import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttendanceHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> historyData;
  final Function(Map<String, dynamic>) onViewDetails;
  final Function(Map<String, dynamic>) onExport;

  const AttendanceHistoryWidget({
    Key? key,
    required this.historyData,
    required this.onViewDetails,
    required this.onExport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Attendance',
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textHighEmphasisDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, '/attendance-reports'),
                  child: Text(
                    'View All',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historyData.length > 5 ? 5 : historyData.length,
            separatorBuilder: (context, index) => Divider(
              color: AppTheme.dividerDark,
              height: 1,
              indent: 4.w,
              endIndent: 4.w,
            ),
            itemBuilder: (context, index) {
              final item = historyData[index];
              return _buildHistoryItem(context, item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, Map<String, dynamic> item) {
    final date = item['date'] as String? ?? '';
    final loginTime = item['loginTime'] as String? ?? '--:--';
    final logoutTime = item['logoutTime'] as String? ?? '--:--';
    final hoursWorked = item['hoursWorked'] as String? ?? '0.0';
    final status = item['status'] as String? ?? 'present';

    Color statusColor = AppTheme.attendancePresent;
    switch (status.toLowerCase()) {
      case 'absent':
        statusColor = AppTheme.attendanceAbsent;
        break;
      case 'late':
        statusColor = AppTheme.attendancePending;
        break;
      case 'early':
        statusColor = AppTheme.successDark;
        break;
      default:
        statusColor = AppTheme.attendancePresent;
    }

    return Slidable(
      key: ValueKey(item['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onViewDetails(item),
            backgroundColor: AppTheme.primaryDark,
            foregroundColor: AppTheme.onPrimaryDark,
            icon: Icons.visibility,
            label: 'Details',
          ),
          SlidableAction(
            onPressed: (context) => onExport(item),
            backgroundColor: AppTheme.accentDark,
            foregroundColor: AppTheme.onPrimaryDark,
            icon: Icons.download,
            label: 'Export',
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textHighEmphasisDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    status.toUpperCase(),
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$loginTime - $logoutTime',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textHighEmphasisDark,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${hoursWorked}h worked',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumEmphasisDark,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'more_horiz',
              color: AppTheme.textMediumEmphasisDark,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
