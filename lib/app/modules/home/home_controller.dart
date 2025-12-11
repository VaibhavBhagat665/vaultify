import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/api_object.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../core/routes/app_routes.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();

  final objects = <ApiObject>[].obs;
  final isLoading = false.obs;
  final error = RxnString();

  int get totalObjects => objects.length;
  bool get isLoggedIn => _authService.isLoggedIn;
  String? get userPhone => _authService.currentUser.value?.phoneNumber;

  @override
  void onInit() {
    super.onInit();
    fetchObjects();
  }

  Future<void> fetchObjects() async {
    isLoading.value = true;
    error.value = null;

    try {
      final apiObjects = await _apiService.getObjects();
      // Combine local objects (persisted) with API objects
      objects.assignAll(_localStorage.combineWithApiObjects(apiObjects));
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addLocalObject(ApiObject obj) {
    _localStorage.addObject(obj);
    objects.insert(0, obj);
  }

  Future<void> logout() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
