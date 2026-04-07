import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SplashScreen
//
// Plays a 3-part animation sequence on first launch:
//   1. Background gradient slides in (0ms → 600ms)
//   2. Logo + wordmark fades and scales up (400ms → 1000ms)
//   3. Tagline fades in (800ms → 1200ms)
//   4. Auto-navigates to /onboarding/language after 2800ms
//
// Uses three separate AnimationControllers so each part can be
// timed independently — same concept as CSS animation-delay.
// ─────────────────────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Three separate controllers — one per animation phase
  late AnimationController _bgCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _tagCtrl;

  late Animation<double> _bgScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _tagOpacity;
  late Animation<Offset> _tagSlide;

  @override
  void initState() {
    super.initState();

    // Phase 1 — background scale
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bgScale = Tween<double>(begin: 1.15, end: 1.0).animate(
      CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut),
    );

    // Phase 2 — logo fade + scale
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );

    // Phase 3 — tagline slide + fade
    _tagCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tagOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut),
    );
    _tagSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut));

    _playSequence();
  }

  Future<void> _playSequence() async {
    // Start bg immediately
    _bgCtrl.forward();

    // Logo starts 300ms in
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    _logoCtrl.forward();

    // Tagline starts 700ms after logo
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    _tagCtrl.forward();

    // Navigate after 2.4 seconds total
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    context.go('/onboarding/language');
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgCtrl, _logoCtrl, _tagCtrl]),
        builder: (context, _) {
          return ScaleTransition(
            scale: _bgScale,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F2A5C), // navy
                    Color(0xFF1A56DB), // blue
                    Color(0xFF7C3AED), // purple
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles in background
                  Positioned(
                    top: -80,
                    right: -60,
                    child: Opacity(
                      opacity: 0.15,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -120,
                    left: -80,
                    child: Opacity(
                      opacity: 0.1,
                      child: Container(
                        width: 360,
                        height: 360,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Small dot pattern
                  const Positioned(
                    top: 100,
                    left: 30,
                    child: Opacity(
                      opacity: 0.2,
                      child: _DotGrid(rows: 4, cols: 4),
                    ),
                  ),
                  const Positioned(
                    bottom: 140,
                    right: 30,
                    child: Opacity(
                      opacity: 0.15,
                      child: _DotGrid(rows: 3, cols: 5),
                    ),
                  ),

                  // Centre content
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo mark
                        FadeTransition(
                          opacity: _logoOpacity,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: _LogoMark(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Wordmark
                        FadeTransition(
                          opacity: _logoOpacity,
                          child: const Text(
                            'LinguaVerse',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Tagline
                        SlideTransition(
                          position: _tagSlide,
                          child: FadeTransition(
                            opacity: _tagOpacity,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius:
                                    const BorderRadius.all(AppRadius.full),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                              child: const Text(
                                'Learn smarter. Speak naturally.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom loader dots
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: _tagOpacity,
                      child: Center(
                        child: _PulsingDots(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Logo mark widget — the "LV" geometric mark ───────────────────────────────
class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: const BorderRadius.all(AppRadius.xxl),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
            // Globe icon
            const Text(
              '🌐',
              style: TextStyle(fontSize: 38),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Decorative dot grid ──────────────────────────────────────────────────────
class _DotGrid extends StatelessWidget {
  final int rows;
  final int cols;
  const _DotGrid({required this.rows, required this.cols});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        rows,
        (r) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            cols,
            (c) => Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated loading dots ────────────────────────────────────────────────────
class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        // Each dot starts its pulse at a different phase
        final delayed = Tween<double>(begin: 0.3, end: 1.0).animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: Interval(i * 0.2, 0.6 + i * 0.2, curve: Curves.easeInOut),
          ),
        );
        return AnimatedBuilder(
          animation: delayed,
          builder: (_, __) => Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(delayed.value),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
