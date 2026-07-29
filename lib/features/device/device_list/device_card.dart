import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DeviceCard extends StatelessWidget {
  final String deviceName;
  final String deviceId;
  final bool isOnline;
  final String imageUrl;
  final VoidCallback? onTap;

  // 新增回调函数用于左右滑动的操作
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const DeviceCard({
    super.key,
    required this.deviceName,
    required this.deviceId,
    required this.isOnline,
    required this.imageUrl,
    this.onTap,
    this.onRename,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 状态颜色配置
    final Color onlineColor = const Color(0xFF8CC152); // 在线绿色
    final Color offlineColor = const Color(0xFFF39191); // 离线粉红

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      // 使用 Slidable 包裹卡片主体
      child: Slidable(
        key: ValueKey(deviceId),
        // 右侧滑出的操作面板 (向左滑动时显示)
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.5, // 侧滑菜单占据的比例，可根据需要调整
          children: [
            const SizedBox(width: 8), // 增加卡片与按钮之间的间距
            // Rename 按钮
            CustomSlidableAction(
              onPressed: (context) => onRename?.call(),
              backgroundColor: const Color(0xFFEFF5E8), // 浅绿色背景 (参考截图)
              borderRadius: BorderRadius.circular(15),
              child: const Text(
                'Rename',
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8), // 按钮之间的间距
            // Delete 按钮
            CustomSlidableAction(
              onPressed: (context) => onDelete?.call(),
              backgroundColor: const Color(0xFFEFF5E8),
              borderRadius: BorderRadius.circular(15),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        // 卡片主体
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF), // 卡片浅灰色背景
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左侧：设备名称、ID 与状态
                // 1. 使用 Expanded 包裹 Column，限制其最大宽度
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                        // 2. 设置最大行数和溢出省略号
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deviceId,
                        style: const TextStyle(fontSize: 15, color: Color(0xFF888888)),
                        // 同样给 ID 也加上溢出保护，以防万一
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 25),
                      Text(
                        isOnline ? '在线' : '离线',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isOnline ? onlineColor : offlineColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16), // 在文字和图片之间加一点安全间距
                // 右侧：设备图片
                Image.asset(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.devices, size: 80, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
