// lib/app/pages/auth/sign_in_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../controllers/auth_controller.dart';
import '../../../app_theme.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/app_routes.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final obscurePassword = true.obs;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center( // Center the content for web
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox( // Constrain the width
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo Section
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.accentColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.userShield,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      "Welcome Back",
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Sign in to your account",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Email Input
                    Container(
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
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          hintText: "Enter your email",
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(16),
                            child: FaIcon(
                              FontAwesomeIcons.envelope,
                              size: 20,
                              color: AppTheme.primaryColor,
                            ),
                          ),
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
                    ),

                    const SizedBox(height: 20),

                    // Password Input
                    Obx(() => Container(
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
                        controller: passwordController,
                        obscureText: obscurePassword.value,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter your password",
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(16),
                            child: FaIcon(
                              FontAwesomeIcons.lock,
                              size: 20,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () => obscurePassword.toggle(),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: FaIcon(
                                obscurePassword.value
                                    ? FontAwesomeIcons.eyeSlash
                                    : FontAwesomeIcons.eye,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
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
                    )),

                    const SizedBox(height: 32),

                    // Sign In Button
                    Obx(() => GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : () => controller.signIn(
                        emailController.text,
                        passwordController.text,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: controller.isLoading.value
                              ? null
                              : LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.accentColor],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          color: controller.isLoading.value
                              ? AppTheme.cardColor
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: controller.isLoading.value
                              ? []
                              : [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: controller.isLoading.value
                              ? [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Signing In...",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ]
                              : [
                            const FaIcon(
                              FontAwesomeIcons.arrowRightToBracket,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Sign In",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),

                    const SizedBox(height: 32),

                    // Sign Up Link
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.signUp),
                      child: RichText(
                        text: TextSpan(
                          text: "New to Treasure Hunt? ",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: "Create Account",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
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
      ),
    );
  }
}