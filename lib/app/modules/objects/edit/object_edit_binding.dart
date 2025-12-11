import 'package:get/get.dart';
import 'object_edit_controller.dart';

class ObjectEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObjectEditController>(() => ObjectEditController());
  }
}
