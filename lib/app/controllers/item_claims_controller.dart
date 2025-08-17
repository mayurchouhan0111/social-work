import 'package:get/get.dart';
import 'package:treasurehunt/app/models/claim_model.dart';
import 'package:treasurehunt/app/models/item_model.dart';
import 'package:treasurehunt/app/routes/app_routes.dart';
import 'package:treasurehunt/app/services/firebase_service.dart';

class ItemClaimsController extends GetxController {
  final ItemModel item = Get.arguments as ItemModel;
  final FirebaseService _firebaseService = Get.find();

  var claims = <ClaimModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchClaims();
  }

  void fetchClaims() {
    _firebaseService.getItemClaims(item.id).listen((snapshot) {
      claims.value = snapshot.docs.map((doc) => ClaimModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  void approveClaim(ClaimModel claim) async {
    final success = await _firebaseService.updateClaimStatus(claim.id, 'approved');
    if (success) {
      print('Attempting to create/get chat for poster: ${claim.posterId} and claimer: ${claim.claimerId}');

      final chatId = await _firebaseService.createChat(claim.posterId, claim.claimerId);
      print('Chat ID returned: $chatId');
      if (chatId != null) {
        print('Navigating to chat with ID: $chatId');
        Get.toNamed(Routes.chat, arguments: chatId);
      } else {
        print('Chat ID is null, not navigating to chat.');
      }
    }
  }

  void rejectClaim(ClaimModel claim) async {
    await _firebaseService.updateClaimStatus(claim.id, 'rejected');
  }
}
