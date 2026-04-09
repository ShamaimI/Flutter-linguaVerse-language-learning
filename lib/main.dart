import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:linguaverse/firebase_options.dart';

import 'package:linguaverse/auth/lib/auth/login_screen.dart';
import 'package:linguaverse/auth/lib/auth/signup_screen.dart';
import 'package:linguaverse/theme/app_theme.dart';
import 'package:linguaverse/onboarding/screens/splash_screen.dart';
import 'package:linguaverse/onboarding/screens/language_picker_screen.dart';
import 'package:linguaverse/onboarding/screens/avatar_picker_screen.dart';
import 'package:linguaverse/onboarding/screens/level_test_screen.dart';
import 'package:linguaverse/onboarding/screens/goal_setter_screen.dart';
import 'package:linguaverse/onboarding/screens/onboarding_complete_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const LinguaVerseApp());
}

final _router = GoRouter(
  initialLocation: '/login',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding/language',
      name: 'language',
      builder: (context, state) => const LanguagePickerScreen(),
    ),
    GoRoute(
      path: '/onboarding/avatar',
      name: 'avatar',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return AvatarPickerScreen(
          languageCode: extra['languageCode'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/onboarding/level-test',
      name: 'level-test',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return LevelTestScreen(
          languageCode: extra['languageCode'] as String?,
          avatarId:     extra['avatarId']     as String?,
          avatarName:   extra['avatarName']   as String?,
        );
      },
    ),
    GoRoute(
      path: '/onboarding/goal',
      name: 'goal',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return GoalSetterScreen(
          languageCode: extra['languageCode'] as String?,
          avatarId:     extra['avatarId']     as String?,
          avatarName:   extra['avatarName']   as String?,
          cefrLevel:    extra['cefrLevel']    as String?,
        );
      },
    ),
    GoRoute(
      path: '/onboarding/complete',
      name: 'onboarding-complete',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return OnboardingCompleteScreen(
          languageCode:    extra['languageCode']    as String?,
          avatarId:        extra['avatarId']        as String?,
          avatarName:      extra['avatarName']      as String?,
          cefrLevel:       extra['cefrLevel']       as String?,
          goalId:          extra['goalId']          as String?,
          dailyXP:         extra['dailyXP']         as int?,
          reminderEnabled: extra['reminderEnabled'] as bool? ?? false,
          reminderHour:    extra['reminderHour']    as int?,
          reminderMinute:  extra['reminderMinute']  as int?,
        );
      },
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const _HomeScreenPlaceholder(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('404 — Page not found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    ),
  ),
);

class LinguaVerseApp extends StatelessWidget {
  const LinguaVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LinguaVerse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}

class _HomeScreenPlaceholder extends StatelessWidget {
  const _HomeScreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: const BorderRadius.all(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🌐', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Onboarding Complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'The Home Screen is built in Week 2.\nThis placeholder confirms the router is working.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.sub,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                OutlinedButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.replay_rounded, size: 18),
                  label: const Text('Back to Login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(220, 48),
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