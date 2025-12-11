import 'package:get/get.dart';

import 'objects_controller.dart';

class ObjectsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObjectsController>(() => ObjectsController());
  }
}
