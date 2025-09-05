import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final List<String> selectedStatuses;
  final DateTime startDate;
  final DateTime endDate;
  final Function(List<String>, DateTime, DateTime) onApplyFilters;
  final VoidCallback onClose;

  const FilterBottomSheetWidget({
    Key? key,
    required this.selectedStatuses,
    required this.startDate,
    required this.endDate,
    required this.onApplyFilters,
    required this.onClose,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late List<String> _selectedStatuses;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isDateRangeExpanded = true;
  bool _isStatusExpanded = true;

  final List<String> _availableStatuses = [
    'Present',
    'Absent',
    'Late',
    'Early'
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatuses = List.from(widget.selectedStatuses);
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLarge),
          topRight: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      child: Column(
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
          _buildHeader(),
          SizedBox(height: 4.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildDateRangeSection(),
                  SizedBox(height: 3.h),
                  _buildStatusSection(),
                  SizedBox(height: 6.h),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filter Options',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textHighEmphasisDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: widget.onClose,
          child: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.textMediumEmphasisDark,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderDark,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isDateRangeExpanded = !_isDateRangeExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'date_range',
                    color: AppTheme.primaryDark,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Date Range',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textHighEmphasisDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName:
                        _isDateRangeExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.textMediumEmphasisDark,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isDateRangeExpanded) ...[
            Divider(
              color: AppTheme.borderDark,
              height: 1,
              thickness: 1,
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  _buildDateSelector(
                    'Start Date',
                    _startDate,
                    (date) => setState(() => _startDate = date),
                  ),
                  SizedBox(height: 2.h),
                  _buildDateSelector(
                    'End Date',
                    _endDate,
                    (date) => setState(() => _endDate = date),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelector(
      String label, DateTime selectedDate, Function(DateTime) onDateSelected) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: AppTheme.darkTheme,
              child: child!,
            );
          },
        );
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.darkTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: AppTheme.borderDark,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.textMediumEmphasisDark,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.year}',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textHighEmphasisDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.primaryDark,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.borderDark,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isStatusExpanded = !_isStatusExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'filter_list',
                    color: AppTheme.primaryDark,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Status Filters',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textHighEmphasisDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (_selectedStatuses.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedStatuses.length}',
                        style:
                            AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName: _isStatusExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.textMediumEmphasisDark,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isStatusExpanded) ...[
            Divider(
              color: AppTheme.borderDark,
              height: 1,
              thickness: 1,
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: _availableStatuses.map((status) {
                  final isSelected = _selectedStatuses.contains(status);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedStatuses.remove(status);
                        } else {
                          _selectedStatuses.add(status);
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 1.h),
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryDark.withValues(alpha: 0.1)
                            : AppTheme.darkTheme.cardColor,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryDark
                              : AppTheme.borderDark,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryDark
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryDark
                                    : AppTheme.borderDark,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? CustomIconWidget(
                                    iconName: 'check',
                                    color: AppTheme.onPrimaryDark,
                                    size: 14,
                                  )
                                : null,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            status,
                            style: AppTheme.darkTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.textHighEmphasisDark,
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedStatuses.clear();
                _startDate = DateTime.now().subtract(Duration(days: 30));
                _endDate = DateTime.now();
              });
            },
            style: AppTheme.darkTheme.outlinedButtonTheme.style,
            child: Text('Clear All'),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              widget.onApplyFilters(_selectedStatuses, _startDate, _endDate);
            },
            style: AppTheme.darkTheme.elevatedButtonTheme.style,
            child: Text('Apply Filters'),
          ),
        ),
      ],
    );
  }
}
