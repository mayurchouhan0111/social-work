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
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo Section
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: AppTheme.accent2,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent2.withOpacity(0.5),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.userShield,
                        size: 64,
                        color: AppTheme.primaryText,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Title
                    Text(
                      "Welcome Back",
                      style: GoogleFonts.archivo(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryText,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Sign in to your account",
                      style: GoogleFonts.archivo(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.accent1,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 56),

                    // Email Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.accent2.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.surface.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.archivo(
                          fontSize: 16,
                          color: AppTheme.primaryText,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          hintText: "Enter your email",
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(16),
                            child: FaIcon(
                              FontAwesomeIcons.envelope,
                              size: 18,
                              color: AppTheme.accent1,
                            ),
                          ),
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
                              color: AppTheme.accent2,
                              width: 2,
                            ),
                          ),
                          labelStyle: GoogleFonts.archivo(
                            color: AppTheme.accent1,
                            fontSize: 16,
                          ),
                          floatingLabelStyle: GoogleFonts.archivo(
                            color: AppTheme.accent1,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          hintStyle: GoogleFonts.archivo(
                            color: AppTheme.secondaryText,
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
                    ),

                    const SizedBox(height: 20),

                    // Password Input Field
                    Obx(() => Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.accent2.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.surface.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: obscurePassword.value,
                        style: GoogleFonts.archivo(
                          fontSize: 16,
                          color: AppTheme.primaryText,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Enter your password",
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          prefixIcon: Container(
                            padding: const EdgeInsets.all(16),
                            child: FaIcon(
                              FontAwesomeIcons.lock,
                              size: 18,
                              color: AppTheme.accent1,
                            ),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () => obscurePassword.toggle(),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: FaIcon(
                                obscurePassword.value
                                    ? FontAwesomeIcons.eyeSlash
                                    : FontAwesomeIcons.eye,
                                size: 16,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          ),
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
                              color: AppTheme.accent2,
                              width: 2,
                            ),
                          ),
                          labelStyle: GoogleFonts.archivo(
                            color: AppTheme.accent1,
                            fontSize: 16,
                          ),
                          floatingLabelStyle: GoogleFonts.archivo(
                            color: AppTheme.accent1,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          hintStyle: GoogleFonts.archivo(
                            color: AppTheme.secondaryText,
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
                    )),

                    const SizedBox(height: 40),

                    // Sign In Button
                    Obx(() => GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : () => controller.signIn(
                        emailController.text,
                        passwordController.text,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: controller.isLoading.value
                              ? AppTheme.surface
                              : AppTheme.accent2,
                          borderRadius: BorderRadius.circular(16),
                          border: controller.isLoading.value
                              ? Border.all(
                            color: AppTheme.accent2.withOpacity(0.3),
                            width: 1,
                          )
                              : null,
                          boxShadow: controller.isLoading.value
                              ? []
                              : [
                            BoxShadow(
                              color: AppTheme.accent2.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
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
                                valueColor: AlwaysStoppedAnimation(
                                  AppTheme.accent1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Signing In...",
                              style: GoogleFonts.archivo(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          ]
                              : [
                            const FaIcon(
                              FontAwesomeIcons.arrowRightToBracket,
                              size: 18,
                              color: AppTheme.primaryText,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Sign In",
                              style: GoogleFonts.archivo(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),

                    const SizedBox(height: 40),

                    // Sign Up Link
                    TextButton(
                      onPressed: () => Get.toNamed(Routes.signUp),
                      child: RichText(
                        text: TextSpan(
                          text: "New to Treasure Hunt? ",
                          style: GoogleFonts.archivo(
                            fontSize: 16,
                            color: AppTheme.secondaryText,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(
                              text: "Create Account",
                              style: GoogleFonts.archivo(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accent1,
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