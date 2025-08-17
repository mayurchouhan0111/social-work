import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:treasurehunt/app/controllers/auth_controller.dart';
import 'package:treasurehunt/app/services/firebase_service.dart';

class MyChatsController extends GetxController {
  final FirebaseService _firebaseService = Get.find();
  final AuthController authController = Get.find();

  var chats = <DocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchChats();
  }

  void fetchChats() {
    final userId = authController.user.value?.id;
    print('Fetching chats for user ID: $userId');
    if (userId == null) {
      print('User ID is null, cannot fetch chats.');
      return;
    }

    print('Calling getUserChats from FirebaseService...');
    _firebaseService.getUserChats(userId).listen((snapshot) {
      print('Received ${snapshot.docs.length} chat documents.');
      chats.value = snapshot.docs;
    });
  }

  // Add logic to navigate to chat page
  void openChat(String chatId) {
    // Get.toNamed(Routes.chat, arguments: chatId);
  }
}
