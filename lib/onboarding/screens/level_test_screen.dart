import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../widgets/onboarding_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LevelTestScreen
//
// Step 3 of onboarding. 3 quick MCQ questions to place the user at
// A1 (Beginner), A2 (Elementary), B1 (Intermediate), or B2+ (Advanced).
//
// Design decisions:
//   - Question slides in from the right, old question slides left on advance
//   - Each option has a press animation
//   - Correct/wrong colour feedback (green/red flash) before advancing
//   - Results screen reveals the CEFR level with a celebration
//   - Skip button available — defaults to A1
// ─────────────────────────────────────────────────────────────────────────────

// Question data — hardcoded here, real app generates these via Claude API
class _Question {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const _Question({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

const _spanishQuestions = [
  _Question(
    prompt: 'What does "Hola, ¿cómo estás?" mean?',
    options: ['Goodbye, how are you?', 'Hello, how are you?', 'Hello, what is your name?', 'Good morning, nice to meet you'],
    correctIndex: 1,
    explanation: '"Hola" = Hello and "¿cómo estás?" = how are you?',
  ),
  _Question(
    prompt: 'Which sentence is grammatically correct?',
    options: ['Yo como la manzana', 'Yo comer la manzana', 'Yo comes la manzana', 'Yo comiendo la manzana'],
    correctIndex: 0,
    explanation: '"Yo como" is the correct conjugation of "comer" (to eat) for yo (I).',
  ),
  _Question(
    prompt: 'Complete: "Si hubiera sabido, ___ venido antes."',
    options: ['hubiera', 'habría', 'haya', 'había'],
    correctIndex: 1,
    explanation: 'The conditional perfect "habría" is used in the result clause of a past counterfactual.',
  ),
];

class LevelTestScreen extends StatefulWidget {
  final String? languageCode;
  final String? avatarId;
  final String? avatarName;

  const LevelTestScreen({
    super.key,
    this.languageCode,
    this.avatarId,
    this.avatarName,
  });

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen>
    with TickerProviderStateMixin {
  int _currentQ = 0;
  int _score = 0;
  int? _selectedOption;
  bool _showingFeedback = false;
  bool _showResults = false;

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideIn;
  late Animation<Offset> _slideOut;
  late Animation<double> _fadeIn;

  late AnimationController _feedbackCtrl;
  late Animation<double> _feedbackScale;

  late AnimationController _resultsCtrl;
  late Animation<double> _resultsFade;
  late Animation<Offset> _resultsSlide;

  final _questions = _spanishQuestions; // TODO: dynamic based on languageCode

  @override
  void initState() {
    super.initState();

    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _slideIn = Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideOut = Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0))
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeInCubic));
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();

    _feedbackCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _feedbackScale = Tween<double>(begin: 1.0, end: 1.04).animate(
        CurvedAnimation(parent: _feedbackCtrl, curve: Curves.easeInOut));

    _resultsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _resultsFade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _resultsCtrl, curve: Curves.easeOut));
    _resultsSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _resultsCtrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _feedbackCtrl.dispose();
    _resultsCtrl.dispose();
    super.dispose();
  }

  void _selectOption(int index) async {
    if (_showingFeedback) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedOption = index;
      _showingFeedback = true;
    });
    _feedbackCtrl.forward().then((_) => _feedbackCtrl.reverse());

    final isCorrect = index == _questions[_currentQ].correctIndex;
    if (isCorrect) _score++;

    // Show feedback for 900ms then advance
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_currentQ < _questions.length - 1) {
      await _slideCtrl.reverse();
      setState(() {
        _currentQ++;
        _selectedOption = null;
        _showingFeedback = false;
      });
      _slideCtrl.forward(from: 0);
    } else {
      // Show results
      setState(() => _showResults = true);
      _resultsCtrl.forward();
    }
  }

  String get _cefrLevel {
    if (_score == 0) return 'A1';
    if (_score == 1) return 'A2';
    if (_score == 2) return 'B1';
    return 'B2';
  }

  String get _cefrLabel {
    switch (_cefrLevel) {
      case 'A1': return 'Beginner';
      case 'A2': return 'Elementary';
      case 'B1': return 'Intermediate';
      default:   return 'Upper Intermediate';
    }
  }

  String get _cefrDescription {
    switch (_cefrLevel) {
      case 'A1': return 'We\'ll start with the absolute basics — greetings, numbers, and everyday words.';
      case 'A2': return 'You know the essentials. We\'ll build on that with common phrases and simple conversations.';
      case 'B1': return 'Solid foundation! We\'ll work on fluency, tenses, and real-world conversations.';
      default:   return 'Impressive! We\'ll challenge you with advanced grammar, idioms, and nuanced expression.';
    }
  }

  Color get _cefrColor {
    switch (_cefrLevel) {
      case 'A1': return AppColors.teal;
      case 'A2': return AppColors.primary;
      case 'B1': return AppColors.purple;
      default:   return AppColors.orange;
    }
  }

  void _continue() {
    HapticFeedback.mediumImpact();
    context.go('/onboarding/goal', extra: {
      'languageCode': widget.languageCode,
      'avatarId': widget.avatarId,
      'avatarName': widget.avatarName,
      'cefrLevel': _cefrLevel,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) return _buildResults();
    return _buildQuestion();
  }

  Widget _buildQuestion() {
    final q = _questions[_currentQ];

    return OnboardingShell(
      step: 2,
      totalSteps: 5,
      onBack: () => context.go('/onboarding/avatar'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            // Step chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.lTeal,
                borderRadius: BorderRadius.all(AppRadius.full),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🧪', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    'Step 3 of 5 · Level Test',
                    style: TextStyle(
                      color: AppColors.teal,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Quick placement\ntest',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.dark,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Question ${_currentQ + 1} of ${_questions.length}  —  no right or wrong answer matters for the journey',
              style: const TextStyle(fontSize: 13, color: AppColors.sub),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Question card — slides in
            Expanded(
              child: SlideTransition(
                position: _selectedOption == null ? _slideIn : _slideOut,
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: ScaleTransition(
                    scale: _feedbackScale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0F2A5C), Color(0xFF1A56DB)],
                            ),
                            borderRadius: const BorderRadius.all(AppRadius.xl),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Text(
                            q.prompt,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Options
                        ...List.generate(q.options.length, (i) {
                          return _OptionTile(
                            text: q.options[i],
                            state: _getOptionState(i),
                            onTap: () => _selectOption(i),
                            label: String.fromCharCode(65 + i), // A, B, C, D
                          );
                        }),

                        if (_showingFeedback && _selectedOption != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          AnimatedOpacity(
                            opacity: _showingFeedback ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: _selectedOption == q.correctIndex
                                    ? AppColors.lTeal
                                    : AppColors.lRed,
                                borderRadius: const BorderRadius.all(AppRadius.lg),
                                border: Border.all(
                                  color: _selectedOption == q.correctIndex
                                      ? AppColors.teal
                                      : AppColors.red,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedOption == q.correctIndex
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.info_outline_rounded,
                                    color: _selectedOption == q.correctIndex
                                        ? AppColors.teal
                                        : AppColors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      q.explanation,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _selectedOption == q.correctIndex
                                            ? AppColors.teal
                                            : AppColors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Skip option
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Center(
                child: GestureDetector(
                  onTap: () => context.go('/onboarding/goal', extra: {
                    'languageCode': widget.languageCode,
                    'avatarId': widget.avatarId,
                    'avatarName': widget.avatarName,
                    'cefrLevel': 'A1',
                  }),
                  child: const Text(
                    'Skip test — start as Beginner',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _OptionState _getOptionState(int i) {
    if (!_showingFeedback) return _OptionState.idle;
    if (i == _questions[_currentQ].correctIndex) return _OptionState.correct;
    if (i == _selectedOption) return _OptionState.wrong;
    return _OptionState.dimmed;
  }

  Widget _buildResults() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _resultsFade,
          child: SlideTransition(
            position: _resultsSlide,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Spacer(),

                  // Level badge
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_cefrColor, _cefrColor.withOpacity(0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _cefrColor.withOpacity(0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _cefrLevel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    '$_cefrLabel Level',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$_score out of ${_questions.length} correct',
                    style: const TextStyle(fontSize: 14, color: AppColors.muted),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: _cefrColor.withOpacity(0.07),
                      borderRadius: const BorderRadius.all(AppRadius.xl),
                      border: Border.all(color: _cefrColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      _cefrDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.body,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const Spacer(),

                  GradientButton(
                    label: 'Looks good — let\'s continue',
                    gradient: LinearGradient(
                      colors: [_cefrColor, _cefrColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: _continue,
                    icon: Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GestureDetector(
                    onTap: () => setState(() {
                      _currentQ = 0;
                      _score = 0;
                      _selectedOption = null;
                      _showingFeedback = false;
                      _showResults = false;
                      _slideCtrl.forward(from: 0);
                    }),
                    child: const Text(
                      'Retake the test',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.sub,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionTile extends StatelessWidget {
  final String text;
  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionTile({
    required this.text,
    required this.label,
    required this.state,
    required this.onTap,
  });

  Color get _bg {
    switch (state) {
      case _OptionState.correct: return AppColors.lTeal;
      case _OptionState.wrong:   return AppColors.lRed;
      case _OptionState.dimmed:  return AppColors.surface;
      default:                   return AppColors.cardBg;
    }
  }

  Color get _borderColor {
    switch (state) {
      case _OptionState.correct: return AppColors.teal;
      case _OptionState.wrong:   return AppColors.red;
      case _OptionState.dimmed:  return AppColors.border;
      default:                   return AppColors.border;
    }
  }

  Color get _labelBg {
    switch (state) {
      case _OptionState.correct: return AppColors.teal;
      case _OptionState.wrong:   return AppColors.red;
      default:                   return AppColors.surface;
    }
  }

  Color get _labelColor {
    switch (state) {
      case _OptionState.correct:
      case _OptionState.wrong:   return Colors.white;
      default:                   return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GestureDetector(
        onTap: state == _OptionState.idle ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: const BorderRadius.all(AppRadius.lg),
            border: Border.all(color: _borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _labelBg,
                  borderRadius: const BorderRadius.all(AppRadius.sm),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _labelColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: state == _OptionState.dimmed
                        ? AppColors.muted
                        : AppColors.body,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (state == _OptionState.correct)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.teal, size: 20),
              if (state == _OptionState.wrong)
                const Icon(Icons.cancel_rounded, color: AppColors.red, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
