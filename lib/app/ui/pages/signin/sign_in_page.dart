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
      backgroundColor: const Color(0xFF000000),
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
                        color: const Color(0xFF0F52BA),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F52BA).withOpacity(0.5),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.userShield,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Title
                    Text(
                      "Welcome Back",
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
                      "Sign in to your account",
                      style: GoogleFonts.rubik(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF87CEEB),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 56),

                    // Email Input Field
                    Container(
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
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          color: Colors.white,
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
                              color: const Color(0xFF87CEEB),
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
                    ),

                    const SizedBox(height: 20),

                    // Password Input Field
                    Obx(() => Container(
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
                        controller: passwordController,
                        obscureText: obscurePassword.value,
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          color: Colors.white,
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
                              color: const Color(0xFF87CEEB),
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
                                color: Colors.white60,
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
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFF0F52BA),
                          borderRadius: BorderRadius.circular(16),
                          border: controller.isLoading.value
                              ? Border.all(
                            color: const Color(0xFF0F52BA).withOpacity(0.3),
                            width: 1,
                          )
                              : null,
                          boxShadow: controller.isLoading.value
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
                          children: controller.isLoading.value
                              ? [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Color(0xFF87CEEB),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Signing In...",
                              style: GoogleFonts.rubik(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ]
                              : [
                            const FaIcon(
                              FontAwesomeIcons.arrowRightToBracket,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Sign In",
                              style: GoogleFonts.rubik(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
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
                          style: GoogleFonts.rubik(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(
                              text: "Create Account",
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
      ),
    );
  }
}
