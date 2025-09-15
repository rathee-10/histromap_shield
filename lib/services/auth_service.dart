import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

/// Authentication service for handling user authentication with Supabase
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Get current user profile from public.user_profiles
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail(
    String email,
    String password, {
    String? fullName,
    String? role = 'explorer',
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? email.split('@')[0],
          'role': role,
        },
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  /// Sign in with Google OAuth
  Future<bool> signInWithGoogle() async {
    try {
      return await _client.auth.signInWithOAuth(OAuthProvider.google);
    } catch (error) {
      throw Exception('Google sign-in failed: $error');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? bio,
    String? avatarUrl,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user');

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _client.from('user_profiles').update(updates).eq('id', user.id);
    } catch (error) {
      throw Exception('Profile update failed: $error');
    }
  }

  /// Listen to authentication state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;
}
