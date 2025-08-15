import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FirebaseService extends GetxController {
  static FirebaseService get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Since all notification logic is removed, onInit is now optional unless you add new initialization logic.
  // @override
  // void onInit() {
  //   super.onInit();
  // }

  // Submit post for admin approval (handles both lost and found items)
  Future<bool> submitPostForApproval(Map<String, dynamic> postData) async {
    try {
      // Determine collection based on status
      String collection = postData['status'] == 'lost' ? 'lost_items' : 'found_items';

      // Generate document ID if not provided, or use the existing one if available.
      String docId = (postData['id'] != null && postData['id'].isNotEmpty) ? postData['id'] : _firestore.collection(collection).doc().id;

      print('Submitting post to collection: $collection with ID: $docId');

      // Add to appropriate collection with pending status
      await _firestore.collection(collection).doc(docId).set({
        ...postData,
        'id': docId, // Ensure ID is set
        'moderationStatus': 'pending',
        'isConfirmedByAdmin': false,
        'submittedAt': FieldValue.serverTimestamp(),
        'createdAt': postData['createdAt'] ?? FieldValue.serverTimestamp(),
      });

      // Add to moderation queue with collection info
      await _firestore.collection('moderation_queue').doc(docId).set({
        'postId': docId,
        'collection': collection, // Track which collection this belongs to
        'postData': {
          ...postData,
          'id': docId,
          'moderationStatus': 'pending',
          'isConfirmedByAdmin': false,
          'submittedAt': FieldValue.serverTimestamp(),
        },
        'submittedAt': FieldValue.serverTimestamp(),
        'priority': 'normal',
      });

      print('Post submitted successfully to $collection and moderation_queue');
      return true;
    } catch (e) {
      print('Error submitting post: $e');
      return false;
    }
  }

  // Get pending posts for admin
  Stream<QuerySnapshot> getPendingPosts() {
    print('Setting up pending posts stream...');
    return _firestore
        .collection('moderation_queue')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Approve post
  Future<bool> approvePost(String postId) async {
    try {
      print('Approving post: $postId');

      // Get the post from moderation queue to determine collection
      DocumentSnapshot queueDoc = await _firestore
          .collection('moderation_queue')
          .doc(postId)
          .get();

      if (!queueDoc.exists) {
        print('Post not found in moderation queue');
        return false;
      }

      Map<String, dynamic> queueData = queueDoc.data() as Map<String, dynamic>;
      String collection = queueData['collection'] ?? 'lost_items';

      print('Approving post in collection: $collection');

      // Update the post in appropriate collection with admin confirmation
      await _firestore.collection(collection).doc(postId).update({
        'moderationStatus': 'approved',
        'isConfirmedByAdmin': true,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': 'mayurchouhan8055@gmail.com',
      });

      // Remove from moderation queue
      await _firestore.collection('moderation_queue').doc(postId).delete();

      print('Post approved successfully');
      return true;
    } catch (e) {
      print('Error approving post: $e');
      return false;
    }
  }

  // Reject post
  Future<bool> rejectPost(String postId, String reason) async {
    try {
      print('Rejecting post: $postId');

      // Get the post from moderation queue to determine collection
      DocumentSnapshot queueDoc = await _firestore
          .collection('moderation_queue')
          .doc(postId)
          .get();

      if (!queueDoc.exists) {
        print('Post not found in moderation queue');
        return false;
      }

      Map<String, dynamic> queueData = queueDoc.data() as Map<String, dynamic>;
      String collection = queueData['collection'] ?? 'lost_items';

      // Update the post in appropriate collection
      await _firestore.collection(collection).doc(postId).update({
        'moderationStatus': 'rejected',
        'isConfirmedByAdmin': false,
        'rejectedAt': FieldValue.serverTimestamp(),
        'rejectedBy': 'mayurchouhan8055@gmail.com',
        'rejectionReason': reason,
      });

      // Remove from moderation queue
      await _firestore.collection('moderation_queue').doc(postId).delete();

      print('Post rejected successfully');
      return true;
    } catch (e) {
      print('Error rejecting post: $e');
      return false;
    }
  }

  // Delete post permanently
  Future<bool> deletePost(String postId) async {
    try {
      print('Deleting post: $postId');

      // Get the post from moderation queue to determine collection
      DocumentSnapshot queueDoc = await _firestore
          .collection('moderation_queue')
          .doc(postId)
          .get();

      String collection = 'lost_items'; // Default collection
      if (queueDoc.exists) {
        Map<String, dynamic> queueData = queueDoc.data() as Map<String, dynamic>;
        collection = queueData['collection'] ?? 'lost_items';
      } else {
        // Check both collections to find the post
        DocumentSnapshot lostDoc = await _firestore
            .collection('lost_items')
            .doc(postId)
            .get();

        if (!lostDoc.exists) {
          collection = 'found_items';
        }
      }

      print('Deleting from collection: $collection');

      // Delete from appropriate collection
      await _firestore.collection(collection).doc(postId).delete();

      // Remove from moderation queue if exists
      await _firestore.collection('moderation_queue').doc(postId).delete();

      print('Post deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // Get approved lost items (with double confirmation)
  Stream<QuerySnapshot> getApprovedLostItems() {
    return _firestore
        .collection('lost_items')
        .where('moderationStatus', isEqualTo: 'approved')
        .where('isConfirmedByAdmin', isEqualTo: true)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Get approved found items (with double confirmation)
  Stream<QuerySnapshot> getApprovedFoundItems() {
    return _firestore
        .collection('found_items')
        .where('moderationStatus', isEqualTo: 'approved')
        .where('isConfirmedByAdmin', isEqualTo: true)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Get all lost items for admin
  Stream<QuerySnapshot> getAllLostItems() {
    return _firestore
        .collection('lost_items')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Get all found items for admin
  Stream<QuerySnapshot> getAllFoundItems() {
    return _firestore
        .collection('found_items')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Get user's lost items (all statuses)
  Stream<QuerySnapshot> getUserLostItems(String userId) {
    return _firestore
        .collection('lost_items')
        .where('reportedBy', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Get user's found items (all statuses)
  Stream<QuerySnapshot> getUserFoundItems(String userId) {
    return _firestore
        .collection('found_items')
        .where('reportedBy', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // Search approved lost items
  Stream<QuerySnapshot> searchLostItems(String searchTerm) {
    return _firestore
        .collection('lost_items')
        .where('moderationStatus', isEqualTo: 'approved')
        .where('isConfirmedByAdmin', isEqualTo: true)
        .orderBy('title')
        .startAt([searchTerm])
        .endAt([searchTerm + '\uf8ff'])
        .snapshots();
  }

  // Search approved found items
  Stream<QuerySnapshot> searchFoundItems(String searchTerm) {
    return _firestore
        .collection('found_items')
        .where('moderationStatus', isEqualTo: 'approved')
        .where('isConfirmedByAdmin', isEqualTo: true)
        .orderBy('title')
        .startAt([searchTerm])
        .endAt([searchTerm + '\uf8ff'])
        .snapshots();
  }

  // Get items by tag (approved only)
  Stream<QuerySnapshot> getLostItemsByTag(String tag) {
    return _firestore
        .collection('lost_items')
        .where('moderationStatus', isEqualTo: 'approved')
        .where('isConfirmedByAdmin', isEqualTo: true)
        .where('tag', isEqualTo: tag)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getFoundItemsByTag(String tag) {
    return _firestore
        .collection('found_items')
        .where('moderationStatus', isEqualTo: 'approved')
        .where('isConfirmedByAdmin', isEqualTo: true)
        .where('tag', isEqualTo: tag)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }
}