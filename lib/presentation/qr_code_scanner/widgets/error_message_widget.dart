import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ErrorMessageWidget extends StatefulWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onDismiss;

  const ErrorMessageWidget({
    Key? key,
    required this.message,
    required this.onRetry,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<ErrorMessageWidget> createState() => _ErrorMessageWidgetState();
}

class _ErrorMessageWidgetState extends State<ErrorMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getErrorIcon() {
    if (widget.message.toLowerCase().contains('camera')) {
      return 'camera_alt';
    } else if (widget.message.toLowerCase().contains('network') ||
        widget.message.toLowerCase().contains('connection')) {
      return 'wifi_off';
    } else if (widget.message.toLowerCase().contains('invalid') ||
        widget.message.toLowerCase().contains('code')) {
      return 'qr_code';
    } else {
      return 'error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 12.h,
      left: 4.w,
      right: 4.w,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.errorDark.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: CustomIconWidget(
                        iconName: _getErrorIcon(),
                        color: Colors.white,
                        size: 5.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        widget.message,
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.onDismiss != null)
                      GestureDetector(
                        onTap: widget.onDismiss,
                        child: Container(
                          padding: EdgeInsets.all(1.w),
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 4.w,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.errorDark,
                          padding: EdgeInsets.symmetric(vertical: 2.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'refresh',
                              color: AppTheme.errorDark,
                              size: 4.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Try Again',
                              style: AppTheme.lightTheme.textTheme.labelLarge
                                  ?.copyWith(
                                color: AppTheme.errorDark,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
