import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/main_nav_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/post_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/admin_controller.dart';
import '../services/firebase_service.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize Firebase Service first (for admin functionality)
    if (!Get.isRegistered<FirebaseService>()) {
      Get.put<FirebaseService>(FirebaseService(), permanent: true);
    }

    // Ensure AuthController is available
    Get.put<AuthController>(AuthController());

    // Bottom nav controller
    Get.lazyPut<MainNavController>(() => MainNavController());

    // Tab controllers
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<PostController>(() => PostController());
    Get.lazyPut<ProfileController>(() => ProfileController());

    // Admin controller (conditional initialization)
    Get.lazyPut<AdminController>(() => AdminController());
  }
}
