
import '../models/attendance_record.dart';
import './supabase_service.dart';

class AttendanceService {
  static AttendanceService? _instance;
  static AttendanceService get instance => _instance ??= AttendanceService._();

  AttendanceService._();

  final _client = SupabaseService.instance.client;

  Future<AttendanceRecord> clockIn({
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final today = DateTime.now().toIso8601String().split('T')[0];

      // Check if already clocked in today
      final existingRecord = await _client
          .from('attendance_records')
          .select()
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();

      if (existingRecord != null && existingRecord['clock_in_time'] != null) {
        throw Exception('Already clocked in today');
      }

      // Get scheduled times
      final schedule = await _getScheduleForToday(userId);

      Map<String, dynamic> data = {
        'user_id': userId,
        'date': today,
        'clock_in_time': DateTime.now().toIso8601String(),
        'scheduled_start': schedule['start_time'],
        'scheduled_end': schedule['end_time'],
        'location_lat': latitude,
        'location_lng': longitude,
        'notes': notes,
      };

      final response = existingRecord == null
          ? await _client
              .from('attendance_records')
              .insert(data)
              .select()
              .single()
          : await _client
              .from('attendance_records')
              .update(data)
              .eq('id', existingRecord['id'])
              .select()
              .single();

      return AttendanceRecord.fromJson(response);
    } catch (error) {
      throw Exception('Clock-in failed: $error');
    }
  }

  Future<AttendanceRecord> clockOut({
    String? notes,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final today = DateTime.now().toIso8601String().split('T')[0];

      // Find today's record
      final record = await _client
          .from('attendance_records')
          .select()
          .eq('user_id', userId)
          .eq('date', today)
          .single();

      if (record['clock_in_time'] == null) {
        throw Exception('Must clock in before clocking out');
      }

      if (record['clock_out_time'] != null) {
        throw Exception('Already clocked out today');
      }

      final clockInTime = DateTime.parse(record['clock_in_time']);
      final clockOutTime = DateTime.now();
      final totalHours = clockOutTime.difference(clockInTime).inMinutes / 60.0;

      final response = await _client
          .from('attendance_records')
          .update({
            'clock_out_time': clockOutTime.toIso8601String(),
            'total_hours': totalHours,
            'notes': notes ?? record['notes'],
          })
          .eq('id', record['id'])
          .select()
          .single();

      return AttendanceRecord.fromJson(response);
    } catch (error) {
      throw Exception('Clock-out failed: $error');
    }
  }

  Future<AttendanceRecord?> getTodayAttendance() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _client
          .from('attendance_records')
          .select()
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();

      return response != null ? AttendanceRecord.fromJson(response) : null;
    } catch (error) {
      throw Exception('Failed to get today\'s attendance: $error');
    }
  }

  Future<List<AttendanceRecord>> getAttendanceHistory({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('attendance_records')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((json) => AttendanceRecord.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get attendance history: $error');
    }
  }

  Future<List<AttendanceRecord>> getAttendanceForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    try {
      final targetUserId = userId ?? _client.auth.currentUser?.id;
      if (targetUserId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('attendance_records')
          .select()
          .eq('user_id', targetUserId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0])
          .order('date', ascending: false);

      return response.map((json) => AttendanceRecord.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to get attendance for date range: $error');
    }
  }

  Future<Map<String, dynamic>> getAttendanceStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      final records = await getAttendanceForDateRange(
        startDate: start,
        endDate: end,
      );

      final totalDays = records.length;
      final presentDays = records.where((r) => r.isPresent).length;
      final absentDays = records.where((r) => r.status == 'absent').length;
      final lateDays = records.where((r) => r.status == 'late').length;
      final totalHours = records.fold(0.0, (sum, r) => sum + r.totalHours);

      return {
        'total_days': totalDays,
        'present_days': presentDays,
        'absent_days': absentDays,
        'late_days': lateDays,
        'total_hours': totalHours,
        'average_hours': totalDays > 0 ? totalHours / totalDays : 0.0,
        'attendance_rate':
            totalDays > 0 ? (presentDays / totalDays) * 100 : 0.0,
      };
    } catch (error) {
      throw Exception('Failed to get attendance statistics: $error');
    }
  }

  Future<Map<String, String?>> _getScheduleForToday(String userId) async {
    try {
      final dayOfWeek = DateTime.now().weekday % 7; // Convert to 0-6 format

      final response = await _client
          .from('work_schedules')
          .select()
          .eq('user_id', userId)
          .eq('day_of_week', dayOfWeek)
          .eq('is_active', true)
          .maybeSingle();

      if (response != null) {
        return {
          'start_time': response['start_time'] as String?,
          'end_time': response['end_time'] as String?,
        };
      }

      return {'start_time': null, 'end_time': null};
    } catch (error) {
      // Return default schedule if no specific schedule found
      return {'start_time': '09:00:00', 'end_time': '18:00:00'};
    }
  }
}
