import 'package:get/get.dart';
import 'app_routes.dart';
import '../../modules/splash/splash_view.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/auth/login/login_view.dart';
import '../../modules/auth/login/login_binding.dart';
import '../../modules/auth/otp/otp_view.dart';
import '../../modules/auth/otp/otp_binding.dart';
import '../../modules/home/home_view.dart';
import '../../modules/home/home_binding.dart';
import '../../modules/objects/list/objects_view.dart';
import '../../modules/objects/list/objects_binding.dart';
import '../../modules/objects/detail/object_detail_view.dart';
import '../../modules/objects/detail/object_detail_binding.dart';
import '../../modules/objects/create/object_create_view.dart';
import '../../modules/objects/create/object_create_binding.dart';
import '../../modules/objects/edit/object_edit_view.dart';
import '../../modules/objects/edit/object_edit_binding.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.objects,
      page: () => const ObjectsView(),
      binding: ObjectsBinding(),
    ),
    GetPage(
      name: AppRoutes.objectDetail,
      page: () => const ObjectDetailView(),
      binding: ObjectDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.objectCreate,
      page: () => const ObjectCreateView(),
      binding: ObjectCreateBinding(),
    ),
    GetPage(
      name: AppRoutes.objectEdit,
      page: () => const ObjectEditView(),
      binding: ObjectEditBinding(),
    ),
  ];
}
