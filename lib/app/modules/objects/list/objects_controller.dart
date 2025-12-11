import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/api_object.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/local_storage_service.dart';

class ObjectsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final LocalStorageService _localStorage = Get.find<LocalStorageService>();
  
  final RxList<ApiObject> objects = <ApiObject>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxString error = ''.obs;
  
  final ScrollController scrollController = ScrollController();
  
  static const int pageSize = 10;
  int _currentPage = 0;
  List<ApiObject> _allObjects = [];
  
  Timer? _undoTimer;
  ApiObject? _deletedObject;
  int? _deletedIndex;

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
    fetchObjects();
  }

  @override
  void onClose() {
    scrollController.dispose();
    _undoTimer?.cancel();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  Future<void> fetchObjects() async {
    isLoading.value = true;
    error.value = '';
    
    try {
      final apiObjects = await _apiService.getObjects();
      // Combine local objects (persisted) with API objects
      _allObjects = _localStorage.combineWithApiObjects(apiObjects);
      _currentPage = 0;
      objects.clear();
      _loadPage();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadPage() {
    final start = _currentPage * pageSize;
    final end = start + pageSize;
    
    if (start < _allObjects.length) {
      final pageItems = _allObjects.sublist(start, end > _allObjects.length ? _allObjects.length : end);
      objects.addAll(pageItems);
      hasMore.value = end < _allObjects.length;
    } else {
      hasMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    
    isLoadingMore.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    
    _currentPage++;
    _loadPage();
    
    isLoadingMore.value = false;
  }

  Future<void> refresh() async {
    await fetchObjects();
  }

  Future<void> deleteObject(String id) async {
    final index = objects.indexWhere((o) => o.id == id);
    if (index == -1) return;
    
    _deletedObject = objects[index];
    _deletedIndex = index;
    
    objects.removeAt(index);
    _allObjects.removeWhere((o) => o.id == id);
    
    Get.snackbar(
      'Deleted',
      'Object removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.shade900,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      mainButton: TextButton(
        onPressed: _undoDelete,
        child: const Text('UNDO', style: TextStyle(color: Colors.white)),
      ),
    );
    
    _undoTimer?.cancel();
    _undoTimer = Timer(const Duration(seconds: 5), () async {
      // Delete from local storage (works for all objects)
      await _localStorage.deleteObject(id);
      _deletedObject = null;
      _deletedIndex = null;
    });
  }

  void _undoDelete() {
    _undoTimer?.cancel();
    _rollbackDelete();
    Get.closeCurrentSnackbar();
  }

  void _rollbackDelete() {
    if (_deletedObject != null && _deletedIndex != null) {
      if (_deletedIndex! <= objects.length) {
        objects.insert(_deletedIndex!, _deletedObject!);
      } else {
        objects.add(_deletedObject!);
      }
      _deletedObject = null;
      _deletedIndex = null;
    }
  }

  void addObject(ApiObject object) {
    objects.insert(0, object);
    _allObjects.insert(0, object);
    // Persist to local storage
    _localStorage.addObject(object);
  }

  void updateObjectInList(ApiObject object) {
    final index = objects.indexWhere((o) => o.id == object.id);
    if (index != -1) {
      objects[index] = object;
    }
    final allIndex = _allObjects.indexWhere((o) => o.id == object.id);
    if (allIndex != -1) {
      _allObjects[allIndex] = object;
    }
  }
}
