// lib/app/services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final cloudinary = CloudinaryPublic('dbxdfhe6c', 'losthunt', cache: false);

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Check if user is authenticated
  bool get isAuthenticated => currentSession != null;

  // ✅ Enhanced Sign up with complete profile
  Future<bool> signUpWithProfile({
    required String email,
    required String password,
    required String name,
    required String mobileNumber,
    required String enrollmentNumber,
    required String identityCardImageUrl,
    String? state,
    String? district,
  }) async {
    try {
      // First create the auth user
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile in the profiles table
        final userProfile = UserModel(
          id: response.user!.id,
          email: email,
          name: name,
          mobileNumber: mobileNumber,
          enrollmentNumber: enrollmentNumber,
          identityCardImageUrl: identityCardImageUrl,
          isVerified: false, // Will be verified by admin later
          createdAt: DateTime.now(),
        );

        // Insert profile into Supabase
        await _supabase.from('profiles').insert(userProfile.toMap());

        // Notify admin for verification
        try {
          final response = await http.post(
            Uri.parse('https://social-work.onrender.com/notify-admin'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'itemId': userProfile.id,
              'collectionType': 'new_user_verification',
              'itemData': userProfile.toMap(),
            }),
          );

          if (response.statusCode == 200) {
            print('Admin notification for new user verification sent successfully.');
          } else {
            print('Failed to send admin notification for new user verification: ${response.body}');
          }
        } catch (e) {
          print('Error sending admin notification for new user verification: $e');
        }

        Get.snackbar('Success', 'Account created successfully! Please verify your email.');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to create account');
        return false;
      }
    } on AuthException catch (error) {
      Get.snackbar('Sign Up Error', error.message);
      return false;
    } catch (error) {
      Get.snackbar('Error', 'Failed to sign up: $error');
      return false;
    }
  }

  // ✅ Basic Sign up with email & password (for backward compatibility)
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        Get.snackbar('Success', 'Account created successfully!');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to create account');
        return false;
      }
    } on AuthException catch (error) {
      Get.snackbar('Sign Up Error', error.message);
      return false;
    } catch (error) {
      Get.snackbar('Error', 'Failed to sign up: $error');
      return false;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromMap(response);
    } catch (error) {
      print('Error getting user profile: $error');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel userModel) async {
    try {
      await _supabase
          .from('profiles')
          .update(userModel.toMap())
          .eq('id', userModel.id);
      return true;
    } catch (error) {
      Get.snackbar('Error', 'Failed to update profile: $error');
      return false;
    }
  }

  // Check if user profile exists
  Future<bool> doesUserProfileExist(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (error) {
      print('Error checking user profile: $error');
      return false;
    }
  }

  // Create user profile (for users who signed up without full profile)
  Future<bool> createUserProfile(UserModel userModel) async {
    try {
      await _supabase.from('profiles').insert(userModel.toMap());
      return true;
    } catch (error) {
      Get.snackbar('Error', 'Failed to create profile: $error');
      return false;
    }
  }

  // Verify user (admin function)
  Future<bool> verifyUser(String userId, bool isVerified) async {
    try {
      await _supabase
          .from('profiles')
          .update({'is_verified': isVerified, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
      return true;
    } catch (error) {
      Get.snackbar('Error', 'Failed to update verification status: $error');
      return false;
    }
  }

  // Get all unverified users (admin function)
  Future<List<UserModel>> getUnverifiedUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('is_verified', false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((user) => UserModel.fromMap(user))
          .toList();
    } catch (error) {
      print('Error getting unverified users: $error');
      return [];
    }
  }

  // Get all verified users (admin function)
  Future<List<UserModel>> getVerifiedUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('is_verified', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((user) => UserModel.fromMap(user))
          .toList();
    } catch (error) {
      print('Error getting verified users: $error');
      return [];
    }
  }

  // Get user by enrollment number (for duplicate check)
  Future<UserModel?> getUserByEnrollmentNumber(String enrollmentNumber) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('enrollment_number', enrollmentNumber)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromMap(response);
      }
      return null;
    } catch (error) {
      print('Error getting user by enrollment number: $error');
      return null;
    }
  }

  // ✅ Sign in with email & password
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null && response.user != null) {
        Get.snackbar('Success', 'Welcome back!');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to sign in');
        return false;
      }
    } on AuthException catch (error) {
      Get.snackbar('Sign In Error', error.message);
      return false;
    } catch (error) {
      Get.snackbar('Error', 'Failed to sign in: $error');
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      Get.snackbar('Error', 'Failed to sign out: $error');
    }
  }

  // Listen to auth state changes
  void listenToAuthChanges(Function(AuthState) callback) {
    _supabase.auth.onAuthStateChange.listen(callback);
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      Get.snackbar('Success', 'Password reset email sent!');
      return true;
    } catch (error) {
      Get.snackbar('Error', 'Failed to send reset email: $error');
      return false;
    }
  }

  // Update password
  Future<bool> updatePassword(String newPassword) async {
    try {
      final UserResponse response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        Get.snackbar('Success', 'Password updated successfully!');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to update password');
        return false;
      }
    } on AuthException catch (error) {
      Get.snackbar('Error', error.message);
      return false;
    } catch (error) {
      Get.snackbar('Error', 'Failed to update password: $error');
      return false;
    }
  }

  // Update email
  Future<bool> updateEmail(String newEmail) async {
    try {
      final UserResponse response = await _supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );

      if (response.user != null) {
        Get.snackbar('Success', 'Email update initiated! Check your new email for confirmation.');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to update email');
        return false;
      }
    } on AuthException catch (error) {
      Get.snackbar('Error', error.message);
      return false;
    } catch (error) {
      Get.snackbar('Error', 'Failed to update email: $error');
      return false;
    }
  }

  // Delete user account
  Future<bool> deleteAccount() async {
    try {
      // First delete the user profile
      if (currentUser != null) {
        await _supabase.from('profiles').delete().eq('id', currentUser!.id);
      }

      // Then delete the auth user (this might require admin privileges)
      // Note: Supabase doesn't allow users to delete their own auth record from client
      // You might need to implement this as an RPC function or handle it server-side

      Get.snackbar('Success', 'Account deletion initiated. Please contact support if needed.');
      return true;
    } catch (error) {
      Get.snackbar('Error', 'Failed to delete account: $error');
      return false;
    }
  }

  // Resend email confirmation
  Future<bool> resendEmailConfirmation(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      Get.snackbar('Success', 'Confirmation email sent!');
      return true;
    } catch (error) {
      Get.snackbar('Error', 'Failed to send confirmation email: $error');
      return false;
    }
  }
}
