import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:petlux/common/l10n/app_localizations.dart';

enum AppToastType { success, error, warning, info }

extension AppDialogExtension on BuildContext {
  Future<bool?> showAppDialog({
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
  }) {
    final String actualConfirmText = confirmText ?? S.of(this)!.confirm;
    final String actualCancelText = cancelText ?? S.of(this)!.cancel;

    return showDialog<bool>(
      context: this,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(actualCancelText)),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(actualConfirmText)),
          ],
        );
      },
    );
  }

  void showAppToast({
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.CENTER,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.black.withValues(alpha: 0.75),
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
