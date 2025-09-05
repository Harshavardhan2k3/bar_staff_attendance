import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/app_logo_widget.dart';
import './widgets/login_form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  final AuthService _authService = AuthService.instance;

  Future<void> _handleLogin(String employeeId, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Convert employee ID to email format if needed
      String email =
          employeeId.contains('@') ? employeeId : '$employeeId@barstaff.com';

      final response = await _authService.signInWithEmail(email, password);

      if (response.user != null) {
        // Success - provide haptic feedback
        HapticFeedback.lightImpact();

        // Navigate to dashboard
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        throw Exception('Authentication failed');
      }
    } catch (error) {
      // Failed authentication
      HapticFeedback.heavyImpact();
      setState(() {
        String errorString = error.toString();

        if (errorString.contains('Invalid login credentials')) {
          _errorMessage =
              'Invalid Employee ID or Password. Please check your credentials.';
        } else if (errorString.contains('Email not confirmed')) {
          _errorMessage = 'Please verify your email address before signing in.';
        } else if (errorString.contains('Too many requests')) {
          _errorMessage = 'Too many login attempts. Please try again later.';
        } else if (employeeId.isEmpty || password.isEmpty) {
          _errorMessage = 'Please enter both Employee ID and Password';
        } else {
          _errorMessage =
              'Login failed. Please try again or contact your manager.';
        }
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: GestureDetector(
          onTap: _dismissKeyboard,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),

                    // App Logo Section
                    const AppLogoWidget(),

                    SizedBox(height: 6.h),

                    // Welcome Text
                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style:
                          AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textHighEmphasisDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 1.h),

                    Text(
                      'Sign in to track your attendance',
                      textAlign: TextAlign.center,
                      style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textMediumEmphasisDark,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Error Message
                    _errorMessage != null
                        ? Container(
                            margin: EdgeInsets.only(bottom: 2.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.errorDark.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                              border: Border.all(
                                color:
                                    AppTheme.errorDark.withValues(alpha: 0.3),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'error_outline',
                                  color: AppTheme.errorDark,
                                  size: 5.w,
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTheme
                                        .darkTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: AppTheme.errorDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),

                    // Login Form
                    LoginFormWidget(
                      onLogin: _handleLogin,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: 4.h),

                    // Demo Credentials Section
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.darkTheme.colorScheme.surface
                            .withValues(alpha: 0.3),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: AppTheme.borderDark.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'info',
                                color: AppTheme.primaryDark,
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Demo Credentials',
                                style: AppTheme.darkTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '• Admin: admin / admin123\n'
                            '• Manager: manager / manager456\n'
                            '• Staff: staff001 / password123\n'
                            '• Bartender: bartender / bar2024',
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textMediumEmphasisDark,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // Support Information
                    Text(
                      'Need help? Contact your manager or HR department',
                      textAlign: TextAlign.center,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textDisabledDark,
                      ),
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
