import 'package:flutter/material.dart';
import 'package:traiteur_management/core/widgets/loading_widget.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';
import '../../generated/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _textController;
  late AnimationController _ornamentController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _ornamentAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Rotation animation for the ornamental border
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Scale animation for the logo
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // Fade animation for the background
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Ornament animation
    _ornamentController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _ornamentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _ornamentController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() async {
    // Check if widget is still mounted before starting animations
    if (!mounted) return;

    // Start background fade
    _fadeController.forward();

    // Start rotation (continuous)
    _rotationController.repeat();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return; // Check again after delay

    // Start ornament animation
    _ornamentController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return; // Check again after delay

    // Start logo scale
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return; // Check again after delay

    // Start text animation
    _textController.forward();
  }

  @override
  void dispose() {
    // Cancel all animations first
    _rotationController.stop();
    _scaleController.stop();
    _fadeController.stop();
    _textController.stop();
    _ornamentController.stop();

    // Then dispose them
    _rotationController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _textController.dispose();
    _ornamentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2ECC71), // Fresh green
              Color(0xFF3498DB), // Clean blue
              // Color(0xFFE67E22), // Warm orange
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Stack(
                children: [
                  // Animated background pattern
                  _buildBackgroundPattern(),

                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated ornamental border with logo
                        if(appLocalizations != null) ...[

                          _buildAnimatedLogo(size),

                          const SizedBox(height: 48),

                          // Animated company name
                          _buildAnimatedTitle(appLocalizations),

                          const SizedBox(height: 16),

                          // Animated subtitle
                          _buildAnimatedSubtitle(appLocalizations),

                          const SizedBox(height: 64),

                          // Animated loading indicator
                          _buildAnimatedLoadingIndicator(),

                          const SizedBox(height: 24),

                          // Loading text
                          _buildLoadingText(appLocalizations),
                        ],
                      ],
                    ),
                  ),

                  // Bottom tagline
                  if (appLocalizations != null)
                    _buildBottomTagline(appLocalizations),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return AnimatedBuilder(
      animation: _ornamentAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _ornamentAnimation.value * 0.1,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(
              painter: ArabicPatternPainter(
                progress: _ornamentAnimation.value,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _scaleAnimation, _ornamentAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating ornamental border
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Opacity(
                    opacity: _ornamentAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 3,
                        ),
                      ),
                      child: CustomPaint(
                        painter: OrnamentalBorderPainter(
                          color: AppColors.primary,
                          progress: _ornamentAnimation.value,
                        ),
                      ),
                    ),
                  ),
                ),

                // Inner logo circle
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'DK',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                colors: [Color(0xFF2ECC71), Color(0xFFE67E22)],
                              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            letterSpacing: 2,
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 3,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2ECC71), Color(0xFFE67E22)],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(2)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Traiteur',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            letterSpacing: 1,
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
      },
    );
  }

  Widget _buildAnimatedTitle(AppLocalizations appLocalizations) {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _textAnimation.value)),
          child: Opacity(
            opacity: _textAnimation.value,
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ).createShader(bounds),
                  child: const Text(
                    'DAR EL KHIR',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primary,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSubtitle(AppLocalizations appLocalizations) {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _textAnimation.value)),
          child: Opacity(
            opacity: _textAnimation.value * 0.8,
            child: const Text(
              'Traiteur Premium',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                letterSpacing: 2,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLoadingIndicator() {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _textAnimation.value,
          child: const SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                // Outer ring
                LoadingWidget(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingText(AppLocalizations appLocalizations) {
    return AnimatedBuilder(
      animation: _textAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _textAnimation.value * 0.7,
          child: Text(
            appLocalizations.loadingMessage,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomTagline(AppLocalizations appLocalizations) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _textAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - _textAnimation.value)),
            child: Opacity(
              opacity: _textAnimation.value * 0.6,
              child: Text(
                appLocalizations.professionalCateringManagement,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for ornamental border
class OrnamentalBorderPainter extends CustomPainter {
  final Color color;
  final double progress;

  OrnamentalBorderPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(progress)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw ornamental patterns around the circle
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final x1 = center.dx + (radius - 15) * math.cos(angle);
      final y1 = center.dy + (radius - 15) * math.sin(angle);
      final x2 = center.dx + (radius - 5) * math.cos(angle);
      final y2 = center.dy + (radius - 5) * math.sin(angle);

      if (i / 12 <= progress) {
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);

        // Draw small decorative circles
        canvas.drawCircle(
          Offset(x2, y2),
          2,
          Paint()..color = color.withOpacity(progress)..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for background Arabic pattern
class ArabicPatternPainter extends CustomPainter {
  final double progress;
  final Color color;

  ArabicPatternPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(progress * 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw geometric Islamic patterns
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const patternSize = 40.0;

    for (double x = -patternSize; x < size.width + patternSize; x += patternSize * 2) {
      for (double y = -patternSize; y < size.height + patternSize; y += patternSize * 2) {
        if ((x + y) / (patternSize * 4) <= progress) {
          _drawGeometricPattern(canvas, paint, Offset(x, y), patternSize);
        }
      }
    }
  }

  void _drawGeometricPattern(Canvas canvas, Paint paint, Offset center, double size) {
    // Draw a simple geometric star pattern
    final path = Path();
    const points = 8;
    final outerRadius = size / 3;
    final innerRadius = size / 6;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}