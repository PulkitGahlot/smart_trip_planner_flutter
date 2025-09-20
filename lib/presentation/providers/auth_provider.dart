import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:itinerary_ai/data/saved_conversation.dart';
import 'package:uuid/uuid.dart';

final authProvider =
    StateNotifierProvider<AuthProvider, AuthState>((ref) => AuthProvider());

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
  AuthProvider() : super(AuthState()) {
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

    await Future.delayed(const Duration(seconds: 3));

    final userId = _uuid.v4();
    await _sessionBox.put('isLoggedIn', true);
    await _sessionBox.put('userEmail', email);
    await _sessionBox.put('userId', userId);
    
    await Hive.openBox<SavedConversation>('itineraries_$userId');
    await Hive.openBox('profile_$userId');

    state = state.copyWith(isLoading: false, currentUserEmail: email);
    if (context.mounted) context.go('/home');
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    await Future.delayed(const Duration(seconds: 3));

    final userId = _sessionBox.get('userId') ?? _uuid.v4();
    await _sessionBox.put('isLoggedIn', true);
    await _sessionBox.put('userEmail', email);
    await _sessionBox.put('userId', userId);

    await Hive.openBox<SavedConversation>('itineraries_$userId');
    await Hive.openBox('profile_$userId');

    state = state.copyWith(isLoading: false, currentUserEmail: email);
    if (context.mounted) context.go('/home');
  }
  
  Future<void> logout(BuildContext context) async {
    final userId = _sessionBox.get('userId');
    
    if (userId != null) {
      final itinerariesBoxName = 'itineraries_$userId';
      if (Hive.isBoxOpen(itinerariesBoxName)) {
        // must specify the type when getting the box reference to close it
        await Hive.box<SavedConversation>(itinerariesBoxName).close();
      }

      final profileBoxName = 'profile_$userId';
      if (Hive.isBoxOpen(profileBoxName)) {
        await Hive.box(profileBoxName).close();
      }
    }

    await _sessionBox.clear(); 
    state = AuthState(); 
    if (context.mounted) context.go('/signup');
  }
}