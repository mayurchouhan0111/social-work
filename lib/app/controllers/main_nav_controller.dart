import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class MainNavController extends GetxController {
  var currentIndex = 0.obs;
  var isAdmin = false.obs;

  // Fixed admin email
  final String adminEmail = "mayurchouhan8055@gmail.com";

  @override
  void onInit() {
    super.onInit();
    print('MainNavController initialized');

    // Check immediately first, then setup listener
    checkAdminStatus();

    // Setup auth listener after a small delay
    Future.delayed(const Duration(milliseconds: 200), () {
      listenToAuthChanges();
    });
  }

  void checkAdminStatus() {
    try {
      print('Checking admin status...');
      // Check if AuthController is registered first
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        final currentUserEmail = authController.userEmail;

        print('Current user email: $currentUserEmail');
        print('Admin email: $adminEmail');

        isAdmin.value = currentUserEmail == adminEmail;
        print('Admin status set to: ${isAdmin.value}');
      } else {
        print('AuthController not registered yet');
        isAdmin.value = false;
      }
    } catch (e) {
      print('Error checking admin status: $e');
      isAdmin.value = false;
    }
  }

  void changeTab(int index) {
    print('=== Tab Change Request ===');
    print('Requested index: $index');
    print('Current index: ${currentIndex.value}');
    print('Is admin: ${isAdmin.value}');

    // Validate index range
    final maxIndex = isAdmin.value ? 3 : 2;
    print('Max allowed index: $maxIndex');

    if (index >= 0 && index <= maxIndex) {
      print('Setting currentIndex to: $index');
      currentIndex.value = index;
      print('Current index after setting: ${currentIndex.value}');
    } else {
      print('Invalid tab index: $index, max allowed: $maxIndex');
      // Force to home if invalid
      currentIndex.value = 0;
    }
    print('=== End Tab Change ===');
  }

  // Admin-specific navigation
  void navigateToAdmin() {
    print('Navigate to admin called, isAdmin: ${isAdmin.value}');
    if (isAdmin.value) {
      changeTab(3); // Use changeTab method for consistency
    } else {
      print('User is not admin, cannot navigate to admin panel');
    }
  }

  // Refresh admin status (call this after login)
  void refreshAdminStatus() {
    print('=== Refreshing Admin Status ===');
    checkAdminStatus();

    // Reset to valid tab if current tab becomes invalid
    final maxIndex = isAdmin.value ? 3 : 2;
    if (currentIndex.value > maxIndex) {
      print('Current tab invalid, resetting to home');
      currentIndex.value = 0;
    }
    print('=== Admin Status Refreshed ===');
  }

  // Reset to home when logging out
  void resetToHome() {
    print('=== Resetting to Home ===');
    currentIndex.value = 0;
    isAdmin.value = false;
    print('Reset complete - Index: ${currentIndex.value}, Admin: ${isAdmin.value}');
  }

  // Listen to auth state changes
  void listenToAuthChanges() {
    try {
      print('Setting up auth state listener...');
      final authController = Get.find<AuthController>();

      // Listen to authentication status changes
      ever(authController.isAuthenticated, (bool authenticated) {
        print('Auth state changed - Authenticated: $authenticated');
        if (authenticated) {
          // Small delay to ensure user data is loaded
          Future.delayed(const Duration(milliseconds: 300), () {
            checkAdminStatus();
          });
        } else {
          resetToHome();
        }
      });

      print('Auth listener setup complete');
    } catch (e) {
      print('Error setting up auth listener: $e');
    }
  }

  // Force refresh everything (for debugging)
  void forceRefresh() {
    print('=== Force Refresh ===');
    checkAdminStatus();
    currentIndex.refresh();
    isAdmin.refresh();
    print('Force refresh complete');
  }
}
