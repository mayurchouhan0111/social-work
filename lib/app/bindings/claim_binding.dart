import 'package:get/get.dart';
import 'package:treasurehunt/app/controllers/claim_controller.dart';

class ClaimBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClaimController>(() => ClaimController());
  }
}
