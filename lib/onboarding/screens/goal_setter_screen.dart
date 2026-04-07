import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../widgets/onboarding_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GoalSetterScreen
//
// Step 4 of onboarding. User sets their daily XP goal and reminder time.
//
// Design decisions:
//   - Three goal cards (Casual / Regular / Intense) with XP and time targets
//   - Selected card expands with a motivational message
//   - Optional reminder toggle with time picker
//   - Summary card at bottom shows what the full commitment looks like
// ─────────────────────────────────────────────────────────────────────────────

class _GoalOption {
  final String id;
  final String label;
  final String emoji;
  final int dailyXP;
  final String timePerDay;
  final String tagline;
  final Color color;
  final Color bg;

  const _GoalOption({
    required this.id,
    required this.label,
    required this.emoji,
    required this.dailyXP,
    required this.timePerDay,
    required this.tagline,
    required this.color,
    required this.bg,
  });
}

const _goals = [
  _GoalOption(
    id: 'casual',
    label: 'Casual',
    emoji: '🌱',
    dailyXP: 10,
    timePerDay: '5 min/day',
    tagline: 'A little every day goes a long way.',
    color: AppColors.teal,
    bg: AppColors.lTeal,
  ),
  _GoalOption(
    id: 'regular',
    label: 'Regular',
    emoji: '⚡',
    dailyXP: 20,
    timePerDay: '10 min/day',
    tagline: 'The sweet spot for steady progress.',
    color: AppColors.primary,
    bg: AppColors.lBlue,
  ),
  _GoalOption(
    id: 'intense',
    label: 'Intense',
    emoji: '🔥',
    dailyXP: 50,
    timePerDay: '20 min/day',
    tagline: 'For learners who mean business.',
    color: AppColors.orange,
    bg: AppColors.lOrange,
  ),
];

class GoalSetterScreen extends StatefulWidget {
  final String? languageCode;
  final String? avatarId;
  final String? avatarName;
  final String? cefrLevel;

  const GoalSetterScreen({
    super.key,
    this.languageCode,
    this.avatarId,
    this.avatarName,
    this.cefrLevel,
  });

  @override
  State<GoalSetterScreen> createState() => _GoalSetterScreenState();
}

