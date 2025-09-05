import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/attendance_record.dart';
import '../../models/leave_balance.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../services/leave_service.dart';
import './widgets/attendance_card_widget.dart';
import './widgets/attendance_history_widget.dart';
import './widgets/dashboard_app_bar_widget.dart';
import './widgets/leave_balance_widget.dart';
import './widgets/quick_action_card_widget.dart';
import './widgets/sidebar_drawer_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  bool _isPrivacyEnabled = false;
  bool _isRefreshing = false;

  // Services
  final AuthService _authService = AuthService.instance;
  final AttendanceService _attendanceService = AttendanceService.instance;
  final LeaveService _leaveService = LeaveService.instance;

  // Data
  AttendanceRecord? _todayAttendance;
  List<AttendanceRecord> _attendanceHistory = [];
  LeaveBalance? _leaveBalance;
  Map<String, dynamic>? _attendanceStats;
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.wait([
        _loadTodayAttendance(),
        _loadAttendanceHistory(),
        _loadLeaveBalance(),
        _loadAttendanceStats(),
        _loadNotifications(),
      ]);
    } catch (error) {
      // Handle error silently or show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: ${error.toString()}'),
            backgroundColor: AppTheme.errorDark,
          ),
        );
      }
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _loadTodayAttendance() async {
    try {
      final attendance = await _attendanceService.getTodayAttendance();
      setState(() {
        _todayAttendance = attendance;
      });
    } catch (error) {
      debugPrint('Failed to load today\'s attendance: $error');
    }
  }

  Future<void> _loadAttendanceHistory() async {
    try {
      final history = await _attendanceService.getAttendanceHistory(limit: 5);
      setState(() {
        _attendanceHistory = history;
      });
    } catch (error) {
      debugPrint('Failed to load attendance history: $error');
    }
  }

  Future<void> _loadLeaveBalance() async {
    try {
      final balance = await _leaveService.getLeaveBalance();
      setState(() {
        _leaveBalance = balance;
      });
    } catch (error) {
      debugPrint('Failed to load leave balance: $error');
    }
  }

  Future<void> _loadAttendanceStats() async {
    try {
      final stats = await _attendanceService.getAttendanceStatistics();
      setState(() {
        _attendanceStats = stats;
      });
    } catch (error) {
      debugPrint('Failed to load attendance statistics: $error');
    }
  }

  Future<void> _loadNotifications() async {
    try {
      // This would normally fetch notifications from a service
      setState(() {
        _notificationCount = 3; // Mock count
      });
    } catch (error) {
      debugPrint('Failed to load notifications: $error');
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _togglePrivacy() {
    setState(() {
      _isPrivacyEnabled = !_isPrivacyEnabled;
    });
  }

  void _onNavigate(String route) {
    Navigator.pop(context);
    if (route == '/login-screen') {
      _authService.signOut().then((_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          route,
          (route) => false,
        );
      });
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  void _onViewDetails(AttendanceRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.cardColor,
        title: Text(
          'Attendance Details',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textHighEmphasisDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${record.formattedDate}',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textHighEmphasisDark,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Clock In: ${record.clockInTimeFormatted}',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textHighEmphasisDark,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Clock Out: ${record.clockOutTimeFormatted}',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textHighEmphasisDark,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Hours: ${record.totalHoursFormatted}h',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textHighEmphasisDark,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Status: ${record.status.toUpperCase()}',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryDark,
              ),
            ),
            if (record.notes != null) ...[
              SizedBox(height: 1.h),
              Text(
                'Notes: ${record.notes}',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumEmphasisDark,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  void _onExport(AttendanceRecord record) {
    // Show export options
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusMedium),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export Options',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textHighEmphasisDark,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'picture_as_pdf',
                color: AppTheme.errorDark,
                size: 24,
              ),
              title: Text(
                'Export as PDF',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textHighEmphasisDark,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle PDF export
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'table_chart',
                color: AppTheme.successDark,
                size: 24,
              ),
              title: Text(
                'Export as Excel',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textHighEmphasisDark,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle Excel export
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: DashboardAppBarWidget(
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
        onNotificationTap: () => Navigator.pushNamed(context, '/notifications'),
        notificationCount: _notificationCount,
      ),
      drawer: SidebarDrawerWidget(
        onNavigate: _onNavigate,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryDark,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              labelColor: AppTheme.onPrimaryDark,
              unselectedLabelColor: AppTheme.textMediumEmphasisDark,
              labelStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTheme.darkTheme.textTheme.bodySmall,
              tabs: const [
                Tab(text: 'Dashboard'),
                Tab(text: 'Scanner'),
                Tab(text: 'Reports'),
                Tab(text: 'Profile'),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildScannerTab(),
                _buildReportsTab(),
                _buildProfileTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/qr-code-scanner'),
        backgroundColor: AppTheme.primaryDark,
        child: CustomIconWidget(
          iconName: 'qr_code_scanner',
          color: AppTheme.onPrimaryDark,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.primaryDark,
      backgroundColor: AppTheme.darkTheme.cardColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Today's Attendance Card
            AttendanceCardWidget(
              attendanceData: _getTodayAttendanceData(),
              onTogglePrivacy: _togglePrivacy,
              isPrivacyEnabled: _isPrivacyEnabled,
            ),

            // Quick Actions
            QuickActionCardWidget(
              title: 'Scan QR Code',
              iconName: 'qr_code_scanner',
              onTap: () => Navigator.pushNamed(context, '/qr-code-scanner'),
              isPrimary: true,
              subtitle: 'Clock in/out quickly',
            ),

            QuickActionCardWidget(
              title: 'Request Leave',
              iconName: 'event_available',
              onTap: () => Navigator.pushNamed(context, '/leave-requests'),
              subtitle: 'Submit leave application',
            ),

            QuickActionCardWidget(
              title: 'View Schedule',
              iconName: 'schedule',
              onTap: () => Navigator.pushNamed(context, '/schedule'),
              subtitle: 'Check your work schedule',
            ),

            QuickActionCardWidget(
              title: 'Notifications',
              iconName: 'notifications',
              onTap: () => Navigator.pushNamed(context, '/notifications'),
              subtitle: '$_notificationCount new notifications',
            ),

            // Attendance History
            AttendanceHistoryWidget(
              historyData: _getHistoryData(),
              onViewDetails: (data) =>
                  _onViewDetails(_convertToAttendanceRecord(data)),
              onExport: (data) => _onExport(_convertToAttendanceRecord(data)),
            ),

            // Leave Balance
            LeaveBalanceWidget(
              leaveData: _getLeaveData(),
              onRequestLeave: () =>
                  Navigator.pushNamed(context, '/leave-requests'),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'qr_code_scanner',
            color: AppTheme.primaryDark,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'QR Code Scanner',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textHighEmphasisDark,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tap the button below to start scanning',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMediumEmphasisDark,
            ),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/qr-code-scanner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDark,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            ),
            child: Text(
              'Open Scanner',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.onPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'assessment',
            color: AppTheme.primaryDark,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Attendance Reports',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.textHighEmphasisDark,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'View detailed attendance reports',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textMediumEmphasisDark,
            ),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/attendance-reports'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryDark,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            ),
            child: Text(
              'View Reports',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.onPrimaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Column(
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.onPrimaryDark,
                    size: 32,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _authService.currentUser?.userMetadata?['full_name'] ??
                      'User',
                  style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textHighEmphasisDark,
                  ),
                ),
                Text(
                  _authService.currentUser?.userMetadata?['role']
                          ?.toString()
                          .toUpperCase() ??
                      'Staff',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMediumEmphasisDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProfileStat('Hours This Week', _getWeeklyHours()),
                    _buildProfileStat('Days Present', _getPresentDays()),
                    _buildProfileStat('Leave Balance', _getRemainingLeave()),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          _buildProfileOption('Settings', 'settings', () {}),
          _buildProfileOption('Change Password', 'lock', () {}),
          _buildProfileOption('Help & Support', 'help', () {}),
          _buildProfileOption('About', 'info', () {}),
          SizedBox(height: 2.h),
          _buildProfileOption('Logout', 'logout', () {
            _onNavigate('/login-screen');
          }, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textMediumEmphasisDark,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(String title, String iconName, VoidCallback onTap,
      {bool isLogout = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: ListTile(
        leading: CustomIconWidget(
          iconName: iconName,
          color:
              isLogout ? AppTheme.errorDark : AppTheme.textMediumEmphasisDark,
          size: 24,
        ),
        title: Text(
          title,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color:
                isLogout ? AppTheme.errorDark : AppTheme.textHighEmphasisDark,
          ),
        ),
        trailing: CustomIconWidget(
          iconName: 'chevron_right',
          color: AppTheme.textMediumEmphasisDark,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  // Helper methods to convert real data to widget format
  Map<String, dynamic> _getTodayAttendanceData() {
    if (_todayAttendance == null) {
      return {
        "loginTime": "--:--",
        "hoursWorked": "0.0",
        "isLoggedIn": false,
      };
    }

    return {
      "loginTime": _todayAttendance!.clockInTimeFormatted,
      "hoursWorked": _todayAttendance!.totalHoursFormatted,
      "isLoggedIn": _todayAttendance!.clockInTime != null &&
          _todayAttendance!.clockOutTime == null,
    };
  }

  List<Map<String, dynamic>> _getHistoryData() {
    return _attendanceHistory
        .map((record) => {
              "id": record.id,
              "date": record.formattedDate,
              "loginTime": record.clockInTimeFormatted,
              "logoutTime": record.clockOutTimeFormatted,
              "hoursWorked": record.totalHoursFormatted,
              "status": record.status,
            })
        .toList();
  }

  Map<String, dynamic> _getLeaveData() {
    if (_leaveBalance == null) {
      return {
        "totalLeave": 24,
        "usedLeave": 0,
        "pendingRequests": 0,
      };
    }

    return {
      "totalLeave": _leaveBalance!.totalLeaveEntitlement,
      "usedLeave": _leaveBalance!.totalLeaveUsed,
      "pendingRequests": 0, // This would come from pending leave requests
    };
  }

  AttendanceRecord _convertToAttendanceRecord(Map<String, dynamic> data) {
    // Find the record in our list by ID
    return _attendanceHistory.firstWhere(
      (record) => record.id == data['id'],
      orElse: () => AttendanceRecord(
        id: data['id'].toString(),
        userId: '',
        date: DateTime.now(),
        status: data['status'].toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  String _getWeeklyHours() {
    if (_attendanceStats == null) return '0.0';
    // This would be calculated based on current week
    return (_attendanceStats!['total_hours'] ?? 0.0).toStringAsFixed(1);
  }

  String _getPresentDays() {
    if (_attendanceStats == null) return '0';
    return (_attendanceStats!['present_days'] ?? 0).toString();
  }

  String _getRemainingLeave() {
    if (_leaveBalance == null) return '0';
    return _leaveBalance!.totalLeaveRemaining.toString();
  }
}
