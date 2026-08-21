import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../theme/app_theme.dart';

/// Types of toast notifications available
enum ToastType { normal, success, error, info, warning }

/// Position of the toast on the screen
enum ToastPosition { bottom, top }

/// Custom Toast Widget & Overlay Controller.
class AppToast {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// Display a custom toast anywhere in the app using the Overlay stack.
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.normal,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
    Widget? customIcon,
    String? avatarUrl,
    Duration duration = const Duration(milliseconds: 3500),
    ToastPosition position = ToastPosition.bottom,
    VoidCallback? onTap,
    bool showCloseButton = false,
  }) {
    // Dismiss any active toast immediately before showing a new one
    dismissCurrent();

    final overlayState = Overlay.of(context, rootOverlay: true);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _AppToastOverlay(
          message: message,
          type: type,
          actionLabel: actionLabel,
          onAction: () {
            dismissCurrent();
            if (onAction != null) onAction();
          },
          icon: icon,
          customIcon: customIcon,
          avatarUrl: avatarUrl,
          position: position,
          onTap: onTap != null
              ? () {
                  dismissCurrent();
                  onTap();
                }
              : null,
          showCloseButton: showCloseButton,
          onDismissed: () {
            dismissCurrent();
          },
        );
      },
    );

    _currentEntry = entry;
    overlayState.insert(entry);

    _dismissTimer = Timer(duration, () {
      dismissCurrent();
    });
  }

  /// Convenience helper for Success toasts
  static void showSuccess(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(milliseconds: 3500),
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: ToastType.success,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      position: position,
    );
  }

  /// Convenience helper for Error / Alert toasts
  static void showError(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(milliseconds: 3500),
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: ToastType.error,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      position: position,
    );
  }

  /// Convenience helper for Info toasts
  static void showInfo(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(milliseconds: 3500),
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: ToastType.info,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      position: position,
    );
  }

  /// Convenience helper for Warning toasts
  static void showWarning(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(milliseconds: 3500),
    ToastPosition position = ToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: ToastType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      position: position,
    );
  }

  /// Dismiss active toast if showing
  static void dismissCurrent() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    if (_currentEntry != null) {
      try {
        _currentEntry?.remove();
      } catch (_) {}
      _currentEntry = null;
    }
  }
}

/// Internal Animated Overlay Widget for AppToast
class _AppToastOverlay extends StatefulWidget {
  final String message;
  final ToastType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final Widget? customIcon;
  final String? avatarUrl;
  final ToastPosition position;
  final VoidCallback? onTap;
  final bool showCloseButton;
  final VoidCallback onDismissed;

  const _AppToastOverlay({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.customIcon,
    this.avatarUrl,
    required this.position,
    this.onTap,
    this.showCloseButton = false,
    required this.onDismissed,
  });

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final beginOffset = widget.position == ToastPosition.bottom
        ? const Offset(0.0, 0.4)
        : const Offset(0.0, -0.4);

    _slideAnimation = Tween<Offset>(begin: beginOffset, end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _controller.forward();
  }

  void _dismissWithAnimation() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTypeAccentColor(bool isDark) {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.error;
      case ToastType.info:
        return AppColors.info;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.normal:
        return isDark ? AppColors.darkAccent : AppColors.amber;
    }
  }

  IconData _getDefaultIcon() {
    switch (widget.type) {
      case ToastType.success:
        return LucideIcons.circle_check;
      case ToastType.error:
        return LucideIcons.circle_alert;
      case ToastType.info:
        return LucideIcons.info;
      case ToastType.warning:
        return LucideIcons.triangle_alert;
      case ToastType.normal:
        return LucideIcons.sparkles;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? AppColors.darkSurface : AppColors.ink;
    final textColor = isDark ? AppColors.darkInk : Colors.white;
    final borderColor = isDark ? AppColors.darkLine : AppColors.line;
    final accentColor = _getTypeAccentColor(isDark);

    final topPadding = mediaQuery.padding.top + 12;
    final bottomPadding = mediaQuery.padding.bottom + 16;

    return Positioned(
      top: widget.position == ToastPosition.top ? topPadding : null,
      bottom: widget.position == ToastPosition.bottom ? bottomPadding : null,
      left: 16,
      right: 16,
      child: Material(
        type: MaterialType.transparency,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.horizontal,
                onDismissed: (_) => widget.onDismissed(),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: borderColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.4 : 0.25,
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: InkWell(
                        onTap: widget.onTap != null
                            ? () {
                                _dismissWithAnimation();
                                widget.onTap!();
                              }
                            : null,
                        borderRadius: BorderRadius.circular(32),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Leading Icon / Avatar
                              _buildLeadingIcon(accentColor),

                              const SizedBox(width: 12),

                              // Message Text
                              Flexible(
                                child: Text(
                                  widget.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                    height: 1.25,
                                  ),
                                ),
                              ),

                              // Action Button
                              if (widget.actionLabel != null &&
                                  widget.onAction != null) ...[
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    _dismissWithAnimation();
                                    widget.onAction!();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(
                                        alpha: 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      widget.actionLabel!,
                                      style: TextStyle(
                                        fontFamily: 'Satoshi',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: accentColor == AppColors.warning
                                            ? Colors.amber[300]
                                            : accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              // Optional Close Button
                              if (widget.showCloseButton) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: _dismissWithAnimation,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4.0),
                                    child: Icon(
                                      LucideIcons.x,
                                      size: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(Color accentColor) {
    if (widget.customIcon != null) {
      return widget.customIcon!;
    }

    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(widget.avatarUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    final iconData = widget.icon ?? _getDefaultIcon();

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Center(child: Icon(iconData, size: 16, color: accentColor)),
    );
  }
}
