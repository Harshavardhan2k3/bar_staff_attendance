import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LoginFormWidget extends StatefulWidget {
  final Function(String employeeId, String password) onLogin;
  final bool isLoading;

  const LoginFormWidget({
    Key? key,
    required this.onLogin,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  String? _employeeIdError;
  String? _passwordError;

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _employeeIdController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _employeeIdError == null &&
        _passwordError == null;
  }

  void _validateEmployeeId(String value) {
    setState(() {
      if (value.isEmpty) {
        _employeeIdError = 'Employee ID is required';
      } else if (value.length < 3) {
        _employeeIdError = 'Employee ID must be at least 3 characters';
      } else {
        _employeeIdError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }
    });
  }

  void _handleLogin() {
    if (_isFormValid && !widget.isLoading) {
      widget.onLogin(_employeeIdController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Employee ID Field
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: _employeeIdError != null
                    ? AppTheme.errorDark
                    : AppTheme.borderDark,
                width: 1.0,
              ),
            ),
            child: TextFormField(
              controller: _employeeIdController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              enabled: !widget.isLoading,
              onChanged: _validateEmployeeId,
              style: AppTheme.darkTheme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Employee ID',
                hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textDisabledDark,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: _employeeIdError != null
                        ? AppTheme.errorDark
                        : AppTheme.textMediumEmphasisDark,
                    size: 5.w,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
            ),
          ),

          // Employee ID Error
          _employeeIdError != null
              ? Padding(
                  padding: EdgeInsets.only(top: 1.h, left: 2.w),
                  child: Text(
                    _employeeIdError!,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.errorDark,
                    ),
                  ),
                )
              : SizedBox(height: 1.h),

          SizedBox(height: 2.h),

          // Password Field
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: _passwordError != null
                    ? AppTheme.errorDark
                    : AppTheme.borderDark,
                width: 1.0,
              ),
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              enabled: !widget.isLoading,
              onChanged: _validatePassword,
              onFieldSubmitted: (_) => _handleLogin(),
              style: AppTheme.darkTheme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textDisabledDark,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'lock',
                    color: _passwordError != null
                        ? AppTheme.errorDark
                        : AppTheme.textMediumEmphasisDark,
                    size: 5.w,
                  ),
                ),
                suffixIcon: GestureDetector(
                  onTap: widget.isLoading
                      ? null
                      : () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName:
                          _isPasswordVisible ? 'visibility' : 'visibility_off',
                      color: AppTheme.textMediumEmphasisDark,
                      size: 5.w,
                    ),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 2.h,
                ),
              ),
            ),
          ),

          // Password Error
          _passwordError != null
              ? Padding(
                  padding: EdgeInsets.only(top: 1.h, left: 2.w),
                  child: Text(
                    _passwordError!,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.errorDark,
                    ),
                  ),
                )
              : SizedBox(height: 1.h),

          SizedBox(height: 2.h),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: widget.isLoading
                  ? null
                  : () {
                      // Navigate to forgot password screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Forgot password feature coming soon'),
                          backgroundColor: AppTheme.primaryDark,
                        ),
                      );
                    },
              child: Text(
                'Forgot Password?',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryDark,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Login Button
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed:
                  _isFormValid && !widget.isLoading ? _handleLogin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFormValid && !widget.isLoading
                    ? AppTheme.primaryDark
                    : AppTheme.textDisabledDark,
                foregroundColor: AppTheme.onPrimaryDark,
                elevation: _isFormValid && !widget.isLoading ? 2.0 : 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      height: 4.w,
                      width: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.onPrimaryDark,
                        ),
                      ),
                    )
                  : Text(
                      'Login',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.onPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
