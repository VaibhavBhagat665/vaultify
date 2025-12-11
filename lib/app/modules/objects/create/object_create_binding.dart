import 'package:get/get.dart';
import 'object_create_controller.dart';

class ObjectCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObjectCreateController>(() => ObjectCreateController());
  }
}
