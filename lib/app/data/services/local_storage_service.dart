import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_object.dart';

/// Service to persist locally created/modified objects since demo API doesn't store them
class LocalStorageService extends GetxService {
  static const String _localObjectsKey = 'local_objects';
  static const String _deletedIdsKey = 'deleted_ids';
  static const String _modifiedObjectsKey = 'modified_objects';
  
  final localObjects = <ApiObject>[].obs;
  final deletedIds = <String>{}.obs;
  final modifiedObjects = <String, ApiObject>{}.obs;
  SharedPreferences? _prefs;

  Future<LocalStorageService> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadData();
    } catch (e) {
      debugPrint('LocalStorageService init error: $e');
    }
    return this;
  }

  Future<void> _loadData() async {
    if (_prefs == null) return;
    try {
      // Load created objects
      final objStr = _prefs!.getString(_localObjectsKey);
      if (objStr != null) {
        final List<dynamic> jsonList = json.decode(objStr);
        localObjects.assignAll(jsonList.map((e) => ApiObject.fromJson(e)).toList());
      }
      // Load deleted IDs
      final delStr = _prefs!.getString(_deletedIdsKey);
      if (delStr != null) {
        final List<dynamic> ids = json.decode(delStr);
        deletedIds.assignAll(ids.cast<String>());
      }
      // Load modified objects
      final modStr = _prefs!.getString(_modifiedObjectsKey);
      if (modStr != null) {
        final Map<String, dynamic> modMap = json.decode(modStr);
        modifiedObjects.assignAll(
          modMap.map((k, v) => MapEntry(k, ApiObject.fromJson(v))),
        );
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    if (_prefs == null) return;
    try {
      await _prefs!.setString(_localObjectsKey, json.encode(localObjects.map((e) => e.toJson()).toList()));
      await _prefs!.setString(_deletedIdsKey, json.encode(deletedIds.toList()));
      await _prefs!.setString(_modifiedObjectsKey, json.encode(modifiedObjects.map((k, v) => MapEntry(k, v.toJson()))));
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  Future<void> addObject(ApiObject object) async {
    localObjects.insert(0, object);
    await _saveData();
  }

  Future<void> updateObject(ApiObject object) async {
    if (object.id == null) return;
    // Check if it's a locally created object
    final localIndex = localObjects.indexWhere((o) => o.id == object.id);
    if (localIndex != -1) {
      localObjects[localIndex] = object;
    } else {
      // It's an API object - store modification
      modifiedObjects[object.id!] = object;
    }
    await _saveData();
  }

  Future<void> deleteObject(String id) async {
    // Remove from local objects if exists
    localObjects.removeWhere((o) => o.id == id);
    // Remove from modified if exists
    modifiedObjects.remove(id);
    // Add to deleted IDs (for API objects)
    deletedIds.add(id);
    await _saveData();
  }

  List<ApiObject> combineWithApiObjects(List<ApiObject> apiObjects) {
    // Filter out deleted API objects and apply modifications
    final filteredApi = apiObjects
        .where((o) => o.id == null || !deletedIds.contains(o.id))
        .map((o) {
          if (o.id != null && modifiedObjects.containsKey(o.id)) {
            return modifiedObjects[o.id]!;
          }
          return o;
        })
        .toList();
    // Local objects first, then filtered API objects
    return [...localObjects, ...filteredApi];
  }
}
