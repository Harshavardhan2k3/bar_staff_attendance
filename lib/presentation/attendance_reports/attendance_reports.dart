import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import './widgets/attendance_table_widget.dart';
import './widgets/date_range_picker_widget.dart';
import './widgets/export_options_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chips_widget.dart';

class AttendanceReports extends StatefulWidget {
  const AttendanceReports({Key? key}) : super(key: key);

  @override
  State<AttendanceReports> createState() => _AttendanceReportsState();
}

class _AttendanceReportsState extends State<AttendanceReports>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<String> _selectedStatuses = [];
  List<String> _activeFilters = [];
  bool _isLoading = false;
  String _lastSyncTime = '';

  // Mock attendance data
  final List<Map<String, dynamic>> _mockAttendanceData = [
    {
      "id": 1,
      "date": "01/05/2025",
      "loginTime": "09:00 AM",
      "logoutTime": "05:30 PM",
      "hoursWorked": "8.5",
      "status": "Present",
      "employeeName": "John Smith",
      "employeeId": "EMP001"
    },
    {
      "id": 2,
      "date": "01/04/2025",
      "loginTime": "09:15 AM",
      "logoutTime": "05:45 PM",
      "hoursWorked": "8.5",
      "status": "Late",
      "employeeName": "John Smith",
      "employeeId": "EMP001"
    },
    {
      "id": 3,
      "date": "01/03/2025",
      "loginTime": "08:45 AM",
      "logoutTime": "05:15 PM",
      "hoursWorked": "8.5",
      "status": "Present",
      "employeeName": "John Smith",
      "employeeId": "EMP001"
    },
    {
      "id": 4,
      "date": "01/02/2025",
      "loginTime": "--",
      "logoutTime": "--",
      "hoursWorked": "0",
      "status": "Absent",
      "employeeName": "John Smith",
      "employeeId": "EMP001"
    },
    {
      "id": 5,
      "date": "01/01/2025",
      "loginTime": "08:30 AM",
      "logoutTime": "04:30 PM",
      "hoursWorked": "8.0",
      "status": "Present",
      "employeeName": "John Smith",
      "employeeId": "EMP001"
    },
    {
      "id": 6,
      "date": "12/31/2024",
      "loginTime": "09:30 AM",
      "logoutTime": "06:00 PM",
      "hoursWorked": "8.5",
      "status": "Late",
      "employeeName": "John Smith",
      "employeeId": "EMP001"
    },
    {
      "id": 7,
      "date": "12/30/2024",
      "loginTime": "08:45 AM",
      "logoutTime": "05:30 PM",
      "hoursWorked": "8.75",
      "status": "Present",
      "employeeName": "John Smith",
      "employeeId": "EMP001"
    },
    {
      "id": 8,
      "date": "12/29/2024",
      "loginTime": "09:00 AM",
      "logoutTime": "05:00 PM",
      "hoursWorked": "8.0",
      "status": "Present",
      "employeeName": "John Smith",
      "employeeId": "EMP001"
    }
  ];

  List<Map<String, dynamic>> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 2);
    _filteredData = List.from(_mockAttendanceData);
    _updateActiveFilters();
    _lastSyncTime = _formatDateTime(DateTime.now());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateActiveFilters() {
    _activeFilters.clear();

    // Add date range filter
    _activeFilters.add('${_formatDate(_startDate)} - ${_formatDate(_endDate)}');

    // Add status filters
    if (_selectedStatuses.isNotEmpty) {
      _activeFilters.addAll(_selectedStatuses);
    }

    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredData = _mockAttendanceData.where((record) {
        // Date range filter
        final recordDate = _parseDate(record['date'] as String);
        if (recordDate.isBefore(_startDate) || recordDate.isAfter(_endDate)) {
          return false;
        }

        // Status filter
        if (_selectedStatuses.isNotEmpty) {
          return _selectedStatuses.contains(record['status'] as String);
        }

        return true;
      }).toList();
    });
  }

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('/');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme,
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _updateActiveFilters();
      });
    }
  }

  void _removeFilter(String filter) {
    setState(() {
      if (_selectedStatuses.contains(filter)) {
        _selectedStatuses.remove(filter);
      }
      _updateActiveFilters();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedStatuses: _selectedStatuses,
        startDate: _startDate,
        endDate: _endDate,
        onApplyFilters: (statuses, start, end) {
          setState(() {
            _selectedStatuses = statuses;
            _startDate = start;
            _endDate = end;
            _updateActiveFilters();
          });
          Navigator.pop(context);
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportOptionsWidget(
        onExportPDF: () {
          Navigator.pop(context);
          _exportToPDF();
        },
        onExportExcel: () {
          Navigator.pop(context);
          _exportToExcel();
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _exportToPDF() async {
    setState(() => _isLoading = true);

    try {
      final content = _generatePDFContent();
      await _downloadFile(content, 'attendance_report.pdf');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF report exported successfully'),
          backgroundColor: AppTheme.successDark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export PDF'),
          backgroundColor: AppTheme.errorDark,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToExcel() async {
    setState(() => _isLoading = true);

    try {
      final content = _generateExcelContent();
      await _downloadFile(content, 'attendance_report.csv');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Excel report exported successfully'),
          backgroundColor: AppTheme.successDark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export Excel'),
          backgroundColor: AppTheme.errorDark,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _generatePDFContent() {
    final buffer = StringBuffer();
    buffer.writeln('ATTENDANCE REPORT');
    buffer.writeln('Generated on: ${_formatDate(DateTime.now())}');
    buffer.writeln(
        'Period: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}');
    buffer.writeln('');
    buffer.writeln('Date\t\tLogin Time\tLogout Time\tHours\tStatus');
    buffer.writeln('=' * 60);

    for (final record in _filteredData) {
      buffer.writeln(
          '${record['date']}\t${record['loginTime']}\t${record['logoutTime']}\t${record['hoursWorked']}\t${record['status']}');
    }

    return buffer.toString();
  }

  String _generateExcelContent() {
    final buffer = StringBuffer();
    buffer.writeln('Date,Login Time,Logout Time,Hours Worked,Status');

    for (final record in _filteredData) {
      buffer.writeln(
          '${record['date']},${record['loginTime']},${record['logoutTime']},${record['hoursWorked']},${record['status']}');
    }

    return buffer.toString();
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _lastSyncTime = _formatDateTime(DateTime.now());
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data refreshed successfully'),
        backgroundColor: AppTheme.successDark,
      ),
    );
  }

  void _onRowTap(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.cardColor,
        title: Text(
          'Attendance Details',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textHighEmphasisDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Date:', record['date'] as String),
            _buildDetailRow(
                'Login Time:', record['loginTime'] as String? ?? '--'),
            _buildDetailRow(
                'Logout Time:', record['logoutTime'] as String? ?? '--'),
            _buildDetailRow(
                'Hours Worked:', record['hoursWorked'] as String? ?? '--'),
            _buildDetailRow('Status:', record['status'] as String),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumEmphasisDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textHighEmphasisDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onViewDetails(Map<String, dynamic> record) {
    _onRowTap(record);
  }

  void _onExportSingle(Map<String, dynamic> record) {
    final content = 'Date,Login Time,Logout Time,Hours Worked,Status\n'
        '${record['date']},${record['loginTime']},${record['logoutTime']},${record['hoursWorked']},${record['status']}';

    _downloadFile(content,
        'attendance_${record['date']?.toString().replaceAll('/', '_')}.csv');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Single record exported successfully'),
        backgroundColor: AppTheme.successDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textHighEmphasisDark,
            size: 24,
          ),
        ),
        title: Text(
          'Attendance Reports',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textHighEmphasisDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showFilterBottomSheet,
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: AppTheme.primaryDark,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: _refreshData,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.textHighEmphasisDark,
              size: 24,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primaryDark,
          labelColor: AppTheme.primaryDark,
          unselectedLabelColor: AppTheme.textMediumEmphasisDark,
          tabs: [
            Tab(text: 'Dashboard'),
            Tab(text: 'Scanner'),
            Tab(text: 'Reports'),
            Tab(text: 'Leave'),
            Tab(text: 'Profile'),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/dashboard');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/qr-code-scanner');
                break;
              case 2:
                // Current screen
                break;
              case 3:
                // Leave screen would be implemented
                break;
              case 4:
                // Profile screen would be implemented
                break;
            }
          },
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryDark,
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: AppTheme.primaryDark,
              backgroundColor: AppTheme.surfaceDark,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    DateRangePickerWidget(
                      startDate: _startDate,
                      endDate: _endDate,
                      onTap: _selectDateRange,
                    ),
                    SizedBox(height: 2.h),
                    FilterChipsWidget(
                      activeFilters: _activeFilters,
                      onRemoveFilter: _removeFilter,
                    ),
                    SizedBox(height: 2.h),
                    if (_lastSyncTime.isNotEmpty)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          'Last synced: $_lastSyncTime',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMediumEmphasisDark,
                          ),
                        ),
                      ),
                    SizedBox(height: 1.h),
                    AttendanceTableWidget(
                      attendanceData: _filteredData,
                      onRowTap: _onRowTap,
                      onViewDetails: _onViewDetails,
                      onExportSingle: _onExportSingle,
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showExportOptions,
        backgroundColor: AppTheme.primaryDark,
        child: CustomIconWidget(
          iconName: 'file_download',
          color: AppTheme.onPrimaryDark,
          size: 24,
        ),
      ),
    );
  }
}