import 'package:get/get.dart';
import 'package:treasurehunt/app/models/item_model.dart';
import 'package:treasurehunt/app/services/firebase_service.dart';

class HomeController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  var isLoading = true.obs;
  var combinedItems = <ItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAndCombineItems();
  }

  void fetchAndCombineItems() {
    isLoading.value = true;
    List<ItemModel> lostItems = [];
    List<ItemModel> foundItems = [];

    _firebaseService.getApprovedLostItems().listen((snapshot) {
      lostItems = snapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    _combineAndSort(lostItems, foundItems);
    }).onError((error) {
      print("Error fetching lost items: $error");
      isLoading.value = false;
    });

    _firebaseService.getApprovedFoundItems().listen((snapshot) {
      foundItems = snapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      _combineAndSort(lostItems, foundItems);
    }).onError((error) {
      print("Error fetching found items: $error");
      isLoading.value = false;
    });
  }

  void _combineAndSort(List<ItemModel> lost, List<ItemModel> found) {
    final combined = [...lost, ...found];
    combined.sort((a, b) {
      if (a.submittedAt == null && b.submittedAt == null) return 0;
      if (a.submittedAt == null) return 1;
      if (b.submittedAt == null) return -1;
      return b.submittedAt!.compareTo(a.submittedAt!);
    });
    combinedItems.assignAll(combined);
    isLoading.value = false;
  }
}