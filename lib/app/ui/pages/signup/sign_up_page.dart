// lib/app/pages/auth/sign_up_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../controllers/auth_controller.dart';
import '../../../app_theme.dart';
import '../../../routes/app_pages.dart';
import '../../../models/college_model.dart';
import '../../../routes/app_routes.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final enrollmentController = TextEditingController();
    final obscurePassword = true.obs;
    final obscureConfirmPassword = true.obs;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.chevronLeft,
            size: 18,
            color: AppTheme.textSecondary,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center( // Center the form
          child: ConstrainedBox( // Constrain its width
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Logo Section
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accentColor, AppTheme.primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.graduationCap,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Title
                  Text(
                    "Student Registration",
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Join the treasure hunt community",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Personal Information Section
                  _buildSectionHeader("Personal Information"),
                  const SizedBox(height: 16),

                  // Name Input
                  _buildInputField(
                    controller: nameController,
                    label: "Full Name",
                    hint: "Enter your full name",
                    icon: FontAwesomeIcons.user,
                    onChanged: (value) => controller.name.value = value,
                  ),
                  const SizedBox(height: 20),

                  // Email Input
                  _buildInputField(
                    controller: emailController,
                    label: "Email Address",
                    hint: "Enter your email",
                    icon: FontAwesomeIcons.envelope,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => controller.email.value = value,
                  ),
                  const SizedBox(height: 20),

                  // Mobile Number Input
                  _buildInputField(
                    controller: mobileController,
                    label: "Mobile Number",
                    hint: "Enter your mobile number",
                    icon: FontAwesomeIcons.phone,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => controller.mobileNumber.value = value,
                  ),
                  const SizedBox(height: 20),

                  // Password Input
                  Obx(() => _buildInputField(
                    controller: passwordController,
                    label: "Password",
                    hint: "Create a secure password",
                    icon: FontAwesomeIcons.lock,
                    obscureText: obscurePassword.value,
                    onChanged: (value) => controller.password.value = value,
                    suffixIcon: GestureDetector(
                      onTap: () => obscurePassword.toggle(),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: FaIcon(
                          obscurePassword.value ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),

                  // Confirm Password Input
                  Obx(() => _buildInputField(
                    controller: confirmPasswordController,
                    label: "Confirm Password",
                    hint: "Re-enter your password",
                    icon: FontAwesomeIcons.lockOpen,
                    obscureText: obscureConfirmPassword.value,
                    onChanged: (value) => controller.confirmPassword.value = value,
                    suffixIcon: GestureDetector(
                      onTap: () => obscureConfirmPassword.toggle(),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: FaIcon(
                          obscureConfirmPassword.value ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: 32),

                  // Academic Information Section
                  _buildSectionHeader("Academic Information"),
                  const SizedBox(height: 16),

                  // Enrollment Number Input
                  _buildInputField(
                    controller: enrollmentController,
                    label: "Enrollment Number",
                    hint: "Enter your enrollment number",
                    icon: FontAwesomeIcons.idCard,
                    onChanged: (value) => controller.enrollmentNumber.value = value,
                  ),
                  const SizedBox(height: 32),

                  // Identity Verification Section
                  _buildSectionHeader("Identity Verification"),
                  const SizedBox(height: 16),
                  _buildIdentityCardUpload(controller),
                  const SizedBox(height: 32),

                  // Create Account Button
                  _buildSignUpButton(controller, emailController, passwordController),
                  const SizedBox(height: 24),

                  // Info Card
                  _buildInfoCard(),
                  const SizedBox(height: 32),

                  // Sign In Link
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.signIn),
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign In",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(16),
            child: FaIcon(
              icon,
              size: 20,
              color: AppTheme.accentColor,
            ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          labelStyle: GoogleFonts.inter(
            color: AppTheme.textSecondary,
          ),
          hintStyle: GoogleFonts.inter(
            color: AppTheme.textSecondary.withOpacity(0.6),
          ),
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildIdentityCardUpload(AuthController controller) {
    return Obx(() => GestureDetector(
      onTap: controller.isUploadingIdentityCard.value ? null : () => _showImagePicker(controller),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: controller.isUploadingIdentityCard.value
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor)),
            const SizedBox(height: 16),
            Text(
              "Uploading identity card...",
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        )
            : controller.selectedIdentityCard.value != null
            ? Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: kIsWeb
                  ? Image.network(
                      controller.selectedIdentityCard.value!.path,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    )
                  : Image.file(
                      File(controller.selectedIdentityCard.value!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
            ),
            if (controller.identityCardImageUrl.value.isNotEmpty)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Uploaded",
                        style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  controller.selectedIdentityCard.value = null;
                  controller.identityCardImageUrl.value = '';
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const FaIcon(FontAwesomeIcons.idCard, size: 24, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              "Upload Identity Card",
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              "Required for student verification",
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSignUpButton(AuthController controller, TextEditingController emailController, TextEditingController passwordController) {
    return Obx(() => GestureDetector(
      onTap: controller.isLoading.value || controller.isUploadingIdentityCard.value
          ? null
          : () {
        controller.signUp(emailController.text, passwordController.text);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: controller.isLoading.value || controller.isUploadingIdentityCard.value
              ? null
              : LinearGradient(
            colors: [AppTheme.accentColor, AppTheme.primaryColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          color: controller.isLoading.value || controller.isUploadingIdentityCard.value
              ? AppTheme.cardColor
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: controller.isLoading.value || controller.isUploadingIdentityCard.value
              ? []
              : [
            BoxShadow(
              color: AppTheme.accentColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: controller.isUploadingIdentityCard.value
              ? [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppTheme.accentColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Uploading Identity Card...",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ]
              : controller.isLoading.value
              ? [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppTheme.accentColor),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Creating Account...",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ]
              : [
            const FaIcon(
              FontAwesomeIcons.graduationCap,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              "Create Student Account",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.shieldHalved,
                size: 20,
                color: AppTheme.accentColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Student Verification",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "• All information will be verified by administrators\n• Your identity card will be securely stored\n• Only verified students can post items\n• This helps maintain community trust",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePicker(AuthController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Upload Identity Card",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildImagePickerOption(
                    icon: FontAwesomeIcons.camera,
                    label: "Camera",
                    onTap: () {
                      Get.back();
                      controller.pickIdentityCardImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImagePickerOption(
                    icon: FontAwesomeIcons.images,
                    label: "Gallery",
                    onTap: () {
                      Get.back();
                      controller.pickIdentityCardImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            FaIcon(
              icon,
              size: 24,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}