import '../models/leave_balance.dart';
import '../models/leave_request.dart';
import './supabase_service.dart';

class LeaveService {
  static LeaveService? _instance;
  static LeaveService get instance => _instance ??= LeaveService._();

  LeaveService._();

  final _client = SupabaseService.instance.client;

  Future<LeaveRequest> submitLeaveRequest({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final totalDays = _calculateWorkingDays(startDate, endDate);

      final response = await _client
          .from('leave_requests')
          .insert({
            'user_id': userId,
            'leave_type': leaveType,
            'start_date': startDate.toIso8601String().split('T')[0],
            'end_date': endDate.toIso8601String().split('T')[0],
            'total_days': totalDays,
            'reason': reason,
            'status': 'pending',
          })
          .select()
          .single();

      return LeaveRequest.fromJson(response);
    } catch (error) {
      throw Exception('Failed to submit leave request: $error');
    }
  }

  Future<List<LeaveRequest>> getLeaveRequests({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      var query = _client
          .from('leave_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.range(offset, offset + limit - 1);

      return response.map((json) => LeaveRequest.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get leave requests: $error');
    }
  }

  Future<LeaveRequest> updateLeaveRequestStatus({
    required String requestId,
    required String status,
    String? remarks,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = {
        'status': status,
        'approved_by': userId,
        'approved_at': DateTime.now().toIso8601String(),
      };

      if (remarks != null) {
        updates['remarks'] = remarks;
      }

      final response = await _client
          .from('leave_requests')
          .update(updates)
          .eq('id', requestId)
          .select()
          .single();

      return LeaveRequest.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update leave request: $error');
    }
  }

  Future<LeaveBalance?> getLeaveBalance({int? year}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final targetYear = year ?? DateTime.now().year;

      final response = await _client
          .from('leave_balances')
          .select()
          .eq('user_id', userId)
          .eq('year', targetYear)
          .maybeSingle();

      return response != null ? LeaveBalance.fromJson(response) : null;
    } catch (error) {
      throw Exception('Failed to get leave balance: $error');
    }
  }

  Future<LeaveBalance> updateLeaveBalance({
    required int year,
    int? sickLeaveTotal,
    int? vacationLeaveTotal,
    int? personalLeaveTotal,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (sickLeaveTotal != null) updates['sick_leave_total'] = sickLeaveTotal;
      if (vacationLeaveTotal != null)
        updates['vacation_leave_total'] = vacationLeaveTotal;
      if (personalLeaveTotal != null)
        updates['personal_leave_total'] = personalLeaveTotal;

      final response = await _client
          .from('leave_balances')
          .update(updates)
          .eq('user_id', userId)
          .eq('year', year)
          .select()
          .single();

      return LeaveBalance.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update leave balance: $error');
    }
  }

  Future<List<LeaveRequest>> getPendingLeaveRequests() async {
    try {
      // This requires manager/admin role
      final response = await _client
          .from('leave_requests')
          .select(
              '*, user_profiles!leave_requests_user_id_fkey(full_name, employee_id)')
          .eq('status', 'pending')
          .order('created_at', ascending: true);

      return response.map((json) => LeaveRequest.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get pending leave requests: $error');
    }
  }

  Future<Map<String, int>> getLeaveStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final start = startDate ?? DateTime(DateTime.now().year, 1, 1);
      final end = endDate ?? DateTime(DateTime.now().year, 12, 31);

      var query = _client
          .from('leave_requests')
          .select()
          .eq('user_id', userId)
          .gte('start_date', start.toIso8601String().split('T')[0])
          .lte('end_date', end.toIso8601String().split('T')[0]);

      final allRequests = await query;

      final approved =
          allRequests.where((r) => r['status'] == 'approved').toList();
      final pending =
          allRequests.where((r) => r['status'] == 'pending').toList();
      final rejected =
          allRequests.where((r) => r['status'] == 'rejected').toList();

      final approvedDays =
          approved.fold<int>(0, (sum, r) => sum + (r['total_days'] as int));
      final pendingDays =
          pending.fold<int>(0, (sum, r) => sum + (r['total_days'] as int));

      return {
        'total_requests': allRequests.length,
        'approved_requests': approved.length,
        'pending_requests': pending.length,
        'rejected_requests': rejected.length,
        'approved_days': approvedDays,
        'pending_days': pendingDays,
      };
    } catch (error) {
      throw Exception('Failed to get leave statistics: $error');
    }
  }

  int _calculateWorkingDays(DateTime startDate, DateTime endDate) {
    int workingDays = 0;
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
      // Skip weekends (Saturday = 6, Sunday = 7)
      if (currentDate.weekday < 6) {
        workingDays++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return workingDays;
  }
}