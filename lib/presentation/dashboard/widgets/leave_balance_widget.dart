import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LeaveBalanceWidget extends StatelessWidget {
  final Map<String, dynamic> leaveData;
  final VoidCallback onRequestLeave;

  const LeaveBalanceWidget({
    Key? key,
    required this.leaveData,
    required this.onRequestLeave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalLeave = leaveData['totalLeave'] as int? ?? 0;
    final usedLeave = leaveData['usedLeave'] as int? ?? 0;
    final pendingRequests = leaveData['pendingRequests'] as int? ?? 0;
    final remainingLeave = totalLeave - usedLeave;

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
                'Leave Balance',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textHighEmphasisDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (pendingRequests > 0)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.attendancePending,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    '$pendingRequests Pending',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.onPrimaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildLeaveItem(
                  'Available',
                  remainingLeave.toString(),
                  AppTheme.attendancePresent,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildLeaveItem(
                  'Used',
                  usedLeave.toString(),
                  AppTheme.textMediumEmphasisDark,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildLeaveItem(
                  'Total',
                  totalLeave.toString(),
                  AppTheme.primaryDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onRequestLeave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: AppTheme.onPrimaryDark,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.onPrimaryDark,
                    size: 18,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Request Leave',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onPrimaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumEmphasisDark,
          ),
        ),
      ],
    );
  }
}
