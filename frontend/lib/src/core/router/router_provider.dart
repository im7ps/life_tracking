import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/daily_log/presentation/screens/daily_log_list_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/consultant/presentation/consultant_screen.dart';
import 'router_notifier.dart';
import '../../features/action/presentation/portfolio_screen.dart';
import '../../features/dashboard/presentation/category_management_screen.dart';
import '../../features/dashboard/presentation/checkpoint_review_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';

import '../../features/settings/presentation/settings_screen.dart'; // New import
import '../../features/account/presentation/account_screen.dart'; // New import
import '../../features/info/presentation/info_screen.dart'; // New import
import '../../features/faq/presentation/faq_screen.dart'; // New import

part 'router_provider.g.dart';

@riverpod
GoRouter router(Ref ref) {
  // Otteniamo l'istanza del Notifier che implementa Listenable.
  // IMPORTANTE: Questo richiede che il build_runner sia stato eseguito con successo.
  final notifier = ref.watch(routerNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier, // Il router ascolta questo oggetto
    redirect: (context, state) {
      final loc = state.matchedLocation;
      print("DEBUG: Router redirect check for location: $loc");

      // Usiamo lo stato interno del notifier che è sincronizzato con l'auth e onboarding
      if (notifier.isLoading) {
        print("DEBUG: Router is waiting for loading...");
        return null;
      }

      final isLoggedIn = notifier.isLoggedIn;
      final isOnboardingSeen = notifier.isOnboardingSeen;

      print(
        "DEBUG: State -> LoggedIn: $isLoggedIn, OnboardingSeen: $isOnboardingSeen",
      );

      final isLoggingIn = loc == '/login';
      final isOnboarding = loc == '/onboarding';

      // 1. Check Auth First
      if (!isLoggedIn) {
        print("DEBUG: Not logged in, redirecting to /login");
        return isLoggingIn ? null : '/login';
      }

      // 2. Check Onboarding (Only if logged in)
      if (!isOnboardingSeen) {
        print("DEBUG: Onboarding not seen, redirecting to /onboarding");
        return isOnboarding ? null : '/onboarding';
      }

      // 3. Prevent access to login if everything is done,
      // but ALLOW /onboarding if requested manually (for re-watching)
      if (isLoggingIn) {
        print("DEBUG: Already logged in, redirecting to / (Dashboard)");
        return '/';
      }

      if (isOnboarding && isLoggedIn) {
        print("DEBUG: Manual onboarding access allowed");
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login', builder: (context, state) => const LoginScreen()
      ),
      GoRoute(
        path: '/', builder: (context, state) => const DashboardScreen()
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/daily-logs',
        builder: (context, state) => const DailyLogListScreen(),
      ),
      GoRoute(
        path: '/consultant',
        builder: (context, state) => const ConsultantScreen(),
      ),
      GoRoute(
        path: '/portfolio',
        builder: (context, state) => const PortfolioScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/info',
        builder: (context, state) => const InfoScreen(),
      ),
      GoRoute(
        path: '/faq',
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoryManagementScreen(),
      ),
      GoRoute(
        path: '/checkpoint-review',
        builder: (context, state) => const CheckpointReviewScreen(),
      ),
    ],
  );
}
