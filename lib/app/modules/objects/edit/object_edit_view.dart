import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../../data/models/api_object.dart';
import '../../../data/services/local_storage_service.dart';

class ObjectEditView extends StatefulWidget {
  const ObjectEditView({super.key});

  @override
  State<ObjectEditView> createState() => _ObjectEditViewState();
}

class _ObjectEditViewState extends State<ObjectEditView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dataController = TextEditingController();
  bool _isLoading = false;
  ApiObject? _object;

  @override
  void initState() {
    super.initState();
    _object = Get.arguments as ApiObject?;
    if (_object != null) {
      _nameController.text = _object!.name;
      if (_object!.data != null && _object!.data!.isNotEmpty) {
        _dataController.text = const JsonEncoder.withIndent('  ').convert(_object!.data);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validateJson(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map) {
        return 'Must be a JSON object {}';
      }
      return null;
    } catch (e) {
      return 'Invalid JSON format';
    }
  }

  Future<void> _updateObject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_object?.id == null) return;

    setState(() => _isLoading = true);

    try {
      final localStorage = Get.find<LocalStorageService>();
      
      Map<String, dynamic>? data;
      if (_dataController.text.trim().isNotEmpty) {
        data = jsonDecode(_dataController.text.trim()) as Map<String, dynamic>;
      }

      final updatedObject = ApiObject(
        id: _object!.id,
        name: _nameController.text.trim(),
        data: data,
      );

      // Save locally - works for all objects
      await localStorage.updateObject(updatedObject);

      Get.back(result: updatedObject);
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
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Object'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Edit Object',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${_object?.id ?? "N/A"}',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(color: AppColors.textMuted),
                            hintText: 'Enter object name',
                            hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
                            prefixIcon: Icon(Icons.label_outline_rounded, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surfaceLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          validator: _validateName,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _dataController,
                          style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                          maxLines: 6,
                          decoration: InputDecoration(
                            labelText: 'Data (JSON, optional)',
                            labelStyle: TextStyle(color: AppColors.textMuted),
                            hintText: '{"color": "blue", "price": 999}',
                            hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
                            filled: true,
                            fillColor: AppColors.surfaceLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                          validator: _validateJson,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateObject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
