import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:treasurehunt/app/controllers/auth_controller.dart';
import 'package:treasurehunt/app/models/item_model.dart';
import '../../../app_theme.dart';
import '../../../routes/app_routes.dart';

class MinimalItemDetailPage extends StatelessWidget {
  final ItemModel item;

  const MinimalItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final bool isLost = item.status.toLowerCase() == 'lost';
    final Color statusColor = isLost ? Colors.orange : Colors.green;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Item Details',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMoreOptions(context, authController),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                item.status.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              item.title,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 8),

            // Date
            Text(
              DateFormat('MMM dd, yyyy').format(item.createdAt),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF9E9E9E),
              ),
            ),

            const SizedBox(height: 20),

            // Image
            if (item.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => _buildSimplePlaceholder(),
                ),
              )
            else
              _buildSimplePlaceholder(),

            const SizedBox(height: 20),

            // Essential Info Only
            _buildInfoRow(Icons.location_on, item.location),

            if (item.mobileNumber != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.phone, item.mobileNumber.toString()),
            ],

            const Spacer(),

            // Primary Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openWhatsApp(authController, isFoundClaim: true),
                icon: FaIcon(
                  isLost ? FontAwesomeIcons.handHoldingHeart : FontAwesomeIcons.handshake,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  isLost ? 'I Found This!' : 'This is Mine!',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationRequiredDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.shieldHalved, size: 32, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                "Verification Required",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "You must be a verified user to contact other users. Please wait for an admin to approve your profile.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimplePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 48, color: Color(0xFF9E9E9E)),
          SizedBox(height: 8),
          Text(
            'No image available',
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // More Options Bottom Sheet
  void _showMoreOptions(BuildContext context, AuthController authController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF9E9E9E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'More Options',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // WhatsApp Contact
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
              title: Text(
                'Contact via WhatsApp',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              subtitle: Text(
                'Send a message directly',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9E9E9E),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Get.back();
                _openWhatsApp(authController, isFoundClaim: false);
              },
            ),

            // Phone Call
            if (item.mobileNumber != null)
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.blue),
                title: Text(
                  'Call Directly',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                subtitle: Text(
                  item.mobileNumber.toString(),
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _makePhoneCall(authController);
                },
              ),

            // SMS
            if (item.mobileNumber != null)
              ListTile(
                leading: const Icon(Icons.message, color: Colors.orange),
                title: Text(
                  'Send SMS',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                subtitle: Text(
                  'Send a text message',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _sendSMS(authController);
                },
              ),

            // View Description
            if (item.description != null && item.description!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.description, color: Colors.purple),
                title: Text(
                  'View Description',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                subtitle: Text(
                  'See full details',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _showDescription();
                },
              ),

            // Share Item
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: Text(
                'Share Item',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              subtitle: Text(
                'Share with others',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9E9E9E),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Get.back();
                _shareItem();
              },
            ),

            // Bookmark
            ListTile(
              leading: const Icon(Icons.bookmark_add, color: Colors.yellow),
              title: Text(
                'Bookmark Item',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              subtitle: Text(
                'Save for later',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9E9E9E),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Get.back();
                _bookmarkItem();
              },
            ),

            // Give Feedback
            ListTile(
              leading: const Icon(Icons.feedback, color: Colors.amber),
              title: Text(
                'Give Feedback',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              subtitle: Text(
                'Provide feedback on this item',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9E9E9E),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.feedbackReport, arguments: item.id);
              },
            ),

            // Report
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.red),
              title: Text(
                'Report Item',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              subtitle: Text(
                'Report inappropriate content',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9E9E9E),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Get.back();
                Get.toNamed(Routes.feedbackReport, arguments: item.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  // WhatsApp Integration
  Future<void> _openWhatsApp(AuthController authController, {required bool isFoundClaim}) async {
    final isVerified = authController.userProfile.value?.isVerified ?? false;
    if (!isVerified) {
      _showVerificationRequiredDialog();
      return;
    }

    String? phoneNumber = item.mobileNumber?.toString();
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showNoContactDialog();
      return;
    }

    // Format phone number
    phoneNumber = _formatPhoneNumber(phoneNumber);
    String message = _generateWhatsAppMessage(isFoundClaim);

    final String whatsappUrl = "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}";

    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showWhatsAppNotInstalledDialog();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open WhatsApp. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  String _formatPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.startsWith('+')) {
      return cleanPhone;
    }
    if (cleanPhone.length > 10) {
      return '+$cleanPhone';
    }
    if (cleanPhone.length == 10) {
      return '+91$cleanPhone'; // Change +91 to your country code
    }
    return cleanPhone;
  }

  String _generateWhatsAppMessage(bool isFoundClaim) {
    final isLost = item.status.toLowerCase() == 'lost';
    final itemTitle = item.title;
    final location = item.location;
    String message;

    if (isFoundClaim) {
      if (isLost) {
        message = "Hi! I found your lost item: $itemTitle\n\n" 
            "Location mentioned: $location\n\n" 
            "Please let me know if this is yours and we can arrange to return it to you.";
      } else {
        message = "Hi! I believe the item you found ($itemTitle) belongs to me.\n\n" 
            "Location: $location\n\n" 
            "Could we please arrange a meeting to verify and collect it?";
      }
    } else {
      message = "Hi! I'm contacting you regarding: $itemTitle\n\n" 
          "Location: $location\n\n" 
          "Could you please provide more details?";
    }

    return message;
  }

  // Phone Call
  Future<void> _makePhoneCall(AuthController authController) async {
    final isVerified = authController.userProfile.value?.isVerified ?? false;
    if (!isVerified) {
      _showVerificationRequiredDialog();
      return;
    }

    String? phoneNumber = item.mobileNumber?.toString();
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showNoContactDialog();
      return;
    }

    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          'Error',
          'Could not make phone call',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not make phone call. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // SMS
  Future<void> _sendSMS(AuthController authController) async {
    final isVerified = authController.userProfile.value?.isVerified ?? false;
    if (!isVerified) {
      _showVerificationRequiredDialog();
      return;
    }

    String? phoneNumber = item.mobileNumber?.toString();
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showNoContactDialog();
      return;
    }

    final String message = "Hi! I'm contacting you regarding: ${item.title}\nLocation: ${item.location}";
    final Uri smsUri = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        Get.snackbar(
          'Error',
          'Could not send SMS',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not send SMS. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Share Item
  Future<void> _shareItem() async {
    final message = "Check out this ${item.status.toLowerCase()} item: ${item.title}\n" 
        "Location: ${item.location}\n" 
        "Posted: ${DateFormat('MMM dd, yyyy').format(item.createdAt)}";

    try {
      await Share.share(message, subject: 'Lost & Found Item: ${item.title}');
    } catch (e) {
      Get.snackbar(
        'Share',
        message,
        backgroundColor: const Color(0xFF1A1A1A),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Bookmark Item
  void _bookmarkItem() {
    Get.snackbar(
      'Bookmark',
      'Item bookmarked successfully!',
      backgroundColor: const Color(0xFF1A1A1A),
      colorText: Colors.white,
      icon: const Icon(Icons.bookmark, color: Colors.white),
    );
  }

  // Show Description Dialog
  void _showDescription() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.description ?? '',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF9E9E9E),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Report Dialog
  void _showReportDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.flag, size: 32, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                "Report Item",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to report this item as inappropriate?",
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
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Reported',
                          'Item has been reported successfully',
                          backgroundColor: const Color(0xFF1A1A1A),
                          colorText: Colors.white,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Report",
                        style: GoogleFonts.inter(
                          color: Colors.white,
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

  // No Contact Dialog
  void _showNoContactDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.exclamationTriangle, size: 32, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                "No Contact Information",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "This item doesn't have contact information available. Please try reporting it to admin.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WhatsApp Not Installed Dialog
  void _showWhatsAppNotInstalledDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(FontAwesomeIcons.whatsapp, size: 32, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                "WhatsApp Not Available",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "WhatsApp is not installed on your device or cannot be opened.",
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
                        style: GoogleFonts.inter(
                          color: const Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        const playStoreUrl = "https://play.google.com/store/apps/details?id=com.whatsapp";
                        if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
                          await launchUrl(Uri.parse(playStoreUrl));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Install",
                        style: GoogleFonts.inter(
                          color: Colors.white,
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