import 'package:get/get.dart';
import 'package:treasurehunt/app/controllers/my_chats_controller.dart';

class MyChatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyChatsController>(() => MyChatsController());
  }
}
