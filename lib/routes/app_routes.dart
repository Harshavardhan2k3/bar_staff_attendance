import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/attendance_reports/attendance_reports.dart';
import '../presentation/qr_code_scanner/qr_code_scanner.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String login = '/login-screen';
  static const String dashboard = '/dashboard';
  static const String attendanceReports = '/attendance-reports';
  static const String qrCodeScanner = '/qr-code-scanner';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    dashboard: (context) => const Dashboard(),
    attendanceReports: (context) => const AttendanceReports(),
    qrCodeScanner: (context) => const QrCodeScanner(),
    // TODO: Add your other routes here
  };
}
