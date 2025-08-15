import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/item_model.dart';
import 'firebase_service.dart';

class FoundItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  // Submit found item for admin approval instead of direct posting
  Future<void> postFoundItem(ItemModel item) async {
    try {
      // Start with a map from the ItemModel
      Map<String, dynamic> itemData = item.toMap();

      // Override or add the status and admin fields directly to the map
      itemData['status'] = 'found';
      itemData['moderationStatus'] = 'pending';
      itemData['isConfirmedByAdmin'] = false;
      itemData['submittedAt'] = DateTime.now().toIso8601String();

      print('Submitting found item for admin approval: ${item.title}');

      bool success = await _firebaseService.submitPostForApproval(itemData);

      if (!success) {
        throw Exception('Failed to submit item for approval');
      }

      print('Found item submitted successfully for admin approval');
    } catch (e) {
      print("Error posting found item: $e");
      rethrow;
    }
  }

  // Get only approved found items for public viewing
  Stream<List<ItemModel>> getFoundItems() {
    print('Getting approved found items...');
    return _firestore
        .collection('found_items')
        .where('moderationStatus', isEqualTo: 'approved')
        .where('isConfirmedByAdmin', isEqualTo: true)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Approved found items received: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get all found items (for admin view)
  Stream<List<ItemModel>> getAllFoundItems() {
    return _firestore
        .collection('found_items')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get user's found items (all statuses for the user who posted)
  Stream<List<ItemModel>> getUserFoundItems(String userId) {
    return _firestore
        .collection('found_items')
        .where('reportedBy', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Search approved found items
  Stream<List<ItemModel>> searchFoundItems(String searchTerm) {
    return _firestore
        .collection('found_items')
        .where('moderationStatus', isEqualTo: 'approved')
        .where('isConfirmedByAdmin', isEqualTo: true)
        .orderBy('title')
        .startAt([searchTerm])
        .endAt([searchTerm + '\uf8ff'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get found items by tag (approved only)
  Stream<List<ItemModel>> getFoundItemsByTag(String tag) {
    return _firestore
        .collection('found_items')
        .where('moderationStatus', isEqualTo: 'approved')
        .where('isConfirmedByAdmin', isEqualTo: true)
        .where('tag', isEqualTo: tag)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}