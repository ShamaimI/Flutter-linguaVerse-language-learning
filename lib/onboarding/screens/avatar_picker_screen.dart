import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../models/avatar_model.dart';
import '../widgets/onboarding_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AvatarPickerScreen
//
// Step 2 of onboarding. User picks an AI tutor avatar + names it.
//
// Design decisions:
//   - 2-column grid with staggered entrance animations
//   - Selected card pops with the avatar's accent colour
//   - Bottom sheet expands to show name input after selection
//   - Preview panel shows the avatar speaking their intro line
// ─────────────────────────────────────────────────────────────────────────────

class AvatarPickerScreen extends StatefulWidget {
  final String? languageCode;

  const AvatarPickerScreen({super.key, this.languageCode});

  @override
  State<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends State<AvatarPickerScreen>
    with TickerProviderStateMixin {
  String? _selectedId;
  final _nameCtrl = TextEditingController();
  bool _showNameField = false;

  late AnimationController _entranceCtrl;
  late List<Animation<double>> _cardFades;
  late List<Animation<Offset>> _cardSlides;

  late AnimationController _previewCtrl;
  late Animation<double> _previewFade;
  late Animation<Offset> _previewSlide;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Stagger 10 cards across the animation timeline
    _cardFades = List.generate(kAvatars.length, (i) {
      final start = (i * 0.08).clamp(0.0, 0.85);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entranceCtrl, curve: Interval(start, end, curve: Curves.easeOut)),
      );
    });
    _cardSlides = List.generate(kAvatars.length, (i) {
      final start = (i * 0.08).clamp(0.0, 0.85);
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(
            parent: _entranceCtrl, curve: Interval(start, end, curve: Curves.easeOutCubic)),
      );
    });

    // Preview panel animation
    _previewCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _previewFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _previewCtrl, curve: Curves.easeOut),
    );
    _previewSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _previewCtrl, curve: Curves.easeOutCubic));

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _previewCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _select(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedId = id;
      _showNameField = true;
      // Prefill name with default avatar name
      final avatar = kAvatars.firstWhere((a) => a.id == id);
      _nameCtrl.text = avatar.name;
    });
    _previewCtrl.forward(from: 0);
  }

  void _continue() {
    if (_selectedId == null) return;
    HapticFeedback.mediumImpact();
    context.go(
      '/onboarding/level-test',
      extra: {
        'languageCode': widget.languageCode,
        'avatarId': _selectedId,
        'avatarName': _nameCtrl.text.trim().isEmpty
            ? kAvatars.firstWhere((a) => a.id == _selectedId).name
            : _nameCtrl.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedId != null
        ? kAvatars.firstWhere((a) => a.id == _selectedId)
        : null;

    return OnboardingShell(
      step: 1,
      totalSteps: 5,
      onBack: () => context.go('/onboarding/language'),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.lPurple,
                    borderRadius: BorderRadius.all(AppRadius.full),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🤖', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text(
                        'Step 2 of 5',
                        style: TextStyle(
                          color: AppColors.purple,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Pick your AI tutor',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Each one has a different teaching style.',
                  style: TextStyle(fontSize: 14, color: AppColors.sub),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Preview panel — appears when avatar selected
          if (_showNameField && selected != null)
            SlideTransition(
              position: _previewSlide,
              child: FadeTransition(
                opacity: _previewFade,
                child: _AvatarPreview(
                  avatar: selected,
                  nameCtrl: _nameCtrl,
                  languageCode: widget.languageCode ?? 'es',
                ),
              ),
            ),

          if (_showNameField) const SizedBox(height: AppSpacing.md),

          // Avatar grid
          Expanded(
            child: AnimatedBuilder(
              animation: _entranceCtrl,
              builder: (context, _) {
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: kAvatars.length,
                  itemBuilder: (context, i) {
                    return SlideTransition(
                      position: _cardSlides[i],
                      child: FadeTransition(
                        opacity: _cardFades[i],
                        child: _AvatarCard(
                          avatar: kAvatars[i],
                          isSelected: _selectedId == kAvatars[i].id,
                          onTap: () => _select(kAvatars[i].id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg,
            ),
            child: AnimatedOpacity(
              opacity: _selectedId != null ? 1.0 : 0.35,
              duration: const Duration(milliseconds: 300),
              child: GradientButton(
                label: _selectedId != null
                    ? 'Continue with ${_nameCtrl.text.isEmpty ? selected?.name ?? '' : _nameCtrl.text}'
                    : 'Choose your tutor first',
                gradient: AppColors.gradientPrimary,
                onTap: _selectedId != null ? _continue : null,
                icon: Icons.arrow_forward_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar card in the grid ───────────────────────────────────────────────────

class _AvatarCard extends StatefulWidget {
  final AvatarModel avatar;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarCard({
    required this.avatar,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AvatarCard> createState() => _AvatarCardState();
}

class _AvatarCardState extends State<_AvatarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
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
    final av = widget.avatar;
    final sel = widget.isSelected;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: sel ? av.accentColor : AppColors.cardBg,
            borderRadius: const BorderRadius.all(AppRadius.xl),
            border: Border.all(
              color: sel ? av.accentColor : AppColors.border,
              width: sel ? 2.5 : 1,
            ),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: av.accentColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji in coloured circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: sel
                        ? Colors.white.withOpacity(0.2)
                        : av.bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      av.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Name
                Text(
                  av.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : AppColors.dark,
                  ),
                ),
                const SizedBox(height: 3),

                // Personality pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sel
                        ? Colors.white.withOpacity(0.2)
                        : av.accentColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(AppRadius.full),
                  ),
                  child: Text(
                    av.personality,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : av.accentColor,
                    ),
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

// ── Preview panel — shows intro + name field ──────────────────────────────────

class _AvatarPreview extends StatelessWidget {
  final AvatarModel avatar;
  final TextEditingController nameCtrl;
  final String languageCode;

  const _AvatarPreview({
    required this.avatar,
    required this.nameCtrl,
    required this.languageCode,
  });

  String get _introLine {
    final langName = {
      'es': 'Spanish',
      'fr': 'French',
      'ar': 'Arabic',
      'ur': 'Urdu',
      'en': 'English',
    }[languageCode] ?? 'the language';
    return '${avatar.emoji}  "Hi! I\'m ${avatar.name}. I\'ll be your $langName tutor. ${avatar.tagline}."';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              avatar.accentColor.withOpacity(0.08),
              avatar.accentColor.withOpacity(0.03),
            ],
          ),
          borderRadius: const BorderRadius.all(AppRadius.xl),
          border: Border.all(color: avatar.accentColor.withOpacity(0.25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intro speech bubble
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: avatar.bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(avatar.emoji,
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: const BorderRadius.only(
                          topRight: AppRadius.lg,
                          bottomLeft: AppRadius.lg,
                          bottomRight: AppRadius.lg,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _introLine,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.body,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Custom name field
              const Text(
                'Give your tutor a name (optional)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.sub,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  hintText: avatar.name,
                  hintStyle: const TextStyle(color: AppColors.muted),
                  filled: true,
                  fillColor: AppColors.cardBg,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(AppRadius.md),
                    borderSide: BorderSide(
                        color: avatar.accentColor.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(AppRadius.md),
                    borderSide:
                        BorderSide(color: avatar.accentColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
