import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:petlux/common/l10n/app_localizations.dart';
import 'package:petlux/common/widgets/app_dialogs.dart';
import 'package:petlux/common/widgets/responsive_layout.dart';
import 'package:petlux/features/device/device_provider.dart';
import 'package:petlux/features/device/models/device_dto.dart';
import 'package:petlux/features/user/viewmodels/user_view_model.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  DeviceDto? _selectedDevice;
  final List<XFile> _selectedImages = [];
  static const int _maxImages = 4;

  static const Color _primaryGold = Color(0xFFF3C746);
  static const Color _bgColor = Color(0xFFF9F9FC);
  static const Color _textColor = Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final devices = context.read<DeviceProvider>().devices;
      if (devices.isNotEmpty) {
        setState(() {
          _selectedDevice = devices.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // 弹出选图来源
  Future<void> _pickImage() async {
    if (_selectedImages.length >= _maxImages) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final s = S.of(context)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(s.chooseFromGallery),
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (image != null) {
                    setState(() => _selectedImages.add(image));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(s.takePhoto),
                onTap: () async {
                  Navigator.pop(ctx);
                  final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                  if (photo != null) {
                    setState(() => _selectedImages.add(photo));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 提交处理
  Future<void> _handleSubmit(UserViewModel vm, S s) async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      context.showAppToast(message: s.emptyAccountOrPassword, type: AppToastType.warning);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    // 依次上传附件图片
    List<Map<String, dynamic>> attachmentPayloads = [];
    if (_selectedImages.isNotEmpty) {
      for (var img in _selectedImages) {
        final uploadedUrl = await vm.uploadFeedbackImage(img);
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          attachmentPayloads.add({"url": uploadedUrl, "filename": img.name});
        }
      }
    }

    final success = await vm.submitFeedback(
      title: _titleCtrl.text.trim(),
      body: content,
      deviceId: _selectedDevice?.deviceId,
      productId: _selectedDevice?.productId,
      attachments: attachmentPayloads,
    );

    if (!mounted) return;

    if (success) {
      context.showAppToast(message: s.operationSuccess, type: AppToastType.success);
      context.pop();
    } else {
      context.showAppToast(message: vm.errorMsg.isNotEmpty ? vm.errorMsg : s.operationFailed, type: AppToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context)!;
    final vm = context.watch<UserViewModel>();
    final devices = context.watch<DeviceProvider>().devices;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          s.feedback,
          style: const TextStyle(color: _textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textColor, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ResponsiveFormContainer(
          maxWidth: 600,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 设备选择下拉框
                if (devices.isNotEmpty) ...[
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DeviceDto?>(
                        value: _selectedDevice,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                        hint: Text(s.myDevices, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        items: [
                          DropdownMenuItem<DeviceDto?>(
                            value: null,
                            child: Text(
                              "App Issue (No device)",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ),
                          ...devices.map(
                            (dev) => DropdownMenuItem<DeviceDto?>(
                              value: dev,
                              child: Text(
                                "${dev.deviceName} (${dev.displayId})",
                                style: const TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedDevice = val;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 2. 标题输入框
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(fontSize: 15, color: _textColor),
                    decoration: const InputDecoration(
                      hintText: "Title (Optional)",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 3. 反馈详细描述
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _contentCtrl,
                    maxLines: 5,
                    maxLength: 500,
                    style: const TextStyle(fontSize: 14, color: _textColor, height: 1.5),
                    decoration: InputDecoration(
                      hintText: s.contactUsDesc,
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      counterStyle: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. 附件图片选择网格（最多 4 张）
                Text(
                  "Attachments (${_selectedImages.length}/$_maxImages)",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textColor),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // 已选图片缩略图
                    ..._selectedImages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final image = entry.value;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 76.w,
                            height: 76.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(image: FileImage(File(image.path)), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedImages.removeAt(index));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    // 添加图片按钮
                    if (_selectedImages.length < _maxImages)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 76.w,
                          height: 76.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E5E5), width: 1.2),
                          ),
                          child: const Center(
                            child: Icon(Icons.add_photo_alternate_outlined, size: 28, color: Colors.grey),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 48),

                // 5. 提交按钮
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryGold,
                      foregroundColor: const Color(0xFF222222),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: vm.isLoading ? null : () => _handleSubmit(vm, s),
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF222222)),
                          )
                        : Text(s.confirm, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
