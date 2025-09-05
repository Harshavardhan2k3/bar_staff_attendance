import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExportOptionsWidget extends StatelessWidget {
  final VoidCallback onExportPDF;
  final VoidCallback onExportExcel;
  final VoidCallback onClose;

  const ExportOptionsWidget({
    Key? key,
    required this.onExportPDF,
    required this.onExportExcel,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLarge),
          topRight: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.borderDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Export Options',
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textHighEmphasisDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.textMediumEmphasisDark,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          _buildExportOption(
            icon: 'picture_as_pdf',
            title: 'Export as PDF',
            subtitle: 'Generate a PDF report with all data',
            onTap: onExportPDF,
          ),
          SizedBox(height: 2.h),
          _buildExportOption(
            icon: 'table_chart',
            title: 'Export as Excel',
            subtitle: 'Download Excel file for data analysis',
            onTap: onExportExcel,
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildExportOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.borderDark,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.primaryDark,
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
                      color: AppTheme.textHighEmphasisDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textMediumEmphasisDark,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.textMediumEmphasisDark,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
