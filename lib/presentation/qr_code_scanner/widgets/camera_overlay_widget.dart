import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraOverlayWidget extends StatefulWidget {
  final bool isScanning;
  final VoidCallback onClose;
  final VoidCallback onFlashToggle;
  final bool isFlashOn;
  final VoidCallback onManualEntry;

  const CameraOverlayWidget({
    Key? key,
    required this.isScanning,
    required this.onClose,
    required this.onFlashToggle,
    required this.isFlashOn,
    required this.onManualEntry,
  }) : super(key: key);

  @override
  State<CameraOverlayWidget> createState() => _CameraOverlayWidgetState();
}

class _CameraOverlayWidgetState extends State<CameraOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(alpha: 0.6),
        ),

        // Scanning frame cutout
        Center(
          child: Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.primaryDark,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),

        // Animated scanning line
        if (widget.isScanning)
          Center(
            child: Container(
              width: 70.w,
              height: 70.w,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      Positioned(
                        top: _animation.value * (70.w - 4),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppTheme.primaryDark,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

        // Corner indicators
        Center(
          child: Container(
            width: 70.w,
            height: 70.w,
            child: Stack(
              children: [
                // Top-left corner
                Positioned(
                  top: -2,
                  left: -2,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppTheme.primaryDark, width: 4),
                        left: BorderSide(color: AppTheme.primaryDark, width: 4),
                      ),
                    ),
                  ),
                ),
                // Top-right corner
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppTheme.primaryDark, width: 4),
                        right:
                            BorderSide(color: AppTheme.primaryDark, width: 4),
                      ),
                    ),
                  ),
                ),
                // Bottom-left corner
                Positioned(
                  bottom: -2,
                  left: -2,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: AppTheme.primaryDark, width: 4),
                        left: BorderSide(color: AppTheme.primaryDark, width: 4),
                      ),
                    ),
                  ),
                ),
                // Bottom-right corner
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: AppTheme.primaryDark, width: 4),
                        right:
                            BorderSide(color: AppTheme.primaryDark, width: 4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Top header
        Positioned(
          top: MediaQuery.of(context).padding.top + 2.h,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onFlashToggle,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: widget.isFlashOn
                          ? AppTheme.primaryDark.withValues(alpha: 0.8)
                          : Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: CustomIconWidget(
                      iconName: widget.isFlashOn ? 'flash_on' : 'flash_off',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom instruction and manual entry
        Positioned(
          bottom: 8.h,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Text(
                  'Position QR code within frame',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 2.h),
              GestureDetector(
                onTap: widget.onManualEntry,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.primaryDark,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'keyboard',
                        color: Colors.white,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Manual Entry',
                        style:
                            AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
