import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:itinerary_ai/presentation/screens/auth/login_screen.dart';
import 'package:itinerary_ai/presentation/screens/auth/signup_screen.dart';
import 'package:itinerary_ai/presentation/screens/home/home_screen.dart';
import 'package:itinerary_ai/presentation/screens/itinerary/creating_itinerary_screen.dart';
import 'package:itinerary_ai/presentation/screens/itinerary/follow_up_chat_screen.dart';
import 'package:itinerary_ai/presentation/screens/itinerary/itinerary_created_screen.dart';
import 'package:itinerary_ai/presentation/screens/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          // Check if user is logged in
          final box = Hive.box('session');
          final bool isLoggedIn = box.get('isLoggedIn', defaultValue: false);
          return isLoggedIn ? const HomeScreen() : const SignUpScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/creating-itinerary',
        builder: (context, state) {
          final prompt = state.extra as String;
          return CreatingItineraryScreen(prompt: prompt);
        },
      ),
      GoRoute(
        path: '/itinerary-created',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ItineraryCreatedScreen(
            itinerary: data['itinerary'],
            wasVoiceInput: data['wasVoiceInput'],
            originalPrompt: data['originalPrompt'], // Extract the prompt
          );
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          // Extract the data passed from the previous screen
          final initialData = state.extra as Map<String, String>;
          // Pass it to the FollowUpChatScreen
          return FollowUpChatScreen(initialData: initialData);
        },
      ),
    ],
  );
  return router;
});