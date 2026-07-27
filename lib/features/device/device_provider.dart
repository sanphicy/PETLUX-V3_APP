import 'package:v3/common/providers/base_provider.dart';
import 'package:v3/core/network/api_endpoints.dart';
import 'package:v3/core/network/http_client.dart';
import 'package:v3/locator.dart';
import 'package:flutter/material.dart';
import 'package:v3/core/mqtt/mqtt_manager.dart';

class DeviceModel {
  final String deviceId;
  final String deviceName;
  final bool isOnline;
  DeviceModel({required this.deviceId, required this.deviceName, required this.isOnline});
}

class DeviceProvider extends BaseProvider {
  List<DeviceModel> _devices = [];
  List<DeviceModel> get devices => _devices;

  // 获取设备列表
  Future<void> fetchDevices() async {
    setLoading(true);
    clearError();
    try {
      final result = await locator<HttpClient>().get<Map<String, dynamic>>(ApiEndpoints.devices);
      if (result.data != null) {
        final List<dynamic> listData = result.data!['items'] ?? [];
        _devices = listData.map((item) {
          final json = item as Map<String, dynamic>;
          return DeviceModel(
            deviceId: json['deviceId']?.toString() ?? '',
            deviceName: json['nickname']?.toString() ?? '',
            isOnline: json['online'] ?? false,
          );
        }).toList();

        _initGlobalMqttAndSubscribe();
        notifyListeners();
      } else {
        setError(result.message);
      }
    } catch (e) {
      setError("网络连接失败，请检查网络设置");
    } finally {
      if (isLoading) setLoading(false);
    }
  }

  // 初始化mqtt
  Future<void> _initGlobalMqttAndSubscribe() async {
    if (_devices.isEmpty) return;

    if (locator<MqttManager>().isConnected) {
      debugPrint('⚡ MQTT 当前已是连接状态，跳过凭证获取，直接检查设备路由...');
      await _subscribeAllDevices();
      return;
    }

    // 未连接时，正常获取凭证
    final credResult = await locator<HttpClient>().post<Map<String, dynamic>>(ApiEndpoints.mqttCredentials);

    if (credResult.code != 0 && credResult.code != 200) {
      debugPrint('❌ 获取 MQTT 凭证失败: ${credResult.message}');
      return;
    }

    final mqttData = credResult.data!['mqtt'];
    if (mqttData == null) {
      debugPrint('❌ MQTT 凭证数据为空');
      return;
    }

    // 建立 MQTT 底层长连接
    final bool isConnected = await locator<MqttManager>().connect(
      endpoint: mqttData['endpoint'],
      port: int.tryParse(mqttData['port'].toString()) ?? 8883,
      username: mqttData['username'],
      password: mqttData['password'],
      clientId: mqttData['clientIdHint'],
      subscribeTopic: mqttData['subscribeTopic'],
      useTls: mqttData['tls'].toString() == 'true',
    );

    // 连上之后，打通云端路由
    if (isConnected) {
      debugPrint('MQTT连接成功');
      await _subscribeAllDevices();
    }
  }

  Future<void> _subscribeAllDevices() async {
    final subResult = await locator<HttpClient>().post(ApiEndpoints.mqttSubscribeSync);

    if (subResult.code == 0 || subResult.code == 200) {
      debugPrint('✅ 一键同步订阅所有设备成功');
    } else {
      debugPrint('⚠️ 一键同步订阅失败: ${subResult.message}');
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    final homeList = await locator<HttpClient>().get(ApiEndpoints.homeList);
    await locator<HttpClient>().delete(ApiEndpoints.deviceUnBind(homeList.data['items'][0]['id'], deviceId));
  }
}
