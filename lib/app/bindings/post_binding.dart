import 'package:get/get.dart';
import 'package:treasurehunt/app/controllers/auth_controller.dart';
import '../controllers/post_controller.dart';

class PostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostController>(() => PostController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
