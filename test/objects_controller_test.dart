import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:storyverse_studio/app/data/models/api_object.dart';
import 'package:storyverse_studio/app/data/services/api_service.dart';
import 'package:storyverse_studio/app/modules/objects/list/objects_controller.dart';
import 'package:mockito/mockito.dart';

class MockApiService extends GetxService with Mock implements ApiService {
  List<ApiObject> mockObjects = [];
  bool shouldThrow = false;

  @override
  Future<List<ApiObject>> getObjects() async {
    if (shouldThrow) throw ApiException('Test error', 500);
    return mockObjects;
  }

  @override
  Future<void> deleteObject(String id) async {
    if (shouldThrow) throw ApiException('Delete failed', 500);
    mockObjects.removeWhere((o) => o.id == id);
  }
}

void main() {
  late ObjectsController controller;
  late MockApiService mockApiService;

  setUp(() {
    Get.reset();
    mockApiService = MockApiService();
    Get.put<ApiService>(mockApiService);
  });

  tearDown(() {
    Get.reset();
  });

  group('ObjectsController', () {
    test('fetchObjects loads objects successfully', () async {
      mockApiService.mockObjects = [
        ApiObject(id: '1', name: 'Object 1'),
        ApiObject(id: '2', name: 'Object 2'),
        ApiObject(id: '3', name: 'Object 3'),
      ];

      controller = ObjectsController();
      controller.onInit();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.objects.length, 3);
      expect(controller.objects[0].name, 'Object 1');
      expect(controller.isLoading.value, false);
      expect(controller.error.value, '');
    });

    test('fetchObjects handles error correctly', () async {
      mockApiService.shouldThrow = true;

      controller = ObjectsController();
      controller.onInit();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.objects.isEmpty, true);
      expect(controller.error.value.isNotEmpty, true);
      expect(controller.isLoading.value, false);
    });

    test('pagination loads items in pages', () async {
      mockApiService.mockObjects = List.generate(
        25,
        (i) => ApiObject(id: '$i', name: 'Object $i'),
      );

      controller = ObjectsController();
      controller.onInit();

      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.objects.length, 10);
      expect(controller.hasMore.value, true);

      await controller.loadMore();
      await Future.delayed(const Duration(milliseconds: 400));

      expect(controller.objects.length, 20);
      expect(controller.hasMore.value, true);

      await controller.loadMore();
      await Future.delayed(const Duration(milliseconds: 400));

      expect(controller.objects.length, 25);
      expect(controller.hasMore.value, false);
    });

    test('addObject inserts at beginning of list', () async {
      mockApiService.mockObjects = [
        ApiObject(id: '1', name: 'Existing'),
      ];

      controller = ObjectsController();
      controller.onInit();

      await Future.delayed(const Duration(milliseconds: 100));

      final newObject = ApiObject(id: '2', name: 'New Object');
      controller.addObject(newObject);

      expect(controller.objects.length, 2);
      expect(controller.objects[0].name, 'New Object');
    });

    test('updateObjectInList updates existing object', () async {
      mockApiService.mockObjects = [
        ApiObject(id: '1', name: 'Original'),
      ];

      controller = ObjectsController();
      controller.onInit();

      await Future.delayed(const Duration(milliseconds: 100));

      final updated = ApiObject(id: '1', name: 'Updated');
      controller.updateObjectInList(updated);

      expect(controller.objects[0].name, 'Updated');
    });
  });
}
