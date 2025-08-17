import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:treasurehunt/app/controllers/auth_controller.dart';
import 'package:treasurehunt/app/models/chat_model.dart';
import 'package:treasurehunt/app/services/firebase_service.dart';

class ChatController extends GetxController {
  final String chatId = Get.arguments as String;
  final FirebaseService _firebaseService = Get.find();
  final AuthController _authController = Get.find();

  var messages = <ChatModel>[].obs;
  final TextEditingController messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
  }

  void fetchMessages() {
    _firebaseService.getChatMessages(chatId).listen((snapshot) {
      messages.value = snapshot.docs.map((doc) => ChatModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  void sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    final senderId = _authController.user.value?.id;
    if (senderId == null) return;

    final chatDoc = await _firebaseService.getChat(chatId);
    final users = List<String>.from(chatDoc.get('users') as List);
    final receiverId = users.firstWhere((id) => id != senderId);

    final message = ChatModel(
      id: '', // Firestore will generate this
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      message: messageText,
      timestamp: DateTime.now(),
    );

    _firebaseService.sendMessage(chatId, message);
    messageController.clear();
  }

  void markAsSolved() async {
    final userId = _authController.user.value?.id;
    if (userId == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Mark as Solved?'),
        content: const Text('Are you sure you want to mark this issue as solved? This will close the chat.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              print('Marking as solved by user: $userId');
              await _firebaseService.updateSettlementStatus(chatId, userId, 'confirmed');
              print('Settlement status updated.');

              final chatDoc = await _firebaseService.getChat(chatId);
              if (!chatDoc.exists) {
                print('Chat document does not exist anymore.');
                return;
              }

              final settlementStatus = chatDoc.get('settlementStatus') as Map<String, dynamic>;
              print('Current settlement status: $settlementStatus');

              final allConfirmed = settlementStatus.values.every((status) => status == 'confirmed');
              print('All confirmed: $allConfirmed');

              if (allConfirmed) {
                print('Deleting chat...');
                await _firebaseService.deleteChat(chatId);
                Get.back(); // Go back from chat screen
                Get.snackbar('Chat Closed', 'The chat has been closed and deleted.');
                print('Chat deleted.');
              } else {
                print('Not all users have confirmed yet.');
                Get.snackbar('Status Updated', 'You have marked the issue as solved. The chat will be closed once all participants have done the same.');
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  bool isCurrentUserMessage(ChatModel message) {
    return message.senderId == _authController.user.value?.id;
  }
}
