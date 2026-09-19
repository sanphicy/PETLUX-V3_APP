import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @login.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get login;

  /// No description provided for @register.
  ///
  /// In zh, this message translates to:
  /// **'注册'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In zh, this message translates to:
  /// **'创建账号'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码'**
  String get forgotPassword;

  /// No description provided for @phoneLogin.
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get phoneLogin;

  /// No description provided for @emailLogin.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get emailLogin;

  /// No description provided for @emailTitle.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get emailTitle;

  /// No description provided for @enterEmailHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入您的邮箱'**
  String get enterEmailHint;

  /// No description provided for @enterPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get enterPasswordHint;

  /// No description provided for @newPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'设置新密码'**
  String get newPasswordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'确认密码'**
  String get confirmPasswordHint;

  /// No description provided for @enterEmailCodeHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入邮箱验证码'**
  String get enterEmailCodeHint;

  /// No description provided for @sendCode.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get sendCode;

  /// No description provided for @emptyAccountOrPassword.
  ///
  /// In zh, this message translates to:
  /// **'请填写完整信息'**
  String get emptyAccountOrPassword;

  /// No description provided for @invalidAccountFormat.
  ///
  /// In zh, this message translates to:
  /// **'请输入正确的邮箱格式'**
  String get invalidAccountFormat;

  /// No description provided for @passwordMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入的密码不一致'**
  String get passwordMismatch;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In zh, this message translates to:
  /// **'密码重置成功，请重新登录'**
  String get resetPasswordSuccess;

  /// No description provided for @hasAccountGoLogin.
  ///
  /// In zh, this message translates to:
  /// **'已有账号？去登录'**
  String get hasAccountGoLogin;

  /// No description provided for @rememberPasswordGoLogin.
  ///
  /// In zh, this message translates to:
  /// **'想起密码？去登录'**
  String get rememberPasswordGoLogin;

  /// No description provided for @submitAndRegister.
  ///
  /// In zh, this message translates to:
  /// **'提交并注册'**
  String get submitAndRegister;

  /// No description provided for @tokenParseError.
  ///
  /// In zh, this message translates to:
  /// **'登录凭证解析失败，请重试'**
  String get tokenParseError;

  /// No description provided for @accountOrPasswordError.
  ///
  /// In zh, this message translates to:
  /// **'账号或密码错误'**
  String get accountOrPasswordError;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @selectCountry.
  ///
  /// In zh, this message translates to:
  /// **'选择国家/地区'**
  String get selectCountry;

  /// No description provided for @agreePrefix.
  ///
  /// In zh, this message translates to:
  /// **'我已阅读并同意'**
  String get agreePrefix;

  /// No description provided for @userAgreement.
  ///
  /// In zh, this message translates to:
  /// **'《用户协议》'**
  String get userAgreement;

  /// No description provided for @andText.
  ///
  /// In zh, this message translates to:
  /// **'和'**
  String get andText;

  /// No description provided for @privacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'《隐私政策》'**
  String get privacyPolicy;

  /// No description provided for @timesUnit.
  ///
  /// In zh, this message translates to:
  /// **'次'**
  String get timesUnit;

  /// No description provided for @secondsUnit.
  ///
  /// In zh, this message translates to:
  /// **'秒'**
  String get secondsUnit;

  /// No description provided for @minutesUnit.
  ///
  /// In zh, this message translates to:
  /// **'分钟'**
  String get minutesUnit;

  /// No description provided for @tabDevice.
  ///
  /// In zh, this message translates to:
  /// **'设备'**
  String get tabDevice;

  /// No description provided for @tabUsage.
  ///
  /// In zh, this message translates to:
  /// **'概况'**
  String get tabUsage;

  /// No description provided for @tabUser.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get tabUser;

  /// No description provided for @actionIdle.
  ///
  /// In zh, this message translates to:
  /// **'空闲中'**
  String get actionIdle;

  /// No description provided for @actionAddLitter.
  ///
  /// In zh, this message translates to:
  /// **'加砂'**
  String get actionAddLitter;

  /// No description provided for @actionEmptyLitter.
  ///
  /// In zh, this message translates to:
  /// **'清砂'**
  String get actionEmptyLitter;

  /// No description provided for @actionResetting.
  ///
  /// In zh, this message translates to:
  /// **'复位中'**
  String get actionResetting;

  /// No description provided for @networkError.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败，请检查网络设置'**
  String get networkError;

  /// No description provided for @selectCountryRegion.
  ///
  /// In zh, this message translates to:
  /// **'选择国家/地区'**
  String get selectCountryRegion;

  /// No description provided for @searchCountryHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索国家或区号'**
  String get searchCountryHint;

  /// No description provided for @noMatchingRegion.
  ///
  /// In zh, this message translates to:
  /// **'未找到匹配的国家或地区'**
  String get noMatchingRegion;

  /// No description provided for @wifiConfigTitle.
  ///
  /// In zh, this message translates to:
  /// **'配置设备网络'**
  String get wifiConfigTitle;

  /// No description provided for @selectWifiTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择设备的 Wi-Fi'**
  String get selectWifiTitle;

  /// No description provided for @wifiConfigDesc.
  ///
  /// In zh, this message translates to:
  /// **'请选择 Wi-Fi 网络并输入密码。'**
  String get wifiConfigDesc;

  /// No description provided for @wifiPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入 Wi-Fi 密码'**
  String get wifiPasswordHint;

  /// No description provided for @searchingLabel.
  ///
  /// In zh, this message translates to:
  /// **'搜索设备'**
  String get searchingLabel;

  /// No description provided for @startConfig.
  ///
  /// In zh, this message translates to:
  /// **'开始配网'**
  String get startConfig;

  /// No description provided for @configProgress.
  ///
  /// In zh, this message translates to:
  /// **'正在配网中...'**
  String get configProgress;

  /// No description provided for @configStep1.
  ///
  /// In zh, this message translates to:
  /// **'正在向设备下发网络信息'**
  String get configStep1;

  /// No description provided for @configStep2.
  ///
  /// In zh, this message translates to:
  /// **'设备正在连接路由器'**
  String get configStep2;

  /// No description provided for @configStep3.
  ///
  /// In zh, this message translates to:
  /// **'正在向云端注册设备'**
  String get configStep3;

  /// No description provided for @configSuccess.
  ///
  /// In zh, this message translates to:
  /// **'设备添加成功！'**
  String get configSuccess;

  /// No description provided for @autoSearching.
  ///
  /// In zh, this message translates to:
  /// **'正在自动搜索可用设备...'**
  String get autoSearching;

  /// No description provided for @noDeviceFoundDesc.
  ///
  /// In zh, this message translates to:
  /// **'当前未连接设备，请点击下方进行连接。'**
  String get noDeviceFoundDesc;

  /// No description provided for @searchingAvailable.
  ///
  /// In zh, this message translates to:
  /// **'正在搜索可用设备'**
  String get searchingAvailable;

  /// No description provided for @networkSettings.
  ///
  /// In zh, this message translates to:
  /// **'搜索与配网设置'**
  String get networkSettings;

  /// No description provided for @filterUnknownDevices.
  ///
  /// In zh, this message translates to:
  /// **'过滤未知设备'**
  String get filterUnknownDevices;

  /// No description provided for @hideUnnamedDevices.
  ///
  /// In zh, this message translates to:
  /// **'隐藏没有名称的蓝牙设备'**
  String get hideUnnamedDevices;

  /// No description provided for @autoFetchWifi.
  ///
  /// In zh, this message translates to:
  /// **'自动获取周围 Wi-Fi'**
  String get autoFetchWifi;

  /// No description provided for @autoFetchWifiDesc.
  ///
  /// In zh, this message translates to:
  /// **'关闭后不向设备下发扫描指令，配网时将自动读取手机当前连接的 Wi-Fi'**
  String get autoFetchWifiDesc;

  /// No description provided for @exactFilter.
  ///
  /// In zh, this message translates to:
  /// **'精确过滤'**
  String get exactFilter;

  /// No description provided for @exactFilterHint.
  ///
  /// In zh, this message translates to:
  /// **'输入要包含的设备名称 (留空则不过滤)'**
  String get exactFilterHint;

  /// No description provided for @saveAndResearch.
  ///
  /// In zh, this message translates to:
  /// **'保存并重新搜索'**
  String get saveAndResearch;

  /// No description provided for @searchAgain.
  ///
  /// In zh, this message translates to:
  /// **'重新搜索'**
  String get searchAgain;

  /// No description provided for @connect.
  ///
  /// In zh, this message translates to:
  /// **'连接'**
  String get connect;

  /// No description provided for @preparingDeviceChannel.
  ///
  /// In zh, this message translates to:
  /// **'正在准备设备通道'**
  String get preparingDeviceChannel;

  /// No description provided for @configError.
  ///
  /// In zh, this message translates to:
  /// **'配置发生异常'**
  String get configError;

  /// No description provided for @reconfig.
  ///
  /// In zh, this message translates to:
  /// **'重新配置'**
  String get reconfig;

  /// No description provided for @deviceAddedDesc.
  ///
  /// In zh, this message translates to:
  /// **'您的设备已成功连接至网络并绑定。'**
  String get deviceAddedDesc;

  /// No description provided for @manageDevice.
  ///
  /// In zh, this message translates to:
  /// **'管理设备'**
  String get manageDevice;

  /// No description provided for @backToHome.
  ///
  /// In zh, this message translates to:
  /// **'返回首页'**
  String get backToHome;

  /// No description provided for @noBlePermission.
  ///
  /// In zh, this message translates to:
  /// **'未获取蓝牙权限'**
  String get noBlePermission;

  /// No description provided for @ensureBleOn.
  ///
  /// In zh, this message translates to:
  /// **'请确保已开启蓝牙'**
  String get ensureBleOn;

  /// No description provided for @bleScanFailed.
  ///
  /// In zh, this message translates to:
  /// **'扫描失败'**
  String get bleScanFailed;

  /// No description provided for @bleConnectFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接蓝牙失败'**
  String get bleConnectFailed;

  /// No description provided for @wifiOrPwdEmpty.
  ///
  /// In zh, this message translates to:
  /// **'Wi-Fi 或密码不能为空'**
  String get wifiOrPwdEmpty;

  /// No description provided for @getMqttFailed.
  ///
  /// In zh, this message translates to:
  /// **'获取 MQTT 配置失败'**
  String get getMqttFailed;

  /// No description provided for @bindDeviceFailed.
  ///
  /// In zh, this message translates to:
  /// **'绑定设备失败，请重试'**
  String get bindDeviceFailed;

  /// No description provided for @wifiPwdError.
  ///
  /// In zh, this message translates to:
  /// **'Wi-Fi 密码错误或信号极弱'**
  String get wifiPwdError;

  /// No description provided for @networkInterrupted.
  ///
  /// In zh, this message translates to:
  /// **'网络连接中断'**
  String get networkInterrupted;

  /// No description provided for @configTimeoutOrError.
  ///
  /// In zh, this message translates to:
  /// **'配网异常或超时'**
  String get configTimeoutOrError;

  /// No description provided for @myDevices.
  ///
  /// In zh, this message translates to:
  /// **'我的设备'**
  String get myDevices;

  /// No description provided for @addDevice.
  ///
  /// In zh, this message translates to:
  /// **'添加设备'**
  String get addDevice;

  /// No description provided for @online.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get offline;

  /// No description provided for @rename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get rename;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @renameDevice.
  ///
  /// In zh, this message translates to:
  /// **'修改设备名称'**
  String get renameDevice;

  /// No description provided for @deleteDevice.
  ///
  /// In zh, this message translates to:
  /// **'删除设备'**
  String get deleteDevice;

  /// No description provided for @deleteDeviceConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除设备 \"{name}\" 吗？解绑后设备将无法在 App 中操控。'**
  String deleteDeviceConfirm(Object name);

  /// No description provided for @deleteSuccess.
  ///
  /// In zh, this message translates to:
  /// **'设备已成功解绑与删除'**
  String get deleteSuccess;

  /// No description provided for @deleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败，请稍后重试'**
  String get deleteFailed;

  /// No description provided for @deleting.
  ///
  /// In zh, this message translates to:
  /// **'正在删除...'**
  String get deleting;

  /// No description provided for @enterNewDeviceName.
  ///
  /// In zh, this message translates to:
  /// **'请输入新的设备名称'**
  String get enterNewDeviceName;

  /// No description provided for @nameUpdated.
  ///
  /// In zh, this message translates to:
  /// **'设备名称修改成功'**
  String get nameUpdated;

  /// No description provided for @todayToilet.
  ///
  /// In zh, this message translates to:
  /// **'今日如厕'**
  String get todayToilet;

  /// No description provided for @averageDuration.
  ///
  /// In zh, this message translates to:
  /// **'平均时长'**
  String get averageDuration;

  /// No description provided for @autoMode.
  ///
  /// In zh, this message translates to:
  /// **'自动\n模式'**
  String get autoMode;

  /// No description provided for @dndMode.
  ///
  /// In zh, this message translates to:
  /// **'勿扰\n模式'**
  String get dndMode;

  /// No description provided for @timerMode.
  ///
  /// In zh, this message translates to:
  /// **'定时\n模式'**
  String get timerMode;

  /// No description provided for @manualMode.
  ///
  /// In zh, this message translates to:
  /// **'手动\n模式'**
  String get manualMode;

  /// No description provided for @actionClean.
  ///
  /// In zh, this message translates to:
  /// **'清理'**
  String get actionClean;

  /// No description provided for @actionSmooth.
  ///
  /// In zh, this message translates to:
  /// **'抚平'**
  String get actionSmooth;

  /// No description provided for @actionDeodorize.
  ///
  /// In zh, this message translates to:
  /// **'除臭'**
  String get actionDeodorize;

  /// No description provided for @actionChildLock.
  ///
  /// In zh, this message translates to:
  /// **'童锁'**
  String get actionChildLock;

  /// No description provided for @todayLogs.
  ///
  /// In zh, this message translates to:
  /// **'今日运行动态'**
  String get todayLogs;

  /// No description provided for @noLogs.
  ///
  /// In zh, this message translates to:
  /// **'暂无相关动态'**
  String get noLogs;

  /// No description provided for @deviceSetting.
  ///
  /// In zh, this message translates to:
  /// **'设备设置'**
  String get deviceSetting;

  /// No description provided for @firmwareVersion.
  ///
  /// In zh, this message translates to:
  /// **'固件版本'**
  String get firmwareVersion;

  /// No description provided for @serialNumber.
  ///
  /// In zh, this message translates to:
  /// **'设备序列号'**
  String get serialNumber;

  /// No description provided for @timezoneSetting.
  ///
  /// In zh, this message translates to:
  /// **'时区设置'**
  String get timezoneSetting;

  /// No description provided for @modeAndParams.
  ///
  /// In zh, this message translates to:
  /// **'模式与参数配置'**
  String get modeAndParams;

  /// No description provided for @autoModeDelay.
  ///
  /// In zh, this message translates to:
  /// **'自动模式延时'**
  String get autoModeDelay;

  /// No description provided for @dndTimeRange.
  ///
  /// In zh, this message translates to:
  /// **'勿扰时间段'**
  String get dndTimeRange;

  /// No description provided for @timerSchedule.
  ///
  /// In zh, this message translates to:
  /// **'定时模式计划'**
  String get timerSchedule;

  /// No description provided for @moreTools.
  ///
  /// In zh, this message translates to:
  /// **'更多工具与辅助'**
  String get moreTools;

  /// No description provided for @firmwareUpgrade.
  ///
  /// In zh, this message translates to:
  /// **'固件升级'**
  String get firmwareUpgrade;

  /// No description provided for @firmwareUpgrading.
  ///
  /// In zh, this message translates to:
  /// **'固件升级中...'**
  String get firmwareUpgrading;

  /// No description provided for @upgrading.
  ///
  /// In zh, this message translates to:
  /// **'升级中'**
  String get upgrading;

  /// No description provided for @wifiInfo.
  ///
  /// In zh, this message translates to:
  /// **'Wi-Fi 信息'**
  String get wifiInfo;

  /// No description provided for @weighingCalibration.
  ///
  /// In zh, this message translates to:
  /// **'称重校准'**
  String get weighingCalibration;

  /// No description provided for @helpAndSupport.
  ///
  /// In zh, this message translates to:
  /// **'使用帮助与支持'**
  String get helpAndSupport;

  /// No description provided for @newFirmwareFound.
  ///
  /// In zh, this message translates to:
  /// **'检测到新版本 ({version})，是否立即升级？升级过程约需要 1~2 分钟。'**
  String newFirmwareFound(Object version);

  /// No description provided for @confirmUpgrade.
  ///
  /// In zh, this message translates to:
  /// **'确认升级'**
  String get confirmUpgrade;

  /// No description provided for @upgradeDispatched.
  ///
  /// In zh, this message translates to:
  /// **'升级指令已下发，正在检测升级状态...'**
  String get upgradeDispatched;

  /// No description provided for @upgradeSuccess.
  ///
  /// In zh, this message translates to:
  /// **'固件升级完成！'**
  String get upgradeSuccess;

  /// No description provided for @upgradeTimeout.
  ///
  /// In zh, this message translates to:
  /// **'OTA 升级超时，请检查设备状态'**
  String get upgradeTimeout;

  /// No description provided for @deviceOfflineError.
  ///
  /// In zh, this message translates to:
  /// **'设备离线无法操作'**
  String get deviceOfflineError;

  /// No description provided for @deviceOperatingError.
  ///
  /// In zh, this message translates to:
  /// **'设备正在运行中，请稍后操作'**
  String get deviceOperatingError;

  /// No description provided for @operationSuccess.
  ///
  /// In zh, this message translates to:
  /// **'操作成功'**
  String get operationSuccess;

  /// No description provided for @operationFailed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败'**
  String get operationFailed;

  /// No description provided for @useGuide.
  ///
  /// In zh, this message translates to:
  /// **'使用指南'**
  String get useGuide;

  /// No description provided for @guideStep1.
  ///
  /// In zh, this message translates to:
  /// **'1. 确保设备已开启并连接网络'**
  String get guideStep1;

  /// No description provided for @guideStep2.
  ///
  /// In zh, this message translates to:
  /// **'2. 点击右上角 + 按钮添加新设备'**
  String get guideStep2;

  /// No description provided for @guideStep3.
  ///
  /// In zh, this message translates to:
  /// **'3. 向左滑动设备卡片可重命名或删除'**
  String get guideStep3;

  /// No description provided for @guideStep4.
  ///
  /// In zh, this message translates to:
  /// **'4. 下拉列表可手动刷新设备状态'**
  String get guideStep4;

  /// No description provided for @iUnderstand.
  ///
  /// In zh, this message translates to:
  /// **'我知道了'**
  String get iUnderstand;

  /// No description provided for @catToiletLog.
  ///
  /// In zh, this message translates to:
  /// **'猫咪本次如厕: {seconds}秒'**
  String catToiletLog(Object seconds);

  /// No description provided for @scaleCalibrationTitle.
  ///
  /// In zh, this message translates to:
  /// **'称重校准'**
  String get scaleCalibrationTitle;

  /// No description provided for @scaleStep1Title.
  ///
  /// In zh, this message translates to:
  /// **'称重校准准备'**
  String get scaleStep1Title;

  /// No description provided for @scaleStep1Desc.
  ///
  /// In zh, this message translates to:
  /// **'· 确保猫砂盆四周无任何遮挡与碰撞物\n· 确保猫砂盆平稳放置在坚硬平整的地面上'**
  String get scaleStep1Desc;

  /// No description provided for @scaleStep2Title.
  ///
  /// In zh, this message translates to:
  /// **'选择校准参考物'**
  String get scaleStep2Title;

  /// No description provided for @scaleStep2Desc.
  ///
  /// In zh, this message translates to:
  /// **'· 请确保参考物体重量在 1000g - 5000g 之间'**
  String get scaleStep2Desc;

  /// No description provided for @enterWeightInGrams.
  ///
  /// In zh, this message translates to:
  /// **'请输入参考物重量 (单位: 克)'**
  String get enterWeightInGrams;

  /// No description provided for @selectObjectFromList.
  ///
  /// In zh, this message translates to:
  /// **'请将参考物平稳放入盆内中央'**
  String get selectObjectFromList;

  /// No description provided for @scaleStep3Title.
  ///
  /// In zh, this message translates to:
  /// **'放入参考物'**
  String get scaleStep3Title;

  /// No description provided for @scaleStep3Desc.
  ///
  /// In zh, this message translates to:
  /// **'请将已知重量的参考物放入设备桶仓中央'**
  String get scaleStep3Desc;

  /// No description provided for @scaleStep4Title.
  ///
  /// In zh, this message translates to:
  /// **'校准完成'**
  String get scaleStep4Title;

  /// No description provided for @scaleStep4Desc.
  ///
  /// In zh, this message translates to:
  /// **'设备已成功完成称重传感器标定'**
  String get scaleStep4Desc;

  /// No description provided for @nextStep.
  ///
  /// In zh, this message translates to:
  /// **'下一步'**
  String get nextStep;

  /// No description provided for @done.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get done;

  /// No description provided for @invalidWeightError.
  ///
  /// In zh, this message translates to:
  /// **'请输入合法的重量数值 (大于 0g)'**
  String get invalidWeightError;

  /// No description provided for @timeZoneTitle.
  ///
  /// In zh, this message translates to:
  /// **'设备时区'**
  String get timeZoneTitle;

  /// No description provided for @searchTimezoneHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索时区 (例如: Asia/Shanghai)...'**
  String get searchTimezoneHint;

  /// No description provided for @useSystemTimezone.
  ///
  /// In zh, this message translates to:
  /// **'使用手机当前系统时区 ({timezone})'**
  String useSystemTimezone(Object timezone);

  /// No description provided for @noTimerRecord.
  ///
  /// In zh, this message translates to:
  /// **'暂无定时任务记录'**
  String get noTimerRecord;

  /// No description provided for @addTimer.
  ///
  /// In zh, this message translates to:
  /// **'添加定时'**
  String get addTimer;

  /// No description provided for @selectExecutionTime.
  ///
  /// In zh, this message translates to:
  /// **'选择执行时间'**
  String get selectExecutionTime;

  /// No description provided for @saveTimersSuccess.
  ///
  /// In zh, this message translates to:
  /// **'定时任务已成功保存并同步至设备'**
  String get saveTimersSuccess;

  /// No description provided for @saveTimersFailed.
  ///
  /// In zh, this message translates to:
  /// **'定时任务保存失败，请检查设备状态'**
  String get saveTimersFailed;

  /// No description provided for @wifiInfoTitle.
  ///
  /// In zh, this message translates to:
  /// **'Wi-Fi 信息'**
  String get wifiInfoTitle;

  /// No description provided for @networkGood.
  ///
  /// In zh, this message translates to:
  /// **'设备当前 Wi-Fi 网络连接良好'**
  String get networkGood;

  /// No description provided for @networkUnstable.
  ///
  /// In zh, this message translates to:
  /// **'设备当前 Wi-Fi 信号较弱或网络不稳定'**
  String get networkUnstable;

  /// No description provided for @wlanName.
  ///
  /// In zh, this message translates to:
  /// **'Wi-Fi 名称 (SSID)'**
  String get wlanName;

  /// No description provided for @wlanStrength.
  ///
  /// In zh, this message translates to:
  /// **'信号强度 (RSSI)'**
  String get wlanStrength;

  /// No description provided for @ipAddress.
  ///
  /// In zh, this message translates to:
  /// **'IP 地址'**
  String get ipAddress;

  /// No description provided for @macAddress.
  ///
  /// In zh, this message translates to:
  /// **'MAC 地址'**
  String get macAddress;

  /// No description provided for @resetWifi.
  ///
  /// In zh, this message translates to:
  /// **'重置 Wi-Fi'**
  String get resetWifi;

  /// No description provided for @resetWifiSuccess.
  ///
  /// In zh, this message translates to:
  /// **'重置 Wi-Fi 指令已发送，设备即将重启配网模式'**
  String get resetWifiSuccess;

  /// No description provided for @latestVersion.
  ///
  /// In zh, this message translates to:
  /// **'最新'**
  String get latestVersion;

  /// No description provided for @plasmaScheduleTitle.
  ///
  /// In zh, this message translates to:
  /// **'等离子除臭计划'**
  String get plasmaScheduleTitle;

  /// No description provided for @plasmaAlwaysOn.
  ///
  /// In zh, this message translates to:
  /// **'常开模式'**
  String get plasmaAlwaysOn;

  /// No description provided for @plasmaCycleMode.
  ///
  /// In zh, this message translates to:
  /// **'循环计划模式'**
  String get plasmaCycleMode;

  /// No description provided for @plasmaAlwaysOnDesc.
  ///
  /// In zh, this message translates to:
  /// **'设备将全天持续开启等离子除臭'**
  String get plasmaAlwaysOnDesc;

  /// No description provided for @plasmaCycleModeDesc.
  ///
  /// In zh, this message translates to:
  /// **'按设定时间循环启动和间隙释放'**
  String get plasmaCycleModeDesc;

  /// No description provided for @fineGrainedAdjust.
  ///
  /// In zh, this message translates to:
  /// **'精确到秒调节'**
  String get fineGrainedAdjust;

  /// No description provided for @runDuration.
  ///
  /// In zh, this message translates to:
  /// **'运行时间'**
  String get runDuration;

  /// No description provided for @intervalDuration.
  ///
  /// In zh, this message translates to:
  /// **'间隙时间'**
  String get intervalDuration;

  /// No description provided for @plasmaDurationWarning.
  ///
  /// In zh, this message translates to:
  /// **'建议运行和间隙时间不少于30秒'**
  String get plasmaDurationWarning;

  /// No description provided for @dataStatistics.
  ///
  /// In zh, this message translates to:
  /// **'数据统计'**
  String get dataStatistics;

  /// No description provided for @toiletTimes.
  ///
  /// In zh, this message translates to:
  /// **'如厕次数'**
  String get toiletTimes;

  /// No description provided for @toiletDuration.
  ///
  /// In zh, this message translates to:
  /// **'如厕时长'**
  String get toiletDuration;

  /// No description provided for @timesTrend.
  ///
  /// In zh, this message translates to:
  /// **'如厕次数趋势'**
  String get timesTrend;

  /// No description provided for @durationTrend.
  ///
  /// In zh, this message translates to:
  /// **'如厕时长趋势'**
  String get durationTrend;

  /// No description provided for @mon.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get sun;

  /// No description provided for @user.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get user;

  /// No description provided for @personalInfo.
  ///
  /// In zh, this message translates to:
  /// **'个人信息'**
  String get personalInfo;

  /// No description provided for @avatar.
  ///
  /// In zh, this message translates to:
  /// **'头像'**
  String get avatar;

  /// No description provided for @chooseFromGallery.
  ///
  /// In zh, this message translates to:
  /// **'从相册选择'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In zh, this message translates to:
  /// **'拍照'**
  String get takePhoto;

  /// No description provided for @nickname.
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get nickname;

  /// No description provided for @editNickname.
  ///
  /// In zh, this message translates to:
  /// **'修改昵称'**
  String get editNickname;

  /// No description provided for @enterNewNickname.
  ///
  /// In zh, this message translates to:
  /// **'请输入新昵称'**
  String get enterNewNickname;

  /// No description provided for @nicknameUpdated.
  ///
  /// In zh, this message translates to:
  /// **'昵称已修改'**
  String get nicknameUpdated;

  /// No description provided for @accountLabel.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get accountLabel;

  /// No description provided for @emailLabel.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In zh, this message translates to:
  /// **'手机号'**
  String get phoneLabel;

  /// No description provided for @notBound.
  ///
  /// In zh, this message translates to:
  /// **'未绑定'**
  String get notBound;

  /// No description provided for @deleteAccount.
  ///
  /// In zh, this message translates to:
  /// **'注销账号'**
  String get deleteAccount;

  /// No description provided for @logout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get logout;

  /// No description provided for @appVersion.
  ///
  /// In zh, this message translates to:
  /// **'软件版本'**
  String get appVersion;

  /// No description provided for @feedback.
  ///
  /// In zh, this message translates to:
  /// **'意见反馈'**
  String get feedback;

  /// No description provided for @aboutUs.
  ///
  /// In zh, this message translates to:
  /// **'关于我们'**
  String get aboutUs;

  /// No description provided for @languageSetting.
  ///
  /// In zh, this message translates to:
  /// **'语言设置'**
  String get languageSetting;

  /// No description provided for @followSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get followSystem;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In zh, this message translates to:
  /// **'注销后账号数据将永久删除且无法恢复。我们将向 {account} 发送验证码以确认操作。'**
  String deleteAccountConfirm(Object account);

  /// No description provided for @confirmDelete.
  ///
  /// In zh, this message translates to:
  /// **'确认注销'**
  String get confirmDelete;

  /// No description provided for @logoutConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要退出当前账号吗？'**
  String get logoutConfirm;

  /// No description provided for @officialEmailLabel.
  ///
  /// In zh, this message translates to:
  /// **'电子邮箱: '**
  String get officialEmailLabel;

  /// No description provided for @officialWebsiteLabel.
  ///
  /// In zh, this message translates to:
  /// **'官方网站: '**
  String get officialWebsiteLabel;

  /// No description provided for @contactUsDesc.
  ///
  /// In zh, this message translates to:
  /// **'如果您有任何问题或建议，欢迎随时与我们联系：'**
  String get contactUsDesc;

  /// No description provided for @avatarUploadFailed.
  ///
  /// In zh, this message translates to:
  /// **'头像上传失败，请检查相机/相册权限及网络连接'**
  String get avatarUploadFailed;

  /// No description provided for @noCurrentAccount.
  ///
  /// In zh, this message translates to:
  /// **'未获取到当前账号'**
  String get noCurrentAccount;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In zh, this message translates to:
  /// **'注销失败，请稍后重试'**
  String get deleteAccountFailed;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'zh':
      return SZh();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
