import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttendanceCardWidget extends StatelessWidget {
  final Map<String, dynamic> attendanceData;
  final VoidCallback? onTogglePrivacy;
  final bool isPrivacyEnabled;

  const AttendanceCardWidget({
    Key? key,
    required this.attendanceData,
    this.onTogglePrivacy,
    this.isPrivacyEnabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginTime = attendanceData['loginTime'] as String? ?? '--:--';
    final hoursWorked = attendanceData['hoursWorked'] as String? ?? '0.0';
    final isLoggedIn = attendanceData['isLoggedIn'] as bool? ?? false;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Attendance",
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textHighEmphasisDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onTogglePrivacy,
                child: CustomIconWidget(
                  iconName: isPrivacyEnabled ? 'visibility_off' : 'visibility',
                  color: AppTheme.primaryDark,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login Time',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMediumEmphasisDark,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      isPrivacyEnabled ? '••:••' : loginTime,
                      style:
                          AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textHighEmphasisDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hours Worked',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMediumEmphasisDark,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      isPrivacyEnabled ? '•.•' : '${hoursWorked}h',
                      style:
                          AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
            decoration: BoxDecoration(
              color: isLoggedIn
                  ? AppTheme.attendancePresent.withValues(alpha: 0.1)
                  : AppTheme.attendanceAbsent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: isLoggedIn
                    ? AppTheme.attendancePresent
                    : AppTheme.attendanceAbsent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: isLoggedIn ? 'check_circle' : 'schedule',
                  color: isLoggedIn
                      ? AppTheme.attendancePresent
                      : AppTheme.attendanceAbsent,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  isLoggedIn ? 'Currently Clocked In' : 'Not Clocked In',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: isLoggedIn
                        ? AppTheme.attendancePresent
                        : AppTheme.attendanceAbsent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
