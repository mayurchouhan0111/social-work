// lib/app/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../app_theme.dart';
import '../../../routes/app_pages.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _rotationController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoGlowAnimation;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _loadingPulse;
  late Animation<double> _rotationAnimation;
  late Animation<double> _continuousPulse;

  bool _showTypewriter = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSequence();
  }

  void _initializeAnimations() {
    // Primary animation controller
    _primaryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Continuous rotation controller
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Particle effects controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Pulse controller for loading indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Logo animations with enhanced curves
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _logoGlowAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: Curves.easeInOut,
      ),
    );

    // Title animations
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    // Loading indicator animations
    _loadingPulse = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _primaryController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _rotationController,
    );

    _continuousPulse = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startSequence() {
    _primaryController.forward();

    // Trigger typewriter animation after title appears
    Timer(const Duration(milliseconds: 1800), () {
      setState(() {
        _showTypewriter = true;
      });
    });

    // Navigate after complete sequence
    Timer(const Duration(milliseconds: 4000), () {
      _navigateToNextScreen();
    });
  }

  void _navigateToNextScreen() async {
    try {
      final AuthController authController = Get.find<AuthController>();

      if (authController.isUserAuthenticated) {
        Get.offAllNamed(Routes.mainNav);
      } else {
        Get.offAllNamed(Routes.signIn);
      }
    } catch (e) {
      print('AuthController not found: $e');
      Get.offAllNamed(Routes.signIn);
    }
  }

  Widget _buildEnhancedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _primaryController,
        _rotationController,
        _pulseController
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    Color(0xFF0F2027),  // Very dark teal
                    Color(0xFF185951),  // Primary teal
                    Color(0xFF2C5530),  // Dark green accent
                    Color(0xFF203A43),  // Dark blue-green
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  // Inner glow effect
                  BoxShadow(
                    color: const Color(0xFF185951).withOpacity(
                      0.6 * _logoGlowAnimation.value,
                    ),
                    blurRadius: 35 * _logoGlowAnimation.value,
                    spreadRadius: 8 * _logoGlowAnimation.value,
                    offset: const Offset(0, 0),
                  ),
                  // Outer orange glow
                  BoxShadow(
                    color: const Color(0xFFFF8800).withOpacity(
                      0.3 * _logoGlowAnimation.value,
                    ),
                    blurRadius: 50 * _logoGlowAnimation.value,
                    spreadRadius: 3 * _logoGlowAnimation.value,
                    offset: const Offset(0, 10),
                  ),
                  // Deep shadow for depth
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: _rotationAnimation.value * 0.15,
                child: Transform.scale(
                  scale: _continuousPulse.value * 0.05 + 0.95,
                  child: const Icon(
                    Icons.search_rounded,
                    size: 90,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(12, (index) {
            final angle = (_particleController.value * 2 * math.pi) +
                (index * math.pi / 6);
            final radius = 140 + (math.sin(_particleController.value * 6) * 30);
            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;
            final opacity = (math.sin(_particleController.value * 4 + index) + 1) / 2;

            return Transform.translate(
              offset: Offset(x, y),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF8800).withOpacity(opacity * 0.8),
                      const Color(0xFFFF8800).withOpacity(0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTypewriterTagline() {
    if (!_showTypewriter) return const SizedBox.shrink();

    return SizedBox(
      width: 300,
      child: DefaultTextStyle(
        style: GoogleFonts.rubik(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: Colors.white60,
          letterSpacing: 1.2,
          height: 1.3,
        ),
        child: AnimatedTextKit(
          totalRepeatCount: 1,
          isRepeatingAnimation: false,
          animatedTexts: [
            TypewriterAnimatedText(
              "Find what you've lost",
              speed: const Duration(milliseconds: 80),
              cursor: '|',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 2.0,
            colors: [
              Color(0xFF0A0A0A),  // Almost black center
              Color(0xFF0F1419),  // Very dark blue-gray
              Color(0xFF0D1B2A),  // Dark navy
              Color(0xFF000000),  // Pure black edges
            ],
            stops: [0.0, 0.4, 0.8, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Enhanced background particles
            Center(child: _buildAdvancedParticles()),

            // Subtle grid overlay for tech feel
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40"><defs><pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse"><path d="M 40 0 L 0 0 0 40" fill="none" stroke="%23185951" stroke-width="0.5" opacity="0.1"/></pattern></defs><rect width="100%" height="100%" fill="url(%23grid)"/></svg>'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.05,
                ),
              ),
            ),

            // Main content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Enhanced animated logo
                    _buildEnhancedLogo(),

                    const SizedBox(height: 60),

                    // App title with enhanced styling
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: Text(
                          "Treasure Hunt",
                          style: GoogleFonts.rubik(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1.0,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF185951).withOpacity(0.8),
                                offset: const Offset(0, 4),
                                blurRadius: 12,
                              ),
                              Shadow(
                                color: const Color(0xFFFF8800).withOpacity(0.3),
                                offset: const Offset(0, 8),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Typewriter animated tagline
                    _buildTypewriterTagline(),

                    const SizedBox(height: 100),

                    // Enhanced loading indicator
                    ScaleTransition(
                      scale: _loadingPulse,
                      child: AnimatedBuilder(
                        animation: _continuousPulse,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF185951).withOpacity(0.1),
                                  const Color(0xFF185951).withOpacity(0.3),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(
                                color: const Color(0xFFFF8800).withOpacity(
                                  0.4 * _continuousPulse.value,
                                ),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF8800).withOpacity(
                                    0.4 * _continuousPulse.value,
                                  ),
                                  blurRadius: 25,
                                  spreadRadius: 3,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF185951).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                strokeWidth: 3.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF8800),
                                ),
                              ),
                            ),
                          );
                        },
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

  @override
  void dispose() {
    _primaryController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}
