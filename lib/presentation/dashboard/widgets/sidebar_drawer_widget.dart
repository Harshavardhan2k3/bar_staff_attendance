import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SidebarDrawerWidget extends StatelessWidget {
  final Function(String) onNavigate;

  const SidebarDrawerWidget({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.dividerDark,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'person',
                      color: AppTheme.onPrimaryDark,
                      size: 24,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'John Doe',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textHighEmphasisDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Bartender',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumEmphasisDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                children: [
                  _buildDrawerItem(
                    'Dashboard',
                    'dashboard',
                    '/dashboard',
                    isActive: true,
                  ),
                  _buildDrawerItem(
                    'QR Scanner',
                    'qr_code_scanner',
                    '/qr-code-scanner',
                  ),
                  _buildDrawerItem(
                    'Attendance Reports',
                    'assessment',
                    '/attendance-reports',
                  ),
                  _buildDrawerItem(
                    'Leave Requests',
                    'event_available',
                    '/leave-requests',
                  ),
                  _buildDrawerItem(
                    'Schedule',
                    'schedule',
                    '/schedule',
                  ),
                  _buildDrawerItem(
                    'Notifications',
                    'notifications',
                    '/notifications',
                  ),
                  Divider(
                    color: AppTheme.dividerDark,
                    indent: 4.w,
                    endIndent: 4.w,
                  ),
                  _buildDrawerItem(
                    'Settings',
                    'settings',
                    '/settings',
                  ),
                  _buildDrawerItem(
                    'Help & Support',
                    'help',
                    '/help',
                  ),
                  _buildDrawerItem(
                    'Logout',
                    'logout',
                    '/login-screen',
                    isLogout: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    String title,
    String iconName,
    String route, {
    bool isActive = false,
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryDark.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: ListTile(
        leading: CustomIconWidget(
          iconName: iconName,
          color: isLogout
              ? AppTheme.errorDark
              : isActive
                  ? AppTheme.primaryDark
                  : AppTheme.textMediumEmphasisDark,
          size: 24,
        ),
        title: Text(
          title,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: isLogout
                ? AppTheme.errorDark
                : isActive
                    ? AppTheme.primaryDark
                    : AppTheme.textHighEmphasisDark,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: () => onNavigate(route),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
      ),
    );
  }
}
