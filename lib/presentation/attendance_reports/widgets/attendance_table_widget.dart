import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AttendanceTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> attendanceData;
  final Function(Map<String, dynamic>) onRowTap;
  final Function(Map<String, dynamic>) onViewDetails;
  final Function(Map<String, dynamic>) onExportSingle;

  const AttendanceTableWidget({
    Key? key,
    required this.attendanceData,
    required this.onRowTap,
    required this.onViewDetails,
    required this.onExportSingle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (attendanceData.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderDark,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Divider(
            color: AppTheme.borderDark,
            height: 1,
            thickness: 1,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: attendanceData.length,
            separatorBuilder: (context, index) => Divider(
              color: AppTheme.borderDark,
              height: 1,
              thickness: 1,
            ),
            itemBuilder: (context, index) {
              final record = attendanceData[index];
              return _buildTableRow(record, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Date',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textHighEmphasisDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Login',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textHighEmphasisDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Logout',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textHighEmphasisDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Hours',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textHighEmphasisDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.textHighEmphasisDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> record, int index) {
    final isEvenRow = index % 2 == 0;

    return Dismissible(
      key: Key('attendance_${record['id']}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        _showQuickActions(record);
        return false;
      },
      background: Container(
        color: AppTheme.primaryDark.withValues(alpha: 0.2),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomIconWidget(
              iconName: 'visibility',
              color: AppTheme.primaryDark,
              size: 20,
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'file_download',
              color: AppTheme.primaryDark,
              size: 20,
            ),
          ],
        ),
      ),
      child: InkWell(
        onTap: () => onRowTap(record),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          color: isEvenRow
              ? AppTheme.surfaceDark.withValues(alpha: 0.3)
              : Colors.transparent,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  record['date'] as String,
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textHighEmphasisDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  record['loginTime'] as String? ?? '--',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textHighEmphasisDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  record['logoutTime'] as String? ?? '--',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textHighEmphasisDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  record['hoursWorked'] as String? ?? '--',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textHighEmphasisDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: _buildStatusChip(record['status'] as String),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'present':
        statusColor = AppTheme.attendancePresent;
        break;
      case 'absent':
        statusColor = AppTheme.attendanceAbsent;
        break;
      case 'late':
        statusColor = AppTheme.warningDark;
        break;
      default:
        statusColor = AppTheme.textMediumEmphasisDark;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderDark,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'event_busy',
            color: AppTheme.textMediumEmphasisDark,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No attendance data found',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textHighEmphasisDark,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Try adjusting your date range or filters',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMediumEmphasisDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showQuickActions(Map<String, dynamic> record) {
    // This would typically show a bottom sheet with quick actions
    // For now, we'll just call the callbacks directly
  }
}
