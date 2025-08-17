import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:treasurehunt/app/routes/app_pages.dart';
import '../../../app_theme.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../routes/app_routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 768) {
            return _buildWebLayout(controller, constraints);
          } else {
            return _buildMobileLayout(controller);
          }
        },
      ),
    );
  }

  Widget _buildWebLayout(ProfileController controller, BoxConstraints constraints) {
    return Column(
      children: [
        // Enhanced Web Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 1200 ? 80 : 40,
            vertical: 32,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            boxShadow: [
              BoxShadow(
                color: AppTheme.surface.withOpacity(0.26),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accent2, AppTheme.accent1],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppTheme.primaryText,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profile",
                    style: GoogleFonts.archivo(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Manage your account information and settings",
                    style: GoogleFonts.archivo(
                      fontSize: 14,
                      color: AppTheme.accent1,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildActionButton(
                icon: FontAwesomeIcons.arrowsRotate,
                label: "Refresh",
                onTap: () => controller.refreshProfile(),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 1200 ? 80 : 40,
              vertical: 40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: _buildProfileContent(controller),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ProfileController controller) {
    return Column(
      children: [
        // Enhanced Mobile Header
        AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accent2.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppTheme.accent1,
                size: 20,
              ),
              onPressed: () => Get.back(),
            ),
          ),
          title: Text(
            "Profile",
            style: GoogleFonts.archivo(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppTheme.accent2.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const FaIcon(
                  FontAwesomeIcons.arrowsRotate,
                  size: 16,
                  color: AppTheme.accent1,
                ),
                onPressed: () => controller.refreshProfile(),
              ),
            ),
          ],
        ),
        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.refreshProfile(),
            color: AppTheme.accent1,
            backgroundColor: AppTheme.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: _buildProfileContent(controller),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent(ProfileController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      return Column(
        children: [
          // Profile Avatar Section
          _buildProfileAvatar(controller),
          const SizedBox(height: 40),
          // Profile Information Cards
          _buildProfileInfoSection(controller),
          const SizedBox(height: 40),
          // Action Buttons
          _buildActionButtonsSection(controller),
          const SizedBox(height: 40),
          // User's posts
          _buildUserPostsSection(controller),
        ],
      );
    });
  }

  Widget _buildUserPostsSection(ProfileController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accent2.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.surface.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 16),
                        const SizedBox(width: 8),
                        Text('Lost (${controller.lostItems.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.find_in_page, size: 16),
                        const SizedBox(width: 8),
                        Text('Found (${controller.foundItems.length})'),
                      ],
                    ),
                  ),
                ],
                labelColor: AppTheme.accent1,
                unselectedLabelColor: AppTheme.secondaryText,
                indicatorColor: AppTheme.accent1,
                labelStyle: GoogleFonts.archivo(fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              height: 300,
              child: TabBarView(
                children: [
                  _buildItemsList(controller.lostItems),
                  _buildItemsList(controller.foundItems),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(List items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppTheme.secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              'No items yet',
              style: GoogleFonts.archivo(
                color: AppTheme.secondaryText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accent2.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accent2, AppTheme.accent1],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_rounded,
                  color: AppTheme.primaryText,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.archivo(
                        color: AppTheme.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.location,
                      style: GoogleFonts.archivo(
                        color: AppTheme.accent1,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.itemClaims, arguments: item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  'View Claims',
                  style: GoogleFonts.archivo(
                    color: AppTheme.primaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(ProfileController controller) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accent2, AppTheme.accent1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent2.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 60,
                color: AppTheme.primaryText,
              ),
            ),
            // Verification badge
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: controller.verificationStatusColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryText, width: 3),
                ),
                child: Icon(
                  controller.isVerified ? Icons.verified : Icons.pending,
                  size: 16,
                  color: AppTheme.primaryText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          controller.displayName,
          style: GoogleFonts.archivo(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          controller.displayEmail,
          style: GoogleFonts.archivo(
            fontSize: 14,
            color: AppTheme.accent1,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoSection(ProfileController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: FontAwesomeIcons.envelope,
                label: "Email",
                value: controller.displayEmail,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildInfoCard(
                icon: FontAwesomeIcons.phone,
                label: "Mobile",
                value: controller.displayMobileNumber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: FontAwesomeIcons.graduationCap,
                label: "Enrollment",
                value: controller.displayEnrollmentNumber,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildInfoCard(
                icon: FontAwesomeIcons.shieldHalved,
                label: "Status",
                value: controller.verificationStatus,
                valueColor: controller.verificationStatusColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accent2.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.surface.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accent2.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  icon,
                  size: 16,
                  color: AppTheme.accent1,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.archivo(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.accent1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.archivo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.primaryText,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsSection(ProfileController controller) {
    return Column(
      children: [
        // Edit Profile Button
        GestureDetector(
          onTap: controller.isUpdating.value
              ? null
              : () {
            Get.snackbar(
              'Edit Profile',
              'Edit profile functionality will be implemented',
              backgroundColor: AppTheme.surface,
              colorText: AppTheme.primaryText,
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accent2, AppTheme.accent1],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent2.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: controller.isUpdating.value
                  ? [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryText,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Updating...",
                  style: GoogleFonts.archivo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
              ]
                  : [
                const FaIcon(
                  FontAwesomeIcons.userPen,
                  size: 18,
                  color: AppTheme.primaryText,
                ),
                const SizedBox(width: 12),
                Text(
                  "Edit Profile",
                  style: GoogleFonts.archivo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Secondary Actions Row
        Row(
          children: [
            Expanded(
              child: _buildSecondaryAction(
                icon: FontAwesomeIcons.gear,
                label: "Settings",
                onTap: () {
                  Get.snackbar(
                    'Settings',
                    'Settings page will be implemented',
                    backgroundColor: AppTheme.surface,
                    colorText: AppTheme.primaryText,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSecondaryAction(
                icon: FontAwesomeIcons.rightFromBracket,
                label: "Sign Out",
                onTap: () {
                  _showSignOutDialog();
                },
                isDestructive: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSecondaryAction(
                icon: FontAwesomeIcons.solidCommentDots,
                label: "My Chats",
                onTap: () {
                  Get.toNamed(Routes.myChats);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : AppTheme.accent1;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.surface.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.archivo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.accent2.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.accent2.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 14,
              color: AppTheme.accent1,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.archivo(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.accent1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.surface.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppTheme.accent1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Loading profile...",
            style: GoogleFonts.archivo(
              fontSize: 16,
              color: AppTheme.accent1,
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accent2.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 32,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Sign Out",
                style: GoogleFonts.archivo(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to sign out of your account?",
                textAlign: TextAlign.center,
                style: GoogleFonts.archivo(
                  fontSize: 14,
                  color: AppTheme.accent1,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.archivo(
                          color: AppTheme.accent1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.find<AuthController>().signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Sign Out",
                        style: GoogleFonts.archivo(
                          color: AppTheme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
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
}