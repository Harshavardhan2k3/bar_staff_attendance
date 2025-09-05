import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionCardWidget extends StatelessWidget {
  final String title;
  final String iconName;
  final VoidCallback onTap;
  final bool isPrimary;
  final String? subtitle;

  const QuickActionCardWidget({
    Key? key,
    required this.title,
    required this.iconName,
    required this.onTap,
    this.isPrimary = false,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color:
              isPrimary ? AppTheme.primaryDark : AppTheme.darkTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowDark,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isPrimary
                    ? AppTheme.onPrimaryDark.withValues(alpha: 0.1)
                    : AppTheme.primaryDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color:
                    isPrimary ? AppTheme.onPrimaryDark : AppTheme.primaryDark,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: isPrimary
                          ? AppTheme.onPrimaryDark
                          : AppTheme.textHighEmphasisDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle!,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: isPrimary
                            ? AppTheme.onPrimaryDark.withValues(alpha: 0.7)
                            : AppTheme.textMediumEmphasisDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: isPrimary
                  ? AppTheme.onPrimaryDark.withValues(alpha: 0.7)
                  : AppTheme.textMediumEmphasisDark,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
