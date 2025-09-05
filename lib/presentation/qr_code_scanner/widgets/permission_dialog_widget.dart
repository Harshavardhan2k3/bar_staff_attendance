import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PermissionDialogWidget extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const PermissionDialogWidget({
    Key? key,
    required this.onAllow,
    required this.onDeny,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 85.w,
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppTheme.darkTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.primaryDark,
                size: 10.w,
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              'Camera Permission Required',
              style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                color: AppTheme.darkTheme.colorScheme.onSurface,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Description
            Text(
              'Bar Staff Attendance needs camera access to scan QR codes for attendance tracking. This helps ensure accurate and secure attendance recording.',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumEmphasisDark,
                fontSize: 14.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 3.h),

            // Features list
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: AppTheme.primaryDark.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  _buildFeatureItem(
                    icon: 'qr_code_scanner',
                    title: 'QR Code Scanning',
                    description: 'Scan attendance QR codes quickly',
                  ),
                  SizedBox(height: 2.h),
                  _buildFeatureItem(
                    icon: 'flash_on',
                    title: 'Low-Light Support',
                    description: 'Flash toggle for bar environments',
                  ),
                  SizedBox(height: 2.h),
                  _buildFeatureItem(
                    icon: 'security',
                    title: 'Secure Tracking',
                    description: 'Accurate attendance verification',
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onDeny,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                    child: Text(
                      'Not Now',
                      style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.textMediumEmphasisDark,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAllow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                    child: Text(
                      'Allow Camera',
                      style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryDark.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.primaryDark,
            size: 4.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.darkTheme.colorScheme.onSurface,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                description,
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMediumEmphasisDark,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
