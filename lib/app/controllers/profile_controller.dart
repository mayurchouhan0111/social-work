// lib/controllers/profile_controller.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:treasurehunt/app/services/firebase_service.dart';
import '../models/item_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class ProfileController extends GetxController{
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = Get.find();

  // User profile data
  var userProfile = Rxn<UserModel>();
  var isLoading = false.obs;
  var isUpdating = false.obs;

  // User's posts
  var lostItems = <ItemModel>[].obs;
  var foundItems = <ItemModel>[].obs;

  // Computed properties for easy access
  String get name => userProfile.value?.name ?? '';
  String get email => userProfile.value?.email ?? '';
  String get mobileNumber => userProfile.value?.mobileNumber ?? '';
  String get enrollmentNumber => userProfile.value?.enrollmentNumber ?? '';
  String get identityCardImageUrl => userProfile.value?.identityCardImageUrl ?? '';
  bool get isVerified => userProfile.value?.isVerified ?? false;
  String get userId => userProfile.value?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchUserPosts();
  }

  // Fetch user profile from Supabase
  Future<void> fetchProfile() async {
    if (!_authService.isAuthenticated) {
      Get.snackbar('Error', 'User not authenticated');
      return;
    }

    try {
      isLoading.value = true;
      final userId = _authService.currentUser?.id;

      if (userId != null) {
        final profile = await _authService.getUserProfile(userId);
        if (profile != null) {
          userProfile.value = profile;
        } else {
          Get.snackbar('Error', 'Profile not found');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
      print('Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch user's posts
  void fetchUserPosts() {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;

    _firebaseService.getUserLostItems(userId).listen((snapshot) {
      lostItems.value = snapshot.docs.map((doc) => ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });

    _firebaseService.getUserFoundItems(userId).listen((snapshot) {
      foundItems.value = snapshot.docs.map((doc) => ItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  }

  // Update user profile
  Future<void> updateProfile({
    String? newName,
    String? newMobileNumber,
    String? newEnrollmentNumber,
    String? newIdentityCardImageUrl,
  }) async {
    if (userProfile.value == null) {
      Get.snackbar('Error', 'No profile data available');
      return;
    }

    try {
      isUpdating.value = true;

      // Create updated profile
      final updatedProfile = userProfile.value!.copyWith(
        name: newName,
        mobileNumber: newMobileNumber,
        enrollmentNumber: newEnrollmentNumber,
        identityCardImageUrl: newIdentityCardImageUrl,
        updatedAt: DateTime.now(),
      );

      // Update in Supabase
      final success = await _authService.updateUserProfile(updatedProfile);

      if (success) {
        userProfile.value = updatedProfile;
        Get.snackbar('Success', 'Profile updated successfully!');
      } else {
        Get.snackbar('Error', 'Failed to update profile');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
      print('Error updating profile: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await fetchProfile();
  }

  // Check if user has complete profile
  bool get hasCompleteProfile {
    final profile = userProfile.value;
    return profile != null &&
        profile.name != null && profile.name!.isNotEmpty &&
        profile.mobileNumber != null && profile.mobileNumber!.isNotEmpty &&
        profile.enrollmentNumber != null && profile.enrollmentNumber!.isNotEmpty &&
        profile.identityCardImageUrl != null && profile.identityCardImageUrl!.isNotEmpty;
  }

  // Format display values
  String get displayName => name.isEmpty ? 'Not set' : name;
  String get displayEmail => email.isEmpty ? 'Not set' : email;
  String get displayMobileNumber => mobileNumber.isEmpty ? 'Not set' : mobileNumber;
  String get displayEnrollmentNumber => enrollmentNumber.isEmpty ? 'Not set' : enrollmentNumber;

  String get verificationStatus => isVerified ? 'Verified' : 'Pending Verification';
  Color get verificationStatusColor => isVerified ? Colors.green : Colors.orange;
}
