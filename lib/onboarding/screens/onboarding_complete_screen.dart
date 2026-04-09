import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../models/avatar_model.dart';
import '../../models/language_model.dart';
import '../widgets/onboarding_widgets.dart';

class OnboardingCompleteScreen extends StatefulWidget {
  final String? languageCode;
  final String? avatarId;
  final String? avatarName;
  final String? cefrLevel;
  final String? goalId;
  final int? dailyXP;
  final bool reminderEnabled;
  final int? reminderHour;
  final int? reminderMinute;

  const OnboardingCompleteScreen({
    super.key,
    this.languageCode,
    this.avatarId,
    this.avatarName,
    this.cefrLevel,
    this.goalId,
    this.dailyXP,
    this.reminderEnabled = false,
    this.reminderHour,
    this.reminderMinute,
  });

  @override
  State<OnboardingCompleteScreen> createState() =>
      _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _heroCtrl;
  late AnimationController _cardsCtrl;
  late AnimationController _ctaCtrl;

  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late List<Animation<double>> _cardFades;
  late List<Animation<Offset>> _cardSlides;
  late Animation<double> _ctaFade;
  late Animation<Offset> _ctaSlide;
  late Animation<double> _bgFade;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _bgFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut));

    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));
    _heroSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    _cardsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _cardFades = List.generate(3, (i) {
      final start = i * 0.22;
      final end = (start + 0.55).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _cardsCtrl,
          curve: Interval(start, end, curve: Curves.easeOut)));
    });
    _cardSlides = List.generate(3, (i) {
      final start = i * 0.22;
      final end = (start + 0.55).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _cardsCtrl,
              curve: Interval(start, end, curve: Curves.easeOutCubic)));
    });

    _ctaCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _ctaFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOut));
    _ctaSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(parent: _ctaCtrl, curve: Curves.easeOutCubic));

    _runSequence();
  }

  Future<void> _runSequence() async {
    _bgCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    _heroCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    _cardsCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _ctaCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _heroCtrl.dispose();
    _cardsCtrl.dispose();
    _ctaCtrl.dispose();
    super.dispose();
  }

  AvatarModel get _avatar => widget.avatarId != null
      ? kAvatars.firstWhere((a) => a.id == widget.avatarId,
          orElse: () => kAvatars.first)
      : kAvatars.first;

  LanguageModel get _language => widget.languageCode != null
      ? kLanguages.firstWhere((l) => l.code == widget.languageCode,
          orElse: () => kLanguages.first)
      : kLanguages.first;

  String get _tutorName =>
      (widget.avatarName?.isNotEmpty == true) ? widget.avatarName! : _avatar.name;

  String get _cefrLabel {
    switch (widget.cefrLevel) {
      case 'A1': return 'Beginner';
      case 'A2': return 'Elementary';
      case 'B1': return 'Intermediate';
      case 'B2': return 'Upper Intermediate';
      default:   return 'Beginner';
    }
  }

  String get _goalEmoji {
    switch (widget.goalId) {
      case 'casual':  return '🌱';
      case 'intense': return '🔥';
      default:        return '⚡';
    }
  }

  Future<void> _launch() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgCtrl, _heroCtrl, _cardsCtrl, _ctaCtrl]),
        builder: (context, _) {
          return Stack(
            children: [
              // Gradient background
              FadeTransition(
                opacity: _bgFade,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0F172A),
                        Color(0xFF0F2A5C),
                        Color(0xFF1A56DB),
                      ],
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Decorative blobs
              FadeTransition(
                opacity: _bgFade,
                child: Stack(
                  children: [
                    Positioned(
                      top: -60,
                      right: -80,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.purple.withOpacity(0.18),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 80,
                      left: -60,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.teal.withOpacity(0.12),
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 200,
                      left: -30,
                      child: Opacity(
                        opacity: 0.12,
                        child: _DotGrid(rows: 5, cols: 4),
                      ),
                    ),
                    const Positioned(
                      bottom: 200,
                      right: 20,
                      child: Opacity(
                        opacity: 0.1,
                        child: _DotGrid(rows: 4, cols: 5),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Avatar + headline
                      SlideTransition(
                        position: _heroSlide,
                        child: FadeTransition(
                          opacity: _heroFade,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius:
                                      const BorderRadius.all(AppRadius.full),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.25)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('🎉', style: TextStyle(fontSize: 14)),
                                    SizedBox(width: 6),
                                    Text(
                                      'Setup complete',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: _avatar.accentColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _avatar.accentColor.withOpacity(0.5),
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _avatar.accentColor.withOpacity(0.3),
                                      blurRadius: 30,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(_avatar.emoji,
                                      style: const TextStyle(fontSize: 44)),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),

                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                    height: 1.25,
                                  ),
                                  children: [
                                    const TextSpan(text: 'You\'re all set!\n'),
                                    TextSpan(
                                      text: _tutorName,
                                      style: TextStyle(color: _avatar.accentColor),
                                    ),
                                    const TextSpan(text: ' is ready\nto teach you '),
                                    TextSpan(
                                      text: _language.name,
                                      style: TextStyle(
                                          color: _language.accentColor ==
                                                  const Color(0xFF012169)
                                              ? AppColors.tealLight
                                              : Color((_language.accentColor.value &
                                                      0xFFFFFF) |
                                                  0xFFFFFFFF)),
                                    ),
                                    const TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Summary cards
                      ..._buildSummaryCards(),

                      const Spacer(flex: 1),

                      // CTA
                      SlideTransition(
                        position: _ctaSlide,
                        child: FadeTransition(
                          opacity: _ctaFade,
                          child: Column(
                            children: [
                              GradientButton(
                                label: 'Start my first lesson  🚀',
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.85),
                                  ],
                                ),
                                onTap: _launch,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setBool('onboardingComplete', true);
                                  if (mounted) context.go('/home');
                                },
                                child: Text(
                                  'Explore the app first',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildSummaryCards() {
    final items = [
      _SummaryData(
        icon: _language.flag,
        label: 'Language',
        value: _language.name,
        sub: _cefrLabel,
        color: AppColors.tealLight,
      ),
      _SummaryData(
        icon: _avatar.emoji,
        label: 'Your tutor',
        value: _tutorName,
        sub: _avatar.personality,
        color: _avatar.accentColor,
      ),
      _SummaryData(
        icon: _goalEmoji,
        label: 'Daily goal',
        value: '${widget.dailyXP ?? 20} XP',
        sub: widget.reminderEnabled
            ? 'Reminder at ${widget.reminderHour?.toString().padLeft(2, '0') ?? '08'}:${widget.reminderMinute?.toString().padLeft(2, '0') ?? '00'}'
            : 'No reminder set',
        color: AppColors.orangeLight,
      ),
    ];

    return [
      Row(
        children: List.generate(items.length, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : AppSpacing.xs,
                right: i == items.length - 1 ? 0 : AppSpacing.xs,
              ),
              child: SlideTransition(
                position: _cardSlides[i],
                child: FadeTransition(
                  opacity: _cardFades[i],
                  child: _SummaryCard(data: items[i]),
                ),
              ),
            ),
          );
        }),
      ),
    ];
  }
}

class _SummaryData {
  final String icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _SummaryData({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });
}

class _SummaryCard extends StatelessWidget {
  final _SummaryData data;
  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.55),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            data.sub,
            style: TextStyle(
              fontSize: 10,
              color: data.color.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

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