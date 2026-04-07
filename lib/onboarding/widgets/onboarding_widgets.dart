import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';  
// ─────────────────────────────────────────────────────────────────────────────
// Gradient Button — the primary CTA across all onboarding screens
// ─────────────────────────────────────────────────────────────────────────────

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Gradient gradient;
  final bool loading;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradient = AppColors.gradientPrimary,
    this.loading = false,
    this.icon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: const BorderRadius.all(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Progress Indicator — dots at top of each onboarding screen
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingProgress extends StatelessWidget {
  final int total;
  final int current; // 0-indexed

  const OnboardingProgress({
    super.key,
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        final isDone = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : isDone
                    ? AppColors.teal
                    : AppColors.border,
            borderRadius: const BorderRadius.all(AppRadius.full),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Shell — consistent page wrapper with back button + progress
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingShell extends StatelessWidget {
  final Widget child;
  final int step;
  final int totalSteps;
  final VoidCallback? onBack;
  final bool showProgress;

  const OnboardingShell({
    super.key,
    required this.child,
    required this.step,
    required this.totalSteps,
    this.onBack,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  if (onBack != null)
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.all(AppRadius.md),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.body,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  const Spacer(),
                  if (showProgress)
                    OnboardingProgress(total: totalSteps, current: step),
                  const Spacer(),
                  const SizedBox(width: 40), // balance
                ],
              ),
            ),
            // Content
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating Badge — used for "RTL" tag on Arabic/Urdu cards
// ─────────────────────────────────────────────────────────────────────────────

class FloatingBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const FloatingBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Check — checkmark that draws itself when a card is selected
// ─────────────────────────────────────────────────────────────────────────────

class AnimatedCheck extends StatefulWidget {
  final bool visible;
  final Color color;

  const AnimatedCheck({super.key, required this.visible, required this.color});

  @override
  State<AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<AnimatedCheck>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(covariant AnimatedCheck old) {
    super.didUpdateWidget(old);
    if (widget.visible && !old.visible) _ctrl.forward();
    if (!widget.visible && old.visible) _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      ),
    );
  }
}
