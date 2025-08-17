import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:treasurehunt/app/models/user_model.dart';
import 'package:treasurehunt/app/services/auth_service.dart';
import '../services/firebase_service.dart';

class AdminController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final AuthService _authService = AuthService();

  var isLoading = false.obs;
  var pendingPosts = <DocumentSnapshot>[].obs;
  var allPosts = <DocumentSnapshot>[].obs;
  var unverifiedUsers = <UserModel>[].obs;
  var verifiedUsers = <UserModel>[].obs;
  var pendingCount = 0.obs;
  var unverifiedUsersCount = 0.obs;
  var verifiedUsersCount = 0.obs;
  var selectedTab = 0.obs; // 0: Pending Posts, 1: All Posts, 2: Unverified Users, 3: Verified Users

  @override
  void onInit() {
    super.onInit();
    print('AdminController initialized');
    loadPendingPosts();
    loadAllPosts();
    loadUnverifiedUsers();
    loadVerifiedUsers();
  }

  void loadUnverifiedUsers() async {
    print('Loading unverified users...');
    try {
      final users = await _authService.getUnverifiedUsers();
      unverifiedUsers.value = users;
      unverifiedUsersCount.value = users.length;
      print('Unverified users loaded: ${users.length}');
    } catch (e) {
      print('Exception in loadUnverifiedUsers: $e');
    }
  }

  void loadVerifiedUsers() async {
    print('Loading verified users...');
    try {
      final users = await _authService.getVerifiedUsers();
      verifiedUsers.value = users;
      verifiedUsersCount.value = users.length;
      print('Verified users loaded: ${users.length}');
    } catch (e) {
      print('Exception in loadVerifiedUsers: $e');
    }
  }

  Future<void> approveUser(String userId) async {
    print('Approving user: $userId');
    isLoading.value = true;
    try {
      final result = await _authService.verifyUser(userId, true);
      if (result) {
        Get.snackbar(
          'Success',
          'User approved successfully',
          backgroundColor: const Color(0xFF1A1A1A),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );
        loadUnverifiedUsers(); // Refresh the list
        loadVerifiedUsers();
      } else {
        Get.snackbar(
          'Error',
          'Failed to approve user',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error approving user: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unverifyUser(String userId) async {
    print('Unverifying user: $userId');
    isLoading.value = true;
    try {
      final result = await _authService.verifyUser(userId, false);
      if (result) {
        Get.snackbar(
          'Success',
          'User un-verified successfully',
          backgroundColor: const Color(0xFF1A1A1A),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );
        loadUnverifiedUsers();
        loadVerifiedUsers(); // Refresh the list
      } else {
        Get.snackbar(
          'Error',
          'Failed to un-verify user',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error un-verifying user: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectUser(String userId) async {
    print('Rejecting user: $userId');
    // NOTE: Implement user deletion or rejection logic in AuthService
    // For now, we'll just show a message.
    Get.snackbar(
      'Info',
      'User rejection functionality to be implemented.',
      backgroundColor: Colors.amber,
      colorText: Colors.black,
    );
  }

  void loadPendingPosts() {
    print('Loading pending posts...');
    try {
      _firebaseService.getPendingPosts().listen((snapshot) {
        print('Pending posts snapshot received: ${snapshot.docs.length} documents');
        pendingPosts.value = snapshot.docs;
        pendingCount.value = snapshot.docs.length;

        // Debug: Print first document if available
        if (snapshot.docs.isNotEmpty) {
          print('First pending post data: ${snapshot.docs.first.data()}');
        }
      }, onError: (error) {
        print('Error loading pending posts: $error');
      });
    } catch (e) {
      print('Exception in loadPendingPosts: $e');
    }
  }

  void loadAllPosts() {
    print('Loading all posts...');
    try {
      // Load both lost and found items
      _firebaseService.getAllLostItems().listen((lostSnapshot) {
        _firebaseService.getAllFoundItems().listen((foundSnapshot) {
          // Combine both collections
          List<DocumentSnapshot> combinedPosts = [];
          combinedPosts.addAll(lostSnapshot.docs);
          combinedPosts.addAll(foundSnapshot.docs);

          // Sort by timestamp
          combinedPosts.sort((a, b) {
            var aData = a.data() as Map<String, dynamic>;
            var bData = b.data() as Map<String, dynamic>;

            Timestamp aTime = aData['submittedAt'] ?? aData['createdAt'] ?? Timestamp.now();
            Timestamp bTime = bData['submittedAt'] ?? bData['createdAt'] ?? Timestamp.now();

            return bTime.compareTo(aTime); // Descending order
          });

          print('All posts loaded: ${combinedPosts.length} documents');
          allPosts.value = combinedPosts;

          // Debug: Print first document if available
          if (combinedPosts.isNotEmpty) {
            print('First all post data: ${combinedPosts.first.data()}');
          }
        }, onError: (error) {
          print('Error loading found items: $error');
        });
      }, onError: (error) {
        print('Error loading lost items: $error');
      });
    } catch (e) {
      print('Exception in loadAllPosts: $e');
    }
  }

  void changeTab(int index) {
    print('Changing admin tab to: $index');
    selectedTab.value = index;
  }

  Future<void> approvePost(String postId) async {
    print('Approving post: $postId');
    isLoading.value = true;
    try {
      final result = await _firebaseService.approvePost(postId);
      if (result) {
        Get.snackbar(
          'Success',
          'Post approved successfully',
          backgroundColor: const Color(0xFF1A1A1A),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to approve post',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error approving post: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectPost(String postId, String reason) async {
    print('Rejecting post: $postId with reason: $reason');
    isLoading.value = true;
    try {
      final result = await _firebaseService.rejectPost(postId, reason);
      if (result) {
        Get.snackbar(
          'Post Rejected',
          'The post has been rejected',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.cancel, color: Colors.white),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to reject post',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error rejecting post: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePost(String postId, String postTitle) async {
    print('Deleting post: $postId ($postTitle)');
    isLoading.value = true;
    try {
      final result = await _firebaseService.deletePost(postId);
      if (result) {
        Get.snackbar(
          'Post Deleted',
          'Post "$postTitle" has been permanently deleted',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.delete_forever, color: Colors.white),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete post',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error deleting post: $e');
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showDeleteDialog(String postId, String postTitle) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delete_forever,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                "Delete Post",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to permanently delete "$postTitle"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        deletePost(postId, postTitle);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(
                        "Delete",
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showRejectDialog(String postId) {
    String rejectionReason = '';

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Reject Post",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: GoogleFonts.inter(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Reason for rejection (optional)",
                  hintStyle: GoogleFonts.inter(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
                onChanged: (value) => rejectionReason = value,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        rejectPost(postId, rejectionReason);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(
                        "Reject",
                        style: GoogleFonts.inter(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Force refresh for debugging
  void forceRefresh() {
    print('=== Force Refresh Admin Data ===');
    loadPendingPosts();
    loadAllPosts();
    loadUnverifiedUsers();
    print('Force refresh complete');
  }
}