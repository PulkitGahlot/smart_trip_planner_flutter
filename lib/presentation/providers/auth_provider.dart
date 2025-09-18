import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

final authProvider =
    StateNotifierProvider<AuthProvider, AuthState>((ref) => AuthProvider(ref));

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final String? currentUserEmail;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.currentUserEmail,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? currentUserEmail,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentUserEmail: currentUserEmail ?? this.currentUserEmail,
    );
  }
}

class AuthProvider extends StateNotifier<AuthState> {
  final Ref _ref;
  AuthProvider(this._ref) : super(AuthState()) {
    _loadCurrentUser();
  }

  final _sessionBox = Hive.box('session');
  final _uuid = const Uuid();

  void _loadCurrentUser() {
    final email = _sessionBox.get('userEmail');
    if (email != null) {
      state = state.copyWith(currentUserEmail: email);
    }
  }

  Future<void> signUp(
      BuildContext context, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Simulate network request
    await Future.delayed(const Duration(seconds: 3));

    // In a real app, you would have user registration logic here.
    // For this app, we generate a unique ID for the user.
    final userId = _uuid.v4();
    await _sessionBox.put('isLoggedIn', true);
    await _sessionBox.put('userEmail', email);
    await _sessionBox.put('userId', userId);
    await Hive.openBox('itineraries_$userId'); // Open user-specific box
    await Hive.openBox('profile_$userId'); // Open user-specific profile box

    state = state.copyWith(isLoading: false, currentUserEmail: email);
    if (context.mounted) context.go('/home');
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Simulate network request & validation
    await Future.delayed(const Duration(seconds: 3));

    // Mock login logic: always successful for demonstration
    final userId = _sessionBox.get('userId') ?? _uuid.v4(); // Reuse or create ID
    await _sessionBox.put('isLoggedIn', true);
    await _sessionBox.put('userEmail', email);
    await _sessionBox.put('userId', userId);
    await Hive.openBox('itineraries_$userId');
    await Hive.openBox('profile_$userId');

    state = state.copyWith(isLoading: false, currentUserEmail: email);
    if (context.mounted) context.go('/home');
  }

  Future<void> logout(BuildContext context) async {
    final userId = _sessionBox.get('userId');
    await _sessionBox.clear(); // Clears isLoggedIn, userEmail, etc.
    
    // Close user-specific boxes on logout
    if (userId != null) {
      final itinerariesBoxName = 'itineraries_$userId';
      if (Hive.isBoxOpen(itinerariesBoxName)) {
        await Hive.box(itinerariesBoxName).close();
      }
      final profileBoxName = 'profile_$userId';
      if (Hive.isBoxOpen(profileBoxName)) {
        await Hive.box(profileBoxName).close();
      }
    }
    
    state = AuthState(); // Reset state
    if (context.mounted) context.go('/signup');
  }
}