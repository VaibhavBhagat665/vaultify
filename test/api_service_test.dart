import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:storyverse_studio/app/data/services/api_service.dart';
import 'package:storyverse_studio/app/data/models/api_object.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;

    test('getObjects returns list of ApiObject on success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://api.restful-api.dev/objects');
        return http.Response(
          json.encode([
            {'id': '1', 'name': 'Test Object 1'},
            {'id': '2', 'name': 'Test Object 2'},
          ]),
          200,
        );
      });

      apiService = ApiService(client: mockClient);
      final objects = await apiService.getObjects();

      expect(objects, isA<List<ApiObject>>());
      expect(objects.length, 2);
      expect(objects[0].name, 'Test Object 1');
      expect(objects[1].name, 'Test Object 2');
    });

    test('getObjects throws ApiException on error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      apiService = ApiService(client: mockClient);

      expect(
        () => apiService.getObjects(),
        throwsA(isA<ApiException>()),
      );
    });

    test('createObject sends POST and returns created object', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'https://api.restful-api.dev/objects');
        
        final body = json.decode(request.body);
        expect(body['name'], 'New Object');
        
        return http.Response(
          json.encode({
            'id': '123',
            'name': 'New Object',
            'createdAt': '2024-01-01T00:00:00.000Z',
          }),
          201,
        );
      });

      apiService = ApiService(client: mockClient);
      final newObject = ApiObject(name: 'New Object');
      final created = await apiService.createObject(newObject);

      expect(created.id, '123');
      expect(created.name, 'New Object');
    });

    test('updateObject sends PUT and returns updated object', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.toString(), 'https://api.restful-api.dev/objects/123');
        
        return http.Response(
          json.encode({
            'id': '123',
            'name': 'Updated Object',
            'updatedAt': '2024-01-02T00:00:00.000Z',
          }),
          200,
        );
      });

      apiService = ApiService(client: mockClient);
      final object = ApiObject(id: '123', name: 'Updated Object');
      final updated = await apiService.updateObject('123', object);

      expect(updated.id, '123');
      expect(updated.name, 'Updated Object');
    });

    test('deleteObject sends DELETE request', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.toString(), 'https://api.restful-api.dev/objects/123');
        return http.Response('{"message": "deleted"}', 200);
      });

      apiService = ApiService(client: mockClient);
      await apiService.deleteObject('123');
      // No exception means success
    });
  });
}
