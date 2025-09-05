import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Container
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: AppTheme.primaryDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowDark,
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'access_time',
              color: AppTheme.onPrimaryDark,
              size: 10.w,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // App Title
        Text(
          'Bar Staff',
          style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.textHighEmphasisDark,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),

        SizedBox(height: 0.5.h),

        // App Subtitle
        Text(
          'Attendance Tracker',
          style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textMediumEmphasisDark,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
        ),
      ],
    );
  }
}
