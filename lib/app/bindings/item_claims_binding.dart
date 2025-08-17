import 'package:get/get.dart';
import 'package:treasurehunt/app/controllers/item_claims_controller.dart';

class ItemClaimsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ItemClaimsController>(() => ItemClaimsController());
  }
}
