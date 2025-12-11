import 'package:get/get.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
  }
}
