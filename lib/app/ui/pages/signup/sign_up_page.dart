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
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF0F52BA).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.chevronLeft,
              size: 16,
              color: Color(0xFF87CEEB),
            ),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Section
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F52BA),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F52BA).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.graduationCap,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    "Student Registration",
                    style: GoogleFonts.rubik(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Join the treasure hunt community",
                    style: GoogleFonts.rubik(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF87CEEB),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Personal Information Section
                  _buildSectionHeader("Personal Information"),
                  const SizedBox(height: 16),

                  _buildInputField(
                    controller: nameController,
                    label: "Full Name",
                    hint: "Enter your full name",
                    icon: FontAwesomeIcons.user,
                    onChanged: (value) => controller.name.value = value,
                  ),

                  const SizedBox(height: 16),

                  _buildInputField(
                    controller: emailController,
                    label: "Email Address",
                    hint: "Enter your email",
                    icon: FontAwesomeIcons.envelope,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => controller.email.value = value,
                  ),

                  const SizedBox(height: 16),

                  _buildInputField(
                    controller: mobileController,
                    label: "Mobile Number",
                    hint: "Enter your mobile number",
                    icon: FontAwesomeIcons.phone,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) => controller.mobileNumber.value = value,
                  ),

                  const SizedBox(height: 16),

                  Obx(() => _buildInputField(
                    controller: passwordController,
                    label: "Password",
                    hint: "Create a secure password",
                    icon: FontAwesomeIcons.lock,
                    obscureText: obscurePassword.value,
                    onChanged: (value) => controller.password.value = value,
                    suffixIcon: GestureDetector(
                      onTap: () => obscurePassword.toggle(),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: FaIcon(
                          obscurePassword.value ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                          size: 16,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  )),

                  const SizedBox(height: 16),

                  Obx(() => _buildInputField(
                    controller: confirmPasswordController,
                    label: "Confirm Password",
                    hint: "Re-enter your password",
                    icon: FontAwesomeIcons.lockOpen,
                    obscureText: obscureConfirmPassword.value,
                    onChanged: (value) => controller.confirmPassword.value = value,
                    suffixIcon: GestureDetector(
                      onTap: () => obscureConfirmPassword.toggle(),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: FaIcon(
                          obscureConfirmPassword.value ? FontAwesomeIcons.eyeSlash : FontAwesomeIcons.eye,
                          size: 16,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  )),

                  const SizedBox(height: 32),

                  // Academic Information Section
                  _buildSectionHeader("Academic Information"),
                  const SizedBox(height: 16),

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
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign In",
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF87CEEB),
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
      style: GoogleFonts.rubik(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.5,
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
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0F52BA).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        style: GoogleFonts.rubik(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          prefixIcon: Container(
            padding: const EdgeInsets.all(16),
            child: FaIcon(
              icon,
              size: 18,
              color: const Color(0xFF87CEEB),
            ),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: const Color(0xFF0F52BA),
              width: 2,
            ),
          ),
          labelStyle: GoogleFonts.rubik(
            color: const Color(0xFF87CEEB),
            fontSize: 16,
          ),
          floatingLabelStyle: GoogleFonts.rubik(
            color: const Color(0xFF87CEEB),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.rubik(
            color: Colors.white70,
            fontSize: 16,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildIdentityCardUpload(AuthController controller) {
    return Obx(() => GestureDetector(
      onTap: controller.isUploadingIdentityCard.value ? null : () => _showImagePicker(controller),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0F52BA).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: controller.isUploadingIdentityCard.value
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF87CEEB)),
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 12),
            Text(
              "Uploading identity card...",
              style: GoogleFonts.rubik(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        )
            : controller.selectedIdentityCard.value != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              kIsWeb
                  ? Image.network(
                controller.selectedIdentityCard.value!.path,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
              )
                  : Image.file(
                File(controller.selectedIdentityCard.value!.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
              ),
              if (controller.identityCardImageUrl.value.isNotEmpty)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F52BA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Uploaded",
                          style: GoogleFonts.rubik(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F52BA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const FaIcon(
                FontAwesomeIcons.idCard,
                size: 28,
                color: Color(0xFF87CEEB),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Upload Identity Card",
              style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Required for student verification",
              style: GoogleFonts.rubik(
                fontSize: 12,
                color: const Color(0xFF87CEEB),
              ),
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
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: controller.isLoading.value || controller.isUploadingIdentityCard.value
              ? const Color(0xFF1A1A1A)
              : const Color(0xFF0F52BA),
          borderRadius: BorderRadius.circular(16),
          border: controller.isLoading.value || controller.isUploadingIdentityCard.value
              ? Border.all(
            color: const Color(0xFF0F52BA).withOpacity(0.3),
            width: 1,
          )
              : null,
          boxShadow: controller.isLoading.value || controller.isUploadingIdentityCard.value
              ? []
              : [
            BoxShadow(
              color: const Color(0xFF0F52BA).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: controller.isUploadingIdentityCard.value
              ? [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF87CEEB)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Uploading Identity Card...",
              style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ]
              : controller.isLoading.value
              ? [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF87CEEB)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Creating Account...",
              style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ]
              : [
            const FaIcon(
              FontAwesomeIcons.graduationCap,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              "Create Student Account",
              style: GoogleFonts.rubik(
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
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0F52BA).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F52BA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.shieldHalved,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Student Verification",
                  style: GoogleFonts.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "• All information will be verified by administrators\n• Your identity card will be securely stored\n• Only verified students can post items\n• This helps maintain community trust",
            style: GoogleFonts.rubik(
              fontSize: 14,
              color: const Color(0xFF87CEEB),
              height: 1.5,
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
          color: Color(0xFF1A1A1A),
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
                color: const Color(0xFF87CEEB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Upload Identity Card",
              style: GoogleFonts.rubik(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
          color: const Color(0xFF0F52BA).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF0F52BA).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            FaIcon(
              icon,
              size: 24,
              color: const Color(0xFF87CEEB),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