class _GoalSetterScreenState extends State<GoalSetterScreen>
    with SingleTickerProviderStateMixin {
  String _selectedGoalId = 'regular'; // default
  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  late AnimationController _entranceCtrl;
  late List<Animation<double>> _cardFades;
  late List<Animation<Offset>> _cardSlides;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardFades = List.generate(3, (i) {
      final start = i * 0.15;
      final end = start + 0.5;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
              curve: Curves.easeOut),
        ),
      );
    });
    _cardSlides = List.generate(3, (i) {
      final start = i * 0.15;
      final end = start + 0.5;
      return Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
        CurvedAnimation(
          parent: _entranceCtrl,
          curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
              curve: Curves.easeOutCubic),
        ),
      );
    });
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  _GoalOption get _selected =>
      _goals.firstWhere((g) => g.id == _selectedGoalId);

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  void _continue() {
    HapticFeedback.mediumImpact();
    context.go('/onboarding/complete', extra: {
      'languageCode': widget.languageCode,
      'avatarId': widget.avatarId,
      'avatarName': widget.avatarName,
      'cefrLevel': widget.cefrLevel,
      'goalId': _selectedGoalId,
      'dailyXP': _selected.dailyXP,
      'reminderEnabled': _reminderEnabled,
      'reminderHour': _reminderTime.hour,
      'reminderMinute': _reminderTime.minute,
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingShell(
      step: 3,
      totalSteps: 5,
      onBack: () => context.go('/onboarding/level-test'),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),
            _buildHeader(),
            const SizedBox(height: AppSpacing.xl),

            // Goal cards
            AnimatedBuilder(
              animation: _entranceCtrl,
              builder: (context, _) {
                return Column(
                  children: List.generate(_goals.length, (i) {
                    return SlideTransition(
                      position: _cardSlides[i],
                      child: FadeTransition(
                        opacity: _cardFades[i],
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _GoalCard(
                            goal: _goals[i],
                            isSelected: _selectedGoalId == _goals[i].id,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedGoalId = _goals[i].id);
                            },
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Reminder toggle
            _buildReminderSection(),
            const SizedBox(height: AppSpacing.lg),

            // Commitment summary
            _buildSummaryCard(),
            const SizedBox(height: AppSpacing.lg),

            GradientButton(
              label: 'Start Learning',
              gradient: LinearGradient(
                colors: [_selected.color, _selected.color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: _continue,
              icon: Icons.rocket_launch_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: const BoxDecoration(
            color: AppColors.lOrange,
            borderRadius: BorderRadius.all(AppRadius.full),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎯', style: TextStyle(fontSize: 14)),
              SizedBox(width: 6),
              Text(
                'Step 4 of 5 · Set Your Goal',
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'How much do\nyou want to learn?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.dark,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'You can always change this later in Settings.',
          style: TextStyle(fontSize: 14, color: AppColors.sub),
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      decoration: BoxDecoration(
        color: _reminderEnabled ? AppColors.lBlue : AppColors.surface,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        border: Border.all(
          color: _reminderEnabled ? AppColors.primary : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _reminderEnabled ? AppColors.lBlue : AppColors.surface,
                    borderRadius: const BorderRadius.all(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: _reminderEnabled ? AppColors.primary : AppColors.muted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily reminder',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                      Text(
                        _reminderEnabled
                            ? 'Remind me at ${_reminderTime.format(context)}'
                            : 'Off',
                        style: const TextStyle(fontSize: 13, color: AppColors.sub),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _reminderEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _reminderEnabled = v),
                ),
              ],
            ),
          ),
          // Time picker row — only visible when enabled
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            child: _reminderEnabled
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: const BorderRadius.all(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                color: AppColors.primary, size: 18),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              _reminderTime.format(context),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Tap to change',
                              style:
                                  TextStyle(fontSize: 12, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final lang = {
      'es': 'Spanish', 'fr': 'French',
      'ar': 'Arabic',  'ur': 'Urdu', 'en': 'English',
    }[widget.languageCode ?? 'es'] ?? 'your language';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary.withOpacity(0.85),
          ],
        ),
        borderRadius: const BorderRadius.all(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your plan',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _SummaryItem(
                label: 'Learning',
                value: lang,
                icon: '🌍',
              ),
              const SizedBox(width: AppSpacing.md),
              _SummaryItem(
                label: 'Level',
                value: widget.cefrLevel ?? 'A1',
                icon: '📊',
              ),
              const SizedBox(width: AppSpacing.md),
              _SummaryItem(
                label: 'Daily goal',
                value: '${_selected.dailyXP} XP',
                icon: _selected.emoji,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Goal card widget ──────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  final _GoalOption goal;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? goal.color.withOpacity(0.06) : AppColors.cardBg,
          borderRadius: const BorderRadius.all(AppRadius.lg),
          border: Border.all(
            color: isSelected ? goal.color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: goal.color.withOpacity(0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? goal.color.withOpacity(0.12) : goal.bg,
                    borderRadius: const BorderRadius.all(AppRadius.md),
                  ),
                  child: Center(
                    child: Text(goal.emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? goal.color : AppColors.dark,
                        ),
                      ),
                      Text(
                        goal.timePerDay,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.sub,
                        ),
                      ),
                    ],
                  ),
                ),
                // XP badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? goal.color : goal.bg,
                    borderRadius: const BorderRadius.all(AppRadius.full),
                  ),
                  child: Text(
                    '${goal.dailyXP} XP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : goal.color,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AnimatedCheck(visible: isSelected, color: goal.color),
              ],
            ),
            // Tagline expands when selected
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        goal.tagline,
                        style: TextStyle(
                          fontSize: 13,
                          color: goal.color,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
