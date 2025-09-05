import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ManualEntryDialogWidget extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onCancel;

  const ManualEntryDialogWidget({
    Key? key,
    required this.onSubmit,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<ManualEntryDialogWidget> createState() =>
      _ManualEntryDialogWidgetState();
}

class _ManualEntryDialogWidgetState extends State<ManualEntryDialogWidget> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_codeController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    widget.onSubmit(_codeController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 85.w,
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppTheme.darkTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: CustomIconWidget(
                    iconName: 'qr_code',
                    color: AppTheme.primaryDark,
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Manual QR Code Entry',
                    style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.darkTheme.colorScheme.onSurface,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onCancel,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.textMediumEmphasisDark,
                      size: 5.w,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Instruction text
            Text(
              'Enter the QR code manually if camera scanning is not working properly.',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textMediumEmphasisDark,
                fontSize: 14.sp,
              ),
            ),

            SizedBox(height: 3.h),

            // Input field
            TextField(
              controller: _codeController,
              focusNode: _focusNode,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                labelText: 'QR Code',
                hintText: 'Enter QR code here...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'qr_code_scanner',
                    color: AppTheme.primaryDark,
                    size: 5.w,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: BorderSide(
                    color: AppTheme.borderDark,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: BorderSide(
                    color: AppTheme.borderDark,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  borderSide: BorderSide(
                    color: AppTheme.primaryDark,
                    width: 2,
                  ),
                ),
                fillColor: AppTheme.darkTheme.colorScheme.surface,
                filled: true,
              ),
              style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.darkTheme.colorScheme.onSurface,
                fontSize: 16.sp,
              ),
              onSubmitted: (_) => _handleSubmit(),
            ),

            SizedBox(height: 4.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : widget.onCancel,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.textMediumEmphasisDark,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isSubmitting || _codeController.text.trim().isEmpty
                            ? null
                            : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryDark,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Submit',
                            style: AppTheme.darkTheme.textTheme.labelLarge
                                ?.copyWith(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
