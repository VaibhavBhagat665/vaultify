import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_object.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'https://api.restful-api.dev';
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<ApiObject>> getObjects() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/objects'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => ApiObject.fromJson(e)).toList();
      }
      throw ApiException('Failed to load objects', response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<ApiObject> getObject(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/objects/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return ApiObject.fromJson(json.decode(response.body));
      }
      throw ApiException('Object not found', response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }


  Future<ApiObject> createObject(ApiObject object) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/objects'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(object.toCreateJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiObject.fromJson(json.decode(response.body));
      }
      throw ApiException('Failed to create object', response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<ApiObject> updateObject(String id, ApiObject object) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl/objects/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(object.toUpdateJson()),
      );

      if (response.statusCode == 405) {
        throw ApiException('Cannot edit read-only sample object. Create your own object first.', 405);
      }
      if (response.statusCode == 200) {
        return ApiObject.fromJson(json.decode(response.body));
      }
      throw ApiException('Failed to update object', response.statusCode);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<void> deleteObject(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl/objects/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 405) {
        throw ApiException('Cannot delete read-only sample object. Create your own object first.', 405);
      }
      if (response.statusCode != 200) {
        throw ApiException('Failed to delete object', response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }
}
