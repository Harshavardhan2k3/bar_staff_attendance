import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/camera_overlay_widget.dart';
import './widgets/error_message_widget.dart';
import './widgets/manual_entry_dialog_widget.dart';
import './widgets/permission_dialog_widget.dart';
import './widgets/success_animation_widget.dart';

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({Key? key}) : super(key: key);

  @override
  State<QrCodeScanner> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner>
    with WidgetsBindingObserver {
  MobileScannerController? _scannerController;
  bool _isInitialized = false;
  bool _isScanning = true;
  bool _isFlashOn = false;
  bool _hasPermission = false;
  bool _showPermissionDialog = false;
  bool _showSuccessAnimation = false;
  bool _showManualEntry = false;
  String? _errorMessage;
  String? _scannedEmployeeName;
  bool _isProcessingCode = false;

  // Mock attendance data
  final Map<String, Map<String, dynamic>> _attendanceData = {
    "EMP001": {
      "employeeId": "EMP001",
      "name": "Sarah Johnson",
      "department": "Bar Staff",
      "shift": "Evening",
      "status": "active"
    },
    "EMP002": {
      "employeeId": "EMP002",
      "name": "Michael Chen",
      "department": "Kitchen Staff",
      "shift": "Night",
      "status": "active"
    },
    "EMP003": {
      "employeeId": "EMP003",
      "name": "Emma Rodriguez",
      "department": "Server",
      "shift": "Day",
      "status": "active"
    },
    "EMP004": {
      "employeeId": "EMP004",
      "name": "James Wilson",
      "department": "Bartender",
      "shift": "Evening",
      "status": "active"
    },
    "EMP005": {
      "employeeId": "EMP005",
      "name": "Lisa Thompson",
      "department": "Manager",
      "shift": "Day",
      "status": "active"
    }
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_scannerController == null || !_isInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _scannerController!.start();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        _scannerController!.stop();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _initializeScanner() async {
    try {
      final hasPermission = await _requestCameraPermission();

      if (!hasPermission) {
        setState(() {
          _showPermissionDialog = true;
        });
        return;
      }

      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

      await _scannerController!.start();

      setState(() {
        _isInitialized = true;
        _hasPermission = true;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera. Please try again.';
      });
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessingCode || !_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
      _processQRCode(code);
    }
  }

  Future<void> _processQRCode(String code) async {
    if (_isProcessingCode) return;

    setState(() {
      _isProcessingCode = true;
      _isScanning = false;
      _errorMessage = null;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Check if code exists in mock data
      final employeeData = _attendanceData[code];

      if (employeeData != null) {
        // Success - show animation
        setState(() {
          _scannedEmployeeName = employeeData['name'] as String;
          _showSuccessAnimation = true;
        });
      } else {
        // Invalid QR code
        setState(() {
          _errorMessage =
              'Invalid QR code. Please try again or use manual entry.';
          _isScanning = true;
          _isProcessingCode = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Network error. Please check your connection and try again.';
        _isScanning = true;
        _isProcessingCode = false;
      });
    }
  }

  void _toggleFlash() async {
    if (_scannerController == null || !_isInitialized) return;

    try {
      await _scannerController!.toggleTorch();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      // Flash not supported on this device
    }
  }

  void _showManualEntryDialog() {
    setState(() {
      _showManualEntry = true;
    });
  }

  void _hideManualEntryDialog() {
    setState(() {
      _showManualEntry = false;
    });
  }

  void _onManualCodeSubmit(String code) {
    _hideManualEntryDialog();
    _processQRCode(code);
  }

  void _onSuccessComplete() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/dashboard',
      (route) => false,
    );
  }

  void _onClose() {
    Navigator.pop(context);
  }

  void _onRetryError() {
    setState(() {
      _errorMessage = null;
      _isScanning = true;
      _isProcessingCode = false;
    });
  }

  void _onPermissionAllow() {
    setState(() {
      _showPermissionDialog = false;
    });
    _initializeScanner();
  }

  void _onPermissionDeny() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview or placeholder
          if (_isInitialized && _hasPermission && _scannerController != null)
            MobileScanner(
              controller: _scannerController!,
              onDetect: _onDetect,
            )
          else
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'camera_alt',
                      color: AppTheme.textMediumEmphasisDark,
                      size: 20.w,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Initializing Camera...',
                      style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textMediumEmphasisDark,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Camera overlay
          if (_isInitialized && _hasPermission)
            CameraOverlayWidget(
              isScanning: _isScanning,
              onClose: _onClose,
              onFlashToggle: _toggleFlash,
              isFlashOn: _isFlashOn,
              onManualEntry: _showManualEntryDialog,
            ),

          // Processing indicator
          if (_isProcessingCode)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppTheme.darkTheme.cardColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12.w,
                        height: 12.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryDark,
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Processing QR Code...',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.darkTheme.colorScheme.onSurface,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Error message
          if (_errorMessage != null)
            ErrorMessageWidget(
              message: _errorMessage!,
              onRetry: _onRetryError,
              onDismiss: () {
                setState(() {
                  _errorMessage = null;
                });
              },
            ),

          // Success animation
          if (_showSuccessAnimation && _scannedEmployeeName != null)
            SuccessAnimationWidget(
              employeeName: _scannedEmployeeName!,
              onComplete: _onSuccessComplete,
            ),

          // Manual entry dialog
          if (_showManualEntry)
            ManualEntryDialogWidget(
              onSubmit: _onManualCodeSubmit,
              onCancel: _hideManualEntryDialog,
            ),

          // Permission dialog
          if (_showPermissionDialog)
            PermissionDialogWidget(
              onAllow: _onPermissionAllow,
              onDeny: _onPermissionDeny,
            ),
        ],
      ),
    );
  }
}
