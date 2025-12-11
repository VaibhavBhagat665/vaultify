import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  
  RxBool get isLoading => _authService.isLoading;

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!value.startsWith('+')) {
      return 'Include country code (e.g., +1)';
    }
    if (value.length < 10) {
      return 'Invalid phone number';
    }
    return null;
  }

  Future<void> sendOtp() async {
    if (!formKey.currentState!.validate()) return;

    await _authService.sendOtp(
      phoneNumber: phoneController.text.trim(),
      onCodeSent: (verificationId) {
        Get.toNamed(AppRoutes.otp, arguments: phoneController.text.trim());
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
        await _signInWithCredential(credential);
      },
    );
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      await _authService.signInWithCredential(credential);
      Get.offAllNamed(AppRoutes.home);
      Get.snackbar(
        'Success',
        'Logged in successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade900,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    }
  }

  void skipLogin() {
    Get.offAllNamed(AppRoutes.home);
  }
}
