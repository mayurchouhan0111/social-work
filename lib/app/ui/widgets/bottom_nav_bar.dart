import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../app_theme.dart';
import '../../controllers/main_nav_controller.dart';
import '../../services/firebase_service.dart';
import '../pages/home/home_page.dart';
import '../pages/post/post_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/admin/admin_page.dart';

class MainNavPage extends StatelessWidget {
  const MainNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    final navController = Get.put(MainNavController());

    return Obx(() {
      print('Building MainNavPage - Current Index: ${navController.currentIndex.value}, Is Admin: ${navController.isAdmin.value}');

      final screens = [
        const HomePage(),
        const PostPage(),
        const ProfilePage(),
        if (navController.isAdmin.value) const AdminPage(), // Conditional admin tab
      ];

      print('Available screens: ${screens.length}');

      return LayoutBuilder(
        builder: (context, constraints) {
          // Web/Desktop layout (NavigationRail)
          if (constraints.maxWidth >= 768) {
            return Scaffold(
              backgroundColor: AppTheme.background,
              body: SafeArea(
                child: Row(
                  children: [
                    _buildNavigationRail(navController, context),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Container(
                          key: ValueKey(navController.currentIndex.value),
                          child: _getSafeScreen(screens, navController.currentIndex.value),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          // Mobile layout (BottomNavigationBar)
          else {
            return Scaffold(
              backgroundColor: AppTheme.background,
              body: SafeArea(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Container(
                    key: ValueKey(navController.currentIndex.value),
                    child: _getSafeScreen(screens, navController.currentIndex.value),
                  ),
                ),
              ),
              bottomNavigationBar: _buildMinimalistBottomNav(navController),
            );
          }
        },
      );
    });
  }

  // Safe screen getter to prevent index out of bounds
  Widget _getSafeScreen(List<Widget> screens, int index) {
    if (index >= 0 && index < screens.length) {
      print('Displaying screen at index: $index');
      return screens[index];
    } else {
      print('Invalid screen index $index, showing home');
      return screens[0]; // Fallback to home
    }
  }

  Widget _buildNavigationRail(MainNavController navController, BuildContext context) {
    return Obx(() => Container(
      width: 280,
      color: AppTheme.surface,
      child: Column(
        children: [
          // Logo/Header section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.accent2, AppTheme.accent1],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.compass,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Treasure Hunt',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildRailNavItem(
                  index: 0,
                  icon: FontAwesomeIcons.house,
                  activeIcon: FontAwesomeIcons.house,
                  label: 'Home',
                  navController: navController,
                ),
                const SizedBox(height: 8),
                _buildRailNavItem(
                  index: 1,
                  icon: FontAwesomeIcons.plus,
                  activeIcon: FontAwesomeIcons.circlePlus,
                  label: 'Post Item',
                  navController: navController,
                ),
                const SizedBox(height: 8),
                _buildRailNavItem(
                  index: 2,
                  icon: FontAwesomeIcons.user,
                  activeIcon: FontAwesomeIcons.solidUser,
                  label: 'Profile',
                  navController: navController,
                ),
                // Admin tab (conditional)
                if (navController.isAdmin.value) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildRailNavItem(
                    index: 3,
                    icon: FontAwesomeIcons.shield,
                    activeIcon: FontAwesomeIcons.shieldHalved,
                    label: 'Admin Panel',
                    navController: navController,
                    isAdmin: true,
                  ),
                ],
              ],
            ),
          ),

          // Admin status indicator (if admin)
          if (navController.isAdmin.value)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.userShield,
                    size: 14,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Admin Mode",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildRailNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required MainNavController navController,
    bool isAdmin = false,
  }) {
    return Obx(() {
      final isSelected = navController.currentIndex.value == index;

      return GestureDetector(
        onTap: () {
          print('Web tab tapped: $index');
          navController.changeTab(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isAdmin ? Colors.red.withOpacity(0.15) : AppTheme.accent2.withOpacity(0.15))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              FaIcon(
                isSelected ? activeIcon : icon,
                size: 20,
                color: isSelected
                    ? (isAdmin ? Colors.red : AppTheme.accent2)
                    : AppTheme.secondaryText,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? (isAdmin ? Colors.red : AppTheme.accent2)
                      : AppTheme.primaryText,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMinimalistBottomNav(MainNavController navController) {
    return Obx(() {
      List<Widget> navItems = [
        _buildMinimalistNavItem(
          index: 0,
          icon: FontAwesomeIcons.house,
          activeIcon: FontAwesomeIcons.house,
          label: "Home",
          currentIndex: navController.currentIndex.value,
          onTap: () => navController.changeTab(0),
        ),
        _buildMinimalistNavItem(
          index: 1,
          icon: FontAwesomeIcons.plus,
          activeIcon: FontAwesomeIcons.circlePlus,
          label: "Post",
          currentIndex: navController.currentIndex.value,
          onTap: () => navController.changeTab(1),
          isCenter: !navController.isAdmin.value, // Only center if not admin
        ),
        _buildMinimalistNavItem(
          index: 2,
          icon: FontAwesomeIcons.user,
          activeIcon: FontAwesomeIcons.solidUser,
          label: "Profile",
          currentIndex: navController.currentIndex.value,
          onTap: () => navController.changeTab(2),
        ),
        // Admin tab for mobile (conditional)
        if (navController.isAdmin.value)
          _buildMinimalistNavItem(
            index: 3,
            icon: FontAwesomeIcons.shield,
            activeIcon: FontAwesomeIcons.shieldHalved,
            label: "Admin",
            currentIndex: navController.currentIndex.value,
            onTap: () => navController.changeTab(3),
            isAdmin: true,
          ),
      ];

      return Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        height: 75,
        decoration: BoxDecoration(
          color: AppTheme.elevatedSurface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.surface.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navItems,
        ),
      );
    });
  }

  Widget _buildMinimalistNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int currentIndex,
    required VoidCallback onTap,
    bool isCenter = false,
    bool isAdmin = false,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        print('Mobile tab tapped: $index');
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isCenter ? 20 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isAdmin ? Colors.red.withOpacity(0.15) : AppTheme.accent2.withOpacity(0.15))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              isSelected ? activeIcon : icon,
              size: isCenter ? 24 : 20,
              color: isSelected
                  ? (isAdmin ? Colors.red : AppTheme.accent2)
                  : AppTheme.secondaryText,
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isAdmin ? Colors.red : AppTheme.accent2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
