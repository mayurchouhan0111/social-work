import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treasurehunt/app/models/user_model.dart';
import '../../../app_theme.dart';
import '../../../controllers/admin_controller.dart';
import '../../../routes/app_routes.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
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

  Widget _buildWebLayout(AdminController controller, BoxConstraints constraints) {
    return Column(
      children: [
        // Web Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 1200 ? 80 : 40,
            vertical: 32,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Admin Panel",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Review, moderate and manage all posts and users",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildStatsCard(controller),
            ],
          ),
        ),

        // Tab Bar
        _buildTabBar(controller),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth > 1200 ? 80 : 40,
              vertical: 40,
            ),
            child: _buildContent(controller),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(AdminController controller) {
    return Column(
      children: [
        AppBar(
          title: Text(
            "Admin Panel",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.feedback),
              onPressed: () => Get.toNamed(Routes.adminFeedbacks),
            ),
            Obx(() => Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${controller.pendingCount.value}",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            )),
          ],
        ),

        // Tab Bar
        _buildTabBar(controller),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildContent(controller),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(AdminController controller) {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: controller.selectedTab.value == 0
                      ? AppTheme.accent2
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Pending Posts (${controller.pendingCount.value})",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: controller.selectedTab.value == 0
                        ? Colors.white
                        : const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: controller.selectedTab.value == 1
                      ? AppTheme.accent2
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "All Posts",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: controller.selectedTab.value == 1
                        ? Colors.white
                        : const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: controller.selectedTab.value == 2
                      ? AppTheme.accent2
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Users (${controller.unverifiedUsersCount.value})",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: controller.selectedTab.value == 2
                        ? Colors.white
                        : const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(3),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: controller.selectedTab.value == 3
                      ? AppTheme.accent2
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Verified Users (${controller.verifiedUsersCount.value})",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: controller.selectedTab.value == 3
                        ? Colors.white
                        : const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildStatsCard(AdminController controller) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.clock,
            size: 16,
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            "${controller.pendingCount.value} Pending Posts",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildContent(AdminController controller) {
    return Obx(() {
      if (controller.selectedTab.value == 0) {
        return _buildPendingContent(controller);
      } else if (controller.selectedTab.value == 1) {
        return _buildAllPostsContent(controller);
      } else if (controller.selectedTab.value == 2) {
        return _buildUsersContent(controller);
      } else {
        return _buildVerifiedUsersContent(controller);
      }
    });
  }

  Widget _buildUsersContent(AdminController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.unverifiedUsers.isEmpty) {
        return _buildEmptyState(message: "No unverified users found.");
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Unverified Users",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ...controller.unverifiedUsers.map((user) {
            return _buildUserCard(controller, user);
          }).toList(),
        ],
      );
    });
  }

  Widget _buildVerifiedUsersContent(AdminController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.verifiedUsers.isEmpty) {
        return _buildEmptyState(message: "No verified users found.");
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Verified Users",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ...controller.verifiedUsers.map((user) {
            return _buildVerifiedUserCard(controller, user);
          }).toList(),
        ],
      );
    });
  }

  Widget _buildVerifiedUserCard(AdminController controller, UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                user.name ?? 'No Name',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showIdCard(user.identityCardImageUrl ?? ''),
                icon: const Icon(Icons.credit_card, color: AppTheme.accent2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enrollment: ${user.enrollmentNumber ?? 'N/A'}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.unverifyUser(user.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.userSlash, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        "Un-verify",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AdminController controller, UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                user.name ?? 'No Name',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showIdCard(user.identityCardImageUrl ?? ''),
                icon: const Icon(Icons.credit_card, color: AppTheme.accent2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enrollment: ${user.enrollmentNumber ?? 'N/A'}',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF9E9E9E),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.approveUser(user.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.check, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        "Approve",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.rejectUser(user.id),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.xmark, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        "Reject",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showIdCard(String imageUrl) {
    if (imageUrl.isEmpty) {
      Get.snackbar('Error', 'No ID card image available.');
      return;
    }
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  Widget _buildPendingContent(AdminController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.pendingPosts.isEmpty) {
        return _buildEmptyState(message: "No pending posts to approve.");
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pending Approvals",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ...controller.pendingPosts.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final postData = data['postData'] as Map<String, dynamic>;
            return _buildPendingPostCard(controller, postData);
          }).toList(),
        ],
      );
    });
  }

  Widget _buildAllPostsContent(AdminController controller) {
    return Obx(() {
      if (controller.allPosts.isEmpty) {
        return _buildEmptyState(message: "No posts found.");
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "All Posts",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ...controller.allPosts.map((doc) {
            final postData = doc.data() as Map<String, dynamic>;
            return _buildAllPostCard(controller, postData);
          }).toList(),
        ],
      );
    });
  }

  Widget _buildPendingPostCard(AdminController controller, Map<String, dynamic> postData) {
    final isLost = (postData['status'] ?? '').toLowerCase() == 'lost';
    final statusColor = isLost ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Delete Button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  (postData['status'] ?? 'UNKNOWN').toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "PENDING APPROVAL",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => controller.showDeleteDialog(
                  postData['id'],
                  postData['title'] ?? 'Unknown Post',
                ),
                icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content (existing code remains the same)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              if (postData['imageUrl'] != null && postData['imageUrl'].toString().isNotEmpty)
                Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF2A2A2A),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      postData['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      postData['title'] ?? 'No Title',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (postData['description'] != null)
                      Text(
                        postData['description'],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF9E9E9E),
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.locationDot,
                          size: 14,
                          color: AppTheme.accent2,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          postData['location'] ?? 'No Location',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (postData['mobileNumber'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.phone,
                            size: 14,
                            color: AppTheme.accent2,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            postData['mobileNumber'].toString(),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.approvePost(postData['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.check, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        "Approve",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.showRejectDialog(postData['id']),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.xmark, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        "Reject",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllPostCard(AdminController controller, Map<String, dynamic> postData) {
    final status = postData['moderationStatus'] ?? 'unknown';
    Color statusColor;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'APPROVED';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'REJECTED';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'PENDING';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'UNKNOWN';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          // Image
          if (postData['imageUrl'] != null && postData['imageUrl'].toString().isNotEmpty)
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF2A2A2A),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  postData['imageUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        postData['title'] ?? 'No Title',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  postData['location'] ?? 'No Location',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),

          // Delete Button
          IconButton(
            onPressed: () => controller.showDeleteDialog(
              postData['id'] ?? '',
              postData['title'] ?? 'Unknown Post',
            ),
            icon: const Icon(Icons.delete_forever, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppTheme.accent2),
          ),
          const SizedBox(height: 24),
          Text(
            "Loading...",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({String message = "No posts found"}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.checkCircle,
                size: 32,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "All Caught Up!",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}