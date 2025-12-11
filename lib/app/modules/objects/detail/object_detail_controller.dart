import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/api_object.dart';
import '../../../data/services/local_storage_service.dart';

class ObjectDetailController extends GetxController {
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();
  
  final Rxn<ApiObject> object = Rxn<ApiObject>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ApiObject) {
      object.value = arg;
    }
  }

  Future<void> deleteObject() async {
    final obj = object.value;
    if (obj?.id == null) return;

    isLoading.value = true;
    // Delete locally - works for all objects
    await _localStorage.deleteObject(obj!.id!);
    Get.back(result: 'deleted');
    Get.snackbar(
      'Deleted',
      'Object removed successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.shade900,
      colorText: Colors.white,
    );
    isLoading.value = false;
  }
}
