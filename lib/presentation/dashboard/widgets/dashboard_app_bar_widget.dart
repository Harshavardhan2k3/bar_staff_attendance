import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DashboardAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;
  final int notificationCount;

  const DashboardAppBarWidget({
    Key? key,
    required this.onMenuTap,
    required this.onNotificationTap,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      elevation: 0,
      leading: GestureDetector(
        onTap: onMenuTap,
        child: Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.darkTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: CustomIconWidget(
            iconName: 'menu',
            color: AppTheme.textHighEmphasisDark,
            size: 24,
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textMediumEmphasisDark,
            ),
          ),
          Text(
            'Bar Staff',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textHighEmphasisDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: onNotificationTap,
          child: Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  color: AppTheme.textHighEmphasisDark,
                  size: 24,
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(0.5.w),
                      decoration: BoxDecoration(
                        color: AppTheme.errorDark,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 4.w,
                        minHeight: 4.w,
                      ),
                      child: Text(
                        notificationCount > 99
                            ? '99+'
                            : notificationCount.toString(),
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.onErrorDark,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
