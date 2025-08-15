// lib/controllers/auth_controller.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../routes/app_pages.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final cloudinary = CloudinaryPublic('dbxdfhe6c', 'losthunt', cache: false);

  // Auth state
  var user = Rxn<User>();
  var userProfile = Rxn<UserModel>();
  var isLoading = false.obs;
  var isAuthenticated = false.obs;

  // Sign up form fields
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;
  var name = ''.obs;
  var mobileNumber = ''.obs;
  var enrollmentNumber = ''.obs;
  var identityCardImageUrl = ''.obs;

  // Identity card upload state
  var isUploadingIdentityCard = false.obs;

  // Identity card image
  final selectedIdentityCard = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  void _initializeAuth() {
    // Set initial auth state
    user.value = _authService.currentUser;
    isAuthenticated.value = _authService.isAuthenticated;

    // Listen to Supabase auth state changes
    _authService.listenToAuthChanges((AuthState data) async {
      final session = data.session;
      user.value = session?.user;
      isAuthenticated.value = session != null;

      if (session != null) {
        // Load user profile
        await loadUserProfile(session.user.id);
        Get.offAllNamed(Routes.mainNav);
      } else {
        userProfile.value = null;
        Get.offAllNamed(Routes.signIn);
      }
    });
  }

  // Load user profile
  Future<void> loadUserProfile(String userId) async {
    try {
      final profile = await _authService.getUserProfile(userId);
      userProfile.value = profile;
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Pick identity card image
  Future<void> pickIdentityCardImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        selectedIdentityCard.value = File(pickedFile.path);
        await _uploadIdentityCardToCloudinary();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick identity card image: $e');
    }
  }

  // Upload identity card to Cloudinary
  Future<void> _uploadIdentityCardToCloudinary() async {
    if (selectedIdentityCard.value == null) return;

    isUploadingIdentityCard.value = true;
    try {
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String publicId = 'user_verification/identity_cards/$timestamp';

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          selectedIdentityCard.value!.path,
          publicId: publicId,
          folder: 'user_verification/identity_cards',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      identityCardImageUrl.value = response.secureUrl;
      Get.snackbar('Success', 'Identity card uploaded successfully!',
          duration: const Duration(seconds: 2));
    } on CloudinaryException catch (e) {
      Get.snackbar('Upload Error', 'Failed to upload identity card: ${e.message}');
      identityCardImageUrl.value = '';
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload identity card. Please try again.');
      identityCardImageUrl.value = '';
    } finally {
      isUploadingIdentityCard.value = false;
    }
  }

  // Validation methods
  bool isValidMobileNumber(String number) {
    String cleanNumber = number.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.length == 10) return true;
    if (cleanNumber.length == 12 && cleanNumber.startsWith('91')) return true;
    return false;
  }

  bool isValidEnrollmentNumber(String enrollmentNo) {
    if (enrollmentNo.isEmpty || enrollmentNo.length < 6) return false;
    RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
    return alphanumeric.hasMatch(enrollmentNo);
  }

  // Sign Up
  Future<void> signUp(String emailText, String passwordText) async {
    if (emailText.isEmpty || passwordText.isEmpty || name.value.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields');
      return;
    }

    if (!GetUtils.isEmail(emailText)) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }

    if (passwordText.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }

    if (passwordText != confirmPassword.value) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    if (mobileNumber.value.isEmpty || !isValidMobileNumber(mobileNumber.value)) {
      Get.snackbar('Error', 'Please enter a valid mobile number');
      return;
    }

    if (enrollmentNumber.value.isEmpty || !isValidEnrollmentNumber(enrollmentNumber.value)) {
      Get.snackbar('Error', 'Please enter a valid enrollment number (minimum 6 characters)');
      return;
    }

    if (identityCardImageUrl.value.isEmpty) {
      Get.snackbar('Error', 'Please upload your identity card for verification');
      return;
    }

    if (isUploadingIdentityCard.value) {
      Get.snackbar('Please wait', 'Identity card is still uploading...');
      return;
    }

    try {
      isLoading.value = true;
      final success = await _authService.signUpWithProfile(
        email: emailText,
        password: passwordText,
        name: name.value,
        mobileNumber: mobileNumber.value,
        enrollmentNumber: enrollmentNumber.value,
        identityCardImageUrl: identityCardImageUrl.value,
      );

      if (success) {
        _clearSignUpForm();
        Get.snackbar('Success', 'Account created! Please check your email for verification.');
        Get.offAllNamed(Routes.signIn);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create account: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _clearSignUpForm() {
    email.value = '';
    password.value = '';
    confirmPassword.value = '';
    name.value = '';
    mobileNumber.value = '';
    enrollmentNumber.value = '';
    identityCardImageUrl.value = '';
    selectedIdentityCard.value = null;
  }

  // Sign In
  Future<void> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }

    try {
      isLoading.value = true;
      final success = await _authService.signInWithEmail(email, password);
      if (!success) {
        Get.snackbar('Failed', 'Unable to login. Please check your credentials.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      Get.snackbar('Error', 'Please enter your email address');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }

    try {
      isLoading.value = true;
      await _authService.resetPassword(email);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send reset email: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Sign Out (Updated)
  Future<void> signOut() async {
    try {
      isLoading.value = true;

      // Call Supabase sign out
      await _authService.signOut();

      // Clear local state immediately
      user.value = null;
      userProfile.value = null;
      isAuthenticated.value = false;

      // Navigate to sign-in & clear navigation history
      Get.offAllNamed(Routes.signIn);

      // Show confirmation
      Get.snackbar(
        'Signed Out',
        'You have been signed out successfully',
        backgroundColor: const Color(0xFF1A1A1A),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool get isUserAuthenticated => isAuthenticated.value;
  String? get userId => user.value?.id;
  String? get userEmail => user.value?.email;
}
