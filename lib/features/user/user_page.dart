import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v3/features/user/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:v3/routes/app_router.dart';
import 'package:v3/common/widgets/app_avatar.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    const Color cardYellow = Color(0xFFCCAC39); // 统计卡片背景色
    const Color nameGreen = Color(0xFF6AB075); // 昵称绿色

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6), // 整体浅灰背景
      body: SafeArea(
        child: Column(
          children: [
            // ==============================
            // 1. 顶部用户信息区
            // ==============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  // 头像与 User 标签
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      AppAvatar(avatarUrl: provider.avatarUrl, radius: 35),
                      Positioned(
                        bottom: -5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A5568),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('User', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 15),
                  // 名字与 ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              provider.userName,
                              style: const TextStyle(fontSize: 18, color: nameGreen, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.edit, color: Colors.grey.shade400, size: 16),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text('ID: ${provider.userId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.grey.shade500, size: 28),
                    onPressed: () {
                      context.push(AppRoutes.personalInfo, extra: provider);
                    },
                  ),
                ],
              ),
            ),

            // ==============================
            // 2. 统计数据卡片
            // ==============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(color: cardYellow, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    _buildStatItem(provider.catCount.toString(), 'Cat'),
                    _buildStatItem(provider.dayCount.toString(), 'Day'),
                    _buildStatItem(provider.deviceCount.toString(), 'Device'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // ==============================
            // 3. 设置列表菜单
            // ==============================
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // 第一组
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildListTile(Icons.chat_bubble_outline, const Color(0xFF6AB075), 'Language setting'),
                        _buildDivider(),
                        _buildListTile(Icons.privacy_tip_outlined, const Color(0xFF805B9A), 'Privacy Policy'),
                        _buildDivider(),
                        _buildListTile(Icons.description_outlined, const Color(0xFFD95A66), 'User Agreement'),
                        _buildDivider(),
                        _buildListTile(Icons.widgets_outlined, const Color(0xFFE2859B), 'Software version'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10), // 分组间距
                  // 第二组
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildListTile(Icons.lightbulb_outline, const Color(0xFF3B9EBA), 'Feedback and suggestions'),
                        _buildDivider(),
                        _buildListTile(Icons.info_outline, const Color(0xFF286A9E), 'About Us'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 统计项小组件
  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w400, height: 1),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  // 列表项小组件
  Widget _buildListTile(IconData icon, Color iconColor, String title) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF333333))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      onTap: () {
        // TODO: 处理点击事件
      },
    );
  }

  // 分割线
  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 56, color: Color(0xFFEEEEEE));
  }
}
