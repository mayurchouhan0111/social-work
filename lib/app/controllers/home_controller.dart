import 'package:get/get.dart';
import 'package:treasurehunt/app/models/item_model.dart';
import 'package:treasurehunt/app/services/firebase_service.dart';
import 'package:treasurehunt/app/ui/widgets/filter_enums.dart'; // Import SortOption

class HomeController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  var isLoading = true.obs;
  var combinedItems = <ItemModel>[].obs;

  // Reactive variables for filtering and searching
  var searchTerm = ''.obs;
  var selectedStatusFilter = 'all'.obs; // 'all', 'lost', 'found'
  var selectedTagFilter = 'all'.obs; // 'all' or specific tag
  var selectedSortOption = SortOption.newest.obs;

  // Computed list of items after applying filters and search
  RxList<ItemModel> get filteredItems => _applyFiltersAndSearch().obs;

  @override
  void onInit() {
    super.onInit();
    fetchAndCombineItems();

    // Listen for changes in filter/search parameters and re-apply
    ever(searchTerm, (_) => filteredItems.refresh());
    ever(selectedStatusFilter, (_) => filteredItems.refresh());
    ever(selectedTagFilter, (_) => filteredItems.refresh());
    ever(selectedSortOption, (_) => filteredItems.refresh());
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
      if (a.submittedAt == null) return 1; // Nulls last
      if (b.submittedAt == null) return -1; // Nulls last
      return b.submittedAt!.compareTo(a.submittedAt!); // Newest first by default
    });
    combinedItems.assignAll(combined);
    isLoading.value = false;
    // No need to call filteredItems.refresh() here, as it's a computed property
    // and will react to changes in combinedItems automatically.
  }

  List<ItemModel> _applyFiltersAndSearch() {
    List<ItemModel> items = List<ItemModel>.from(combinedItems);

    // Apply Search Term
    if (searchTerm.value.isNotEmpty) {
      final query = searchTerm.value.toLowerCase();
      items = items.where((item) {
        return item.title.toLowerCase().contains(query) ||
               item.description.toLowerCase().contains(query) ||
               item.location.toLowerCase().contains(query);
      }).toList();
    }

    // Apply Status Filter
    if (selectedStatusFilter.value != 'all') {
      items = items.where((item) => item.status == selectedStatusFilter.value).toList();
    }

    // Apply Tag Filter (assuming ItemModel has a 'tag' field, or it's in metadata)
    // For now, let's assume 'tag' is directly accessible or can be added to ItemModel
    // If 'tag' is not directly in ItemModel, you'd need to adjust ItemModel.fromMap
    // or access it via metadata if it's stored there.
    // For this example, I'll assume ItemModel has a 'tag' property.
    // If not, you'd need to add `final String? tag;` to ItemModel and update its fromMap/toMap.
    if (selectedTagFilter.value != 'all') {
      items = items.where((item) => (item.metadata?['tag'] ?? 'N/A') == selectedTagFilter.value).toList();
    }


    // Apply Sorting
    switch (selectedSortOption.value) {
      case SortOption.newest:
        items.sort((a, b) => (b.submittedAt ?? DateTime(0)).compareTo(a.submittedAt ?? DateTime(0)));
        break;
      case SortOption.oldest:
        items.sort((a, b) => (a.submittedAt ?? DateTime(0)).compareTo(b.submittedAt ?? DateTime(0)));
        break;
      case SortOption.alphabetical:
        items.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.location:
        items.sort((a, b) => a.location.toLowerCase().compareTo(b.location.toLowerCase()));
        break;
      default:
        // Default to newest if no specific sort option
        items.sort((a, b) => (b.submittedAt ?? DateTime(0)).compareTo(a.submittedAt ?? DateTime(0)));
        break;
    }

    return items;
  }

  // Helper to set search term
  void setSearchTerm(String value) {
    searchTerm.value = value;
  }

  // Helper to set status filter
  void setStatusFilter(String value) {
    selectedStatusFilter.value = value;
  }

  // Helper to set tag filter
  void setTagFilter(String value) {
    selectedTagFilter.value = value;
  }

  // Helper to set sort option
  void setSortOption(SortOption value) {
    selectedSortOption.value = value;
  }
}
