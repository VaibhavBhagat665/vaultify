import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/api_object.dart';
import '../../../data/services/api_service.dart';

class ObjectEditController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dataController = TextEditingController();
  
  final Rxn<ApiObject> object = Rxn<ApiObject>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ApiObject) {
      object.value = arg;
      nameController.text = arg.name;
      if (arg.data != null && arg.data!.isNotEmpty) {
        dataController.text = const JsonEncoder.withIndent('  ').convert(arg.data);
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    dataController.dispose();
    super.onClose();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validateJson(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    try {
      json.decode(value);
      return null;
    } catch (e) {
      return 'Invalid JSON format';
    }
  }

  Future<void> updateObject() async {
    if (!formKey.currentState!.validate()) return;
    if (object.value?.id == null) return;

    Map<String, dynamic>? data;
    if (dataController.text.trim().isNotEmpty) {
      try {
        data = json.decode(dataController.text.trim()) as Map<String, dynamic>;
      } catch (e) {
        Get.snackbar(
          'Error',
          'Invalid JSON format',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade900,
          colorText: Colors.white,
        );
        return;
      }
    }

    isLoading.value = true;
    try {
      final updatedObject = ApiObject(
        id: object.value!.id,
        name: nameController.text.trim(),
        data: data,
      );
      
      final result = await _apiService.updateObject(object.value!.id!, updatedObject);
      
      Get.back(result: result);
      Get.snackbar(
        'Success',
        'Object updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade900,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
