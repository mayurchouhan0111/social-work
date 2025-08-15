import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../services/firebase_service.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure FirebaseService is initialized
    if (!Get.isRegistered<FirebaseService>()) {
      Get.put(FirebaseService(), permanent: true);
    }

    // Initialize AdminController
    Get.lazyPut<AdminController>(() => AdminController());
  }
}
