import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final Rxn<User> currentUser = Rxn<User>();
  final RxBool isLoading = false.obs;
  final RxString verificationId = ''.obs;
  final RxInt? resendToken = RxInt(0);

  bool get isLoggedIn => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    currentUser.bindStream(_auth.authStateChanges());
  }

  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function(PhoneAuthCredential) onAutoVerify,
  }) async {
    isLoading.value = true;
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          onAutoVerify(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
          String message = 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            message = 'Invalid phone number format. Use +countrycode format';
          } else if (e.code == 'too-many-requests') {
            message = 'Too many requests. Try again later';
          } else if (e.code == 'quota-exceeded') {
            message = 'SMS quota exceeded';
          } else if (e.code == 'app-not-authorized') {
            message = 'App not authorized. Check Firebase config';
          } else if (e.code == 'captcha-check-failed') {
            message = 'reCAPTCHA failed. Try again';
          } else if (e.code == 'web-context-cancelled') {
            message = 'Verification cancelled';
          } else {
            message = e.message ?? 'Verification failed: ${e.code}';
          }
          onError(message);
        },
        codeSent: (String verId, int? token) {
          isLoading.value = false;
          verificationId.value = verId;
          if (token != null) resendToken?.value = token;
          onCodeSent(verId);
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
        },
        forceResendingToken: resendToken?.value,
      );
    } catch (e) {
      isLoading.value = false;
      onError(e.toString());
    }
  }

  Future<bool> verifyOtp({
    required String otp,
    required Function(String) onError,
  }) async {
    if (verificationId.value.isEmpty) {
      onError('No verification in progress');
      return false;
    }

    isLoading.value = true;
    
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );
      
      await _auth.signInWithCredential(credential);
      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = 'Verification failed';
      if (e.code == 'invalid-verification-code') {
        message = 'Invalid OTP code';
      } else if (e.code == 'session-expired') {
        message = 'OTP expired. Request a new one';
      } else {
        message = e.message ?? 'Verification failed';
      }
      onError(message);
      return false;
    } catch (e) {
      isLoading.value = false;
      onError(e.toString());
      return false;
    }
  }

  Future<void> signInWithCredential(PhoneAuthCredential credential) async {
    isLoading.value = true;
    try {
      await _auth.signInWithCredential(credential);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    verificationId.value = '';
  }
}
