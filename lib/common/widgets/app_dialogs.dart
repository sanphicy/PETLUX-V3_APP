import 'dart:async';
import 'package:flutter/material.dart';
import 'package:petlux/core/services/nav_service.dart';
import 'package:petlux/common/l10n/app_localizations.dart';

enum AppToastType { success, error, warning, info }

enum AppToastPosition { top, center, bottom }

OverlayEntry? _currentToastEntry;
Timer? _toastTimer;

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF222222)),
          ),
          content: Text(content, style: const TextStyle(fontSize: 14, color: Color(0xFF555555), height: 1.4)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(actualCancelText, style: const TextStyle(color: Color(0xFF888888))),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                actualConfirmText,
                style: const TextStyle(
                  color: Color(0xFF222222), // 经典石墨黑加粗
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showAppToast({
    required String message,
    required AppToastType type,
    AppToastPosition position = AppToastPosition.center,
    Duration duration = const Duration(seconds: 2),
  }) {
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (type) {
      case AppToastType.success:
        iconData = Icons.check_circle_rounded;
        iconColor = const Color(0xFF43A047);
        bgColor = const Color(0xFFF1F8F1);
        break;
      case AppToastType.error:
        iconData = Icons.cancel_rounded;
        iconColor = const Color(0xFFE53935);
        bgColor = const Color(0xFFFDF2F2);
        break;
      case AppToastType.warning:
        iconData = Icons.warning_amber_rounded;
        iconColor = const Color(0xFFD97706);
        bgColor = const Color(0xFFFFFBEB);
        break;
      case AppToastType.info:
        iconData = Icons.info_rounded;
        iconColor = const Color(0xFF4B5563);
        bgColor = const Color(0xFFF3F4F6);
        break;
    }

    Alignment alignment;
    EdgeInsets margin;

    switch (position) {
      case AppToastPosition.top:
        alignment = Alignment.topCenter;
        margin = const EdgeInsets.only(top: 50);
        break;
      case AppToastPosition.bottom:
        alignment = Alignment.bottomCenter;
        margin = const EdgeInsets.only(bottom: 50);
        break;
      case AppToastPosition.center:
        alignment = Alignment.center;
        margin = EdgeInsets.zero;
        break;
    }

    final overlayState = Overlay.maybeOf(this) ?? NavService.rootNavigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    _toastTimer?.cancel();
    _toastTimer = null;

    if (_currentToastEntry != null && _currentToastEntry!.mounted) {
      _currentToastEntry!.remove();
      _currentToastEntry = null;
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return SafeArea(
          child: IgnorePointer(
            child: Align(
              alignment: alignment,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: margin,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: iconColor.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(iconData, color: iconColor, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          message,
                          style: TextStyle(color: iconColor, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    _currentToastEntry = entry;
    overlayState.insert(entry);

    _toastTimer = Timer(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
      if (_currentToastEntry == entry) {
        _currentToastEntry = null;
      }
    });
  }
}
