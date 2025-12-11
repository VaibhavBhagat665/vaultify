import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/services/auth_service.dart';

class OtpController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final otpController = TextEditingController();
  final phoneNumber = ''.obs;
  final canResend = false.obs;
  final resendTimer = 60.obs;
  
  Timer? _timer;
  
  RxBool get isLoading => _authService.isLoading;

  @override
  void onInit() {
    super.onInit();
    phoneNumber.value = Get.arguments as String? ?? '';
    _startResendTimer();
  }

  @override
  void onClose() {
    otpController.dispose();
    _timer?.cancel();
    super.onClose();
  }

  void _startResendTimer() {
    canResend.value = false;
    resendTimer.value = 60;
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    
    if (otp.length != 6) {
      Get.snackbar(
        'Error',
        'Enter 6-digit code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _authService.verifyOtp(
      otp: otp,
      onError: (error) {
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
      },
    );

    if (success) {
      Get.offAllNamed(AppRoutes.home);
      Get.snackbar(
        'Success',
        'Logged in successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade900,
        colorText: Colors.white,
      );
    }
  }

  Future<void> resendOtp() async {
    await _authService.sendOtp(
      phoneNumber: phoneNumber.value,
      onCodeSent: (verificationId) {
        _startResendTimer();
        Get.snackbar(
          'Sent',
          'New OTP sent',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade900,
          colorText: Colors.white,
        );
      },
      onError: (error) {
        Get.snackbar(
          'Error',
          error,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
      },
      onAutoVerify: (credential) async {
        await _authService.signInWithCredential(credential);
        Get.offAllNamed(AppRoutes.home);
      },
    );
  }
}
