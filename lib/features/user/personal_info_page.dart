import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:v3/common/widgets/app_avatar.dart';
import 'package:v3/features/user/user_provider.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key});

  /// 弹出相册/相机选择底栏
  void _showImagePicker(BuildContext context, UserProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await provider.uploadAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await provider.uploadAvatar(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // 1. 头像行（加了 onTap 触发选择头像）
                _buildListItem(
                  title: 'profile image',
                  textColor: textColor,
                  showArrow: true,
                  onTap: () => _showImagePicker(context, provider),
                  trailing: AppAvatar(avatarUrl: provider.avatarUrl, radius: 20),
                ),
                const Divider(height: 1, color: dividerColor),

                // 2. 昵称行
                _buildListItem(
                  title: 'nickname',
                  textColor: textColor,
                  trailingText: provider.userName,
                  valueColor: valueColor,
                  showArrow: true,
                ),
                const Divider(height: 1, color: dividerColor),

                // 3. 邮箱行
                _buildListItem(
                  title: 'email',
                  textColor: textColor,
                  trailingText: '***@***.com',
                  valueColor: valueColor,
                  showArrow: true,
                ),
                const Divider(height: 1, color: dividerColor),

                const Spacer(),

                // 4. Log off 按钮（注销账号）
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF37474),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // TODO: 处理注销逻辑
                    },
                    child: const Text(
                      'Log off',
                      style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // 5. Log out 按钮（退出登录）
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3D14B),
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

          // 上传图像时的遮罩与加载动画
          if (provider.isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator(color: Color(0xFFF3D14B))),
            ),
        ],
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
      ),
    );
  }
}
