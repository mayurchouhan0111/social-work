import 'package:get/get.dart';
import 'package:treasurehunt/app/controllers/auth_controller.dart';
import 'package:treasurehunt/app/models/claim_model.dart';
import 'package:treasurehunt/app/models/item_model.dart';
import 'package:treasurehunt/app/services/firebase_service.dart';

class ClaimController extends GetxController {
  final ItemModel item = Get.arguments as ItemModel;
  late List<String> answers;
  final AuthController _authController = Get.find();
  final FirebaseService _firebaseService = Get.find();

  @override
  void onInit() {
    super.onInit();
    answers = List<String>.filled(item.questions?.length ?? 0, '');
  }

  void updateAnswer(int index, String answer) {
    answers[index] = answer;
  }

  void submitClaim() async {
    final claimerId = _authController.user.value?.id;
    if (claimerId == null) {
      Get.snackbar('Error', 'You must be logged in to submit a claim.');
      return;
    }

    final claim = ClaimModel(
      id: '', // Firestore will generate this
      itemId: item.id,
      claimerId: claimerId,
      posterId: item.reportedBy,
      answers: answers,
      status: 'pending',
      createdAt: DateTime.now(),
    );

    final success = await _firebaseService.createClaim(claim);

    if (success) {
      Get.back();
      Get.snackbar('Success', 'Your claim has been submitted.');
    } else {
      Get.snackbar('Error', 'Failed to submit your claim. Please try again.');
    }
  }
}
