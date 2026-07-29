import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:v3/features/user/user_provider.dart';
import 'package:v3/common/widgets/app_avatar.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    const Color textColor = Color(0xFF666666);
    const Color valueColor = Color(0xFF999999);
    const Color dividerColor = Color(0xFFEEEEEE);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('personal information', style: TextStyle(color: Colors.black, fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildListItem(
              title: 'profile image',
              textColor: textColor,
              trailing: AppAvatar(avatarUrl: provider.avatarUrl, radius: 20),
            ),
            const Divider(height: 1, color: dividerColor),
            _buildListItem(
              title: 'nickname',
              textColor: textColor,
              trailingText: provider.userName,
              valueColor: valueColor,
              showArrow: true,
            ),
            const Divider(height: 1, color: dividerColor),
            _buildListItem(
              title: 'email',
              textColor: textColor,
              trailingText: '***@***.com', // 目前数据结构无 email，此处作占位
              valueColor: valueColor,
              showArrow: true,
            ),
            const Divider(height: 1, color: dividerColor),

            const Spacer(),

            // Log off 按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF37474), // 红色注销按钮
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () {
                  // TODO: 注销账户的逻辑
                },
                child: const Text(
                  'Log off',
                  style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Log out 按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3D14B), // 黄色退出登录按钮
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () => provider.logout(),
                child: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem({
    required String title,
    Widget? trailing,
    String? trailingText,
    bool showArrow = false,
    required Color textColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: textColor)),
          const Spacer(),
          if (trailing != null) trailing,
          if (trailingText != null) Text(trailingText, style: TextStyle(fontSize: 16, color: valueColor)),
          if (showArrow) ...[
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ],
      ),
    );
  }
}
