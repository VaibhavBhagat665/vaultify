import 'package:get/get.dart';
import 'object_detail_controller.dart';

class ObjectDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObjectDetailController>(() => ObjectDetailController());
  }
}
