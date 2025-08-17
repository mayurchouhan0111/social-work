import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../app_theme.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/main_nav_controller.dart';
import 'item_detail_page.dart' hide AppTheme;
import '../../widgets/filter_enums.dart'; // Import SortOption and DateRange

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Dark background
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Web layout with header
          if (constraints.maxWidth >= 768) {
            return Column(
              children: [
                _buildWebHeader(controller, constraints),
                Expanded(child: _buildWebContent(controller, constraints)),
              ],
            );
          }
          // Mobile layout with AppBar
          else {
            return Column(
              children: [
                _buildMobileHeader(controller),
                Expanded(child: _buildMobileContent(controller)),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildWebHeader(HomeController controller, BoxConstraints constraints) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: constraints.maxWidth > 1200 ? 80 : 40,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Dark card background
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
                "Lost & Found",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Find what you've lost, return what you've found",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF9E9E9E), // Light gray text
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildSearchField(controller, isWeb: true),
          const SizedBox(width: 20),
          _buildWebFilterButton(controller),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(HomeController controller) {
    return AppBar(
      title: Text(
        "Lost & Found",
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
          icon: FaIcon(
            FontAwesomeIcons.filter,
            size: 16,
            color: const Color(0xFF9E9E9E),
          ),
          onPressed: () {
            _showFilterBottomSheet(controller);
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildSearchField(controller, isWeb: false),
        ),
      ),
    );
  }

  Widget _buildSearchField(HomeController controller, {required bool isWeb}) {
    return Container(
      width: isWeb ? 300 : double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (value) => controller.setSearchTerm(value),
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search items...",
          hintStyle: GoogleFonts.inter(color: const Color(0xFF9E9E9E)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildWebFilterButton(HomeController controller) {
    return GestureDetector(
      onTap: () => _showFilterBottomSheet(controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.accent2.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTheme.accent2.withOpacity(0.3)
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.filter,
              size: 14,
              color: AppTheme.accent2,
            ),
            const SizedBox(width: 8),
            Text(
              "Filters",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.accent2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebContent(HomeController controller, BoxConstraints constraints) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.filteredItems.isEmpty) {
        return _buildEmptyState();
      }

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth > 1200 ? 80 : 40,
          vertical: 32,
        ),
        child: _buildItemsGrid(controller, constraints),
      );
    });
  }

  Widget _buildMobileContent(HomeController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.filteredItems.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredItems.length,
        itemBuilder: (context, index) {
          final item = controller.filteredItems[index];
          return _buildMobileItemCard(item);
        },
      );
    });
  }

  Widget _buildItemsGrid(HomeController controller, BoxConstraints constraints) {
    int crossAxisCount;
    double childAspectRatio;

    if (constraints.maxWidth > 1400) {
      crossAxisCount = 4;
      childAspectRatio = 0.75;
    } else if (constraints.maxWidth > 1000) {
      crossAxisCount = 3;
      childAspectRatio = 0.8;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.85;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: controller.filteredItems.length,
      itemBuilder: (context, index) {
        final item = controller.filteredItems[index];
        return _buildWebItemCard(item);
      },
    );
  }

  Widget _buildWebItemCard(dynamic item) {
    final isLost = item.status.toLowerCase() == 'lost';
    final statusColor = isLost ? Colors.orange : Colors.green;

    return GestureDetector(
      onTap: () => _navigateToDetailView(item),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A2A2A),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: item.imageUrl != null && item.imageUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
                    )
                        : _buildImagePlaceholder(),
                  ),
                  // View Details overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.eye,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.status.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Location and time
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.locationDot,
                          size: 10,
                          color: const Color(0xFF9E9E9E),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.location,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF9E9E9E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatDate(item.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "View Details",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppTheme.accent2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileItemCard(dynamic item) {
    final isLost = item.status.toLowerCase() == 'lost';
    final statusColor = isLost ? Colors.orange : Colors.green;

    return GestureDetector(
      onTap: () => _navigateToDetailView(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A2A2A),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            if (item.imageUrl != null && item.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      ),
                    ),
                    // View Details overlay
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.eye,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "View",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          item.status.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(item.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    item.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.locationDot,
                        size: 14,
                        color: AppTheme.accent2,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.location,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accent2.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "View Details",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.accent2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.image,
            size: 32,
            color: const Color(0xFF9E9E9E).withOpacity(0.5),
          ),
          const SizedBox(height: 8),
          Text(
            "No Image",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF9E9E9E),
            ),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppTheme.accent2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Loading items...",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accent2.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  size: 32,
                  color: AppTheme.accent2,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Nothing here yet",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Be the first to post a lost or found item",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                final authController = Get.find<AuthController>();
                if (authController.userProfile.value?.isVerified ?? false) {
                  try {
                    Get.find<MainNavController>().changeTab(1);
                  } catch (e) {
                    // Fallback navigation
                    Get.toNamed('/post');
                  }
                } else {
                  Get.snackbar(
                    'Verification Required',
                    'You need to be a verified user to post items.',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.accent2, AppTheme.accent1],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent2.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.plus,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Post an item",
                      style: GoogleFonts.inter(
                        fontSize: 16,
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
      ),
    );
  }

  // Missing filter bottom sheet method
  void _showFilterBottomSheet(HomeController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF9E9E9E),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              "Filter Items",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Status Filter
            Text(
              "Status",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            Obx(() => Row(
              children: [
                Expanded(
                  child: _buildFilterChip(
                    label: "All",
                    isSelected: controller.selectedStatusFilter.value == 'all',
                    onTap: () => controller.setStatusFilter('all'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    label: "Lost",
                    isSelected: controller.selectedStatusFilter.value == 'lost',
                    onTap: () => controller.setStatusFilter('lost'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFilterChip(
                    label: "Found",
                    isSelected: controller.selectedStatusFilter.value == 'found',
                    onTap: () => controller.setStatusFilter('found'),
                  ),
                ),
              ],
            )),

            const SizedBox(height: 32),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent2,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Apply Filters",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent2
              : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.accent2
                : const Color(0xFF2A2A2A),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }

  void _navigateToDetailView(dynamic item) {
    final authController = Get.find<AuthController>();
    if (authController.userProfile.value?.isVerified ?? false) {
      Get.to(
            () => MinimalItemDetailPage(item: item),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );
    } else {
      Get.snackbar(
        'Verification Required',
        'You need to be a verified user to view item details.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
