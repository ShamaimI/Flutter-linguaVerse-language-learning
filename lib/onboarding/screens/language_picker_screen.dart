import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/language_model.dart';
import '../widgets/onboarding_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LanguagePickerScreen
//
// Step 1 of onboarding. User picks a language to learn.
//
// Design decisions:
//   - Cards animate in with staggered slide-up on first render
//   - Selected card expands to show the fun fact
//   - RTL badge shown on Arabic and Urdu
//   - CTA button only becomes active once a selection is made
//   - Haptic feedback on selection
// ─────────────────────────────────────────────────────────────────────────────

class LanguagePickerScreen extends StatefulWidget {
  const LanguagePickerScreen({super.key});

  @override
  State<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends State<LanguagePickerScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCode;

  // Staggered entrance controller — runs once on mount
  late AnimationController _entranceCtrl;
  late List<Animation<Offset>> _slideAnims;
  late List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Each card has its own staggered slide + fade
    _slideAnims = List.generate(kLanguages.length, (i) {
      final start = i * 0.12;
      final end = start + 0.55;
      return Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      ));
    });

    _fadeAnims = List.generate(kLanguages.length, (i) {
      final start = i * 0.12;
      final end = start + 0.45;
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
            curve: Curves.easeOut),
      ));
    });

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _select(String code) {
    HapticFeedback.selectionClick(); // subtle haptic on selection
    setState(() => _selectedCode = code);
  }

  void _continue() {
    if (_selectedCode == null) return;
    HapticFeedback.mediumImpact();
    context.go('/onboarding/avatar', extra: {'languageCode': _selectedCode});
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      step: 0,
      totalSteps: 5,
      showProgress: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Header
            _buildHeader(),
            const SizedBox(height: AppSpacing.xl),

            // Language cards
            Expanded(
              child: AnimatedBuilder(
                animation: _entranceCtrl,
                builder: (context, _) {
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: kLanguages.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      return SlideTransition(
                        position: _slideAnims[i],
                        child: FadeTransition(
                          opacity: _fadeAnims[i],
                          child: _LanguageCard(
                            language: kLanguages[i],
                            isSelected: _selectedCode == kLanguages[i].code,
                            onTap: () => _select(kLanguages[i].code),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // CTA
            AnimatedOpacity(
              opacity: _selectedCode != null ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 300),
              child: GradientButton(
                label: _selectedCode != null
                    ? 'Continue with ${kLanguages.firstWhere((l) => l.code == _selectedCode).name}'
                    : 'Pick a language to continue',
                onTap: _selectedCode != null ? _continue : null,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emoji + chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: const BoxDecoration(
            color: AppColors.lBlue,
            borderRadius: BorderRadius.all(AppRadius.full),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🌍', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text(
                'Step 1 of 5',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'What do you want\nto learn?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.dark,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Our AI tutor adapts to your pace and style.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.sub,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

// ── Language card widget ──────────────────────────────────────────────────────

class _LanguageCard extends StatefulWidget {
  final LanguageModel language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<_LanguageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final selected = widget.isSelected;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _pressScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: selected ? lang.accentColor.withOpacity(0.06) : AppColors.cardBg,
            borderRadius: const BorderRadius.all(AppRadius.lg),
            border: Border.all(
              color: selected ? lang.accentColor : AppColors.border,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: lang.accentColor.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main row: flag + names + check
                Row(
                  children: [
                    // Flag in a coloured circle
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: lang.bgColor,
                        borderRadius: const BorderRadius.all(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(
                          lang.flag,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Language names
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                lang.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Native name
                              Text(
                                lang.nativeName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.muted,
                                  fontStyle: lang.isRtl
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                lang.speakers,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.sub,
                                ),
                              ),
                              if (lang.isRtl) ...[
                                const SizedBox(width: 6),
                                const FloatingBadge(
                                  label: 'RTL',
                                  color: AppColors.purple,
                                  bg: AppColors.lPurple,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Animated check
                    AnimatedCheck(
                      visible: selected,
                      color: lang.accentColor,
                    ),
                  ],
                ),

                // Fun fact — expands when selected
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: lang.accentColor.withOpacity(0.08),
                              borderRadius: const BorderRadius.all(AppRadius.md),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 15,
                                  color: lang.accentColor,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    lang.funFact,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: lang.accentColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
