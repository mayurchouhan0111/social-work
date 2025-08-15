import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/item_model.dart';
import 'firebase_service.dart';

class LostItemService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  // Submit lost item for admin approval instead of direct posting
  Future<void> postLostItem(ItemModel item) async {
    try {
      // Convert ItemModel to Map and ensure it has the status and admin fields
      Map<String, dynamic> itemData = item.copyWith(
        status: 'lost',
        moderationStatus: 'pending',
        isConfirmedByAdmin: false,
        submittedAt: DateTime.now(),
      ).toMap();

      print('Submitting lost item for admin approval: ${item.title}');

      // Submit through FirebaseService for admin approval
      bool success = await _firebaseService.submitPostForApproval(itemData);

      if (!success) {
        throw Exception('Failed to submit item for approval');
      }

      print('Lost item submitted successfully for admin approval');
    } catch (e) {
      print("Error posting lost item: $e");
      rethrow;
    }
  }

  // Get only approved lost items for public viewing
  Stream<List<ItemModel>> getLostItems() {
    print('Getting approved lost items...');
    return _firestore
        .collection('lost_items')
        .where('moderationStatus', isEqualTo: 'approved')
        .where('isConfirmedByAdmin', isEqualTo: true)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Approved lost items received: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get all lost items (for admin view)
  Stream<List<ItemModel>> getAllLostItems() {
    return _firestore
        .collection('lost_items')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get user's lost items (all statuses for the user who posted)
  Stream<List<ItemModel>> getUserLostItems(String userId) {
    return _firestore
        .collection('lost_items')
        .where('reportedBy', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Search approved lost items
  Stream<List<ItemModel>> searchLostItems(String searchTerm) {
    return _firestore
        .collection('lost_items')
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

  // Get lost items by tag (approved only)
  Stream<List<ItemModel>> getLostItemsByTag(String tag) {
    return _firestore
        .collection('lost_items')
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
