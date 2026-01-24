import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart'; // Added
import 'package:dio/dio.dart'; // Added
import '../../core/api/api_client.dart';
import '../../app/routes/app_routes.dart';
import '../../core/utils/platform_utils.dart';

/// AuthController - Supabase OAuth only
/// Role is fetched from backend, not trusted from frontend
class AuthController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ApiClient _apiClient = Get.find<ApiClient>();
  final box = GetStorage();

  // Observable auth state - single source of truth
  var isLoading = false.obs;
  var isReady = false.obs;
  final Rx<Map<String, dynamic>?> user = Rx<Map<String, dynamic>?>(null);
  final Rx<Map<String, dynamic>?> profile = Rx<Map<String, dynamic>?>(null);
  final Rx<String?> role = Rx<String?>(null);

  var _hasCheckedSession = false;

  @override
  void onInit() {
    super.onInit();
    // Check session on controller initialization (only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkSessionAndRedirect();
    });
  }

  /// Check if session exists and redirect accordingly
  void checkSessionAndRedirect() {
    if (_hasCheckedSession) return;
    _hasCheckedSession = true;

    final session = _supabase.auth.currentSession;

    if (session != null) {
      print('[AUTH] Session exists, processing...');
      _processSession(session);
    } else {
      print('[AUTH] No session, staying on login');
    }
  }

  /// Process session from deep link (bypasses the session check guard)
  /// Called when OAuth returns via deep link on mobile
  void processSessionFromDeepLink(Session session) {
    print('[AUTH] Processing session from deep link...');
    _hasCheckedSession =
        true; // Mark as checked to prevent duplicate processing
    _processSession(session);
  }

  /// Login with Google via Supabase OAuth
  Future<void> login() async {
    try {
      isLoading.value = true;

      // Use platform-specific redirect URL
      final redirectUrl = PlatformUtils.getOAuthRedirectUrl();
      print('[AUTH] Starting OAuth login with redirect: $redirectUrl');
      print('[AUTH] Platform: ${PlatformUtils.platformName}');

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
    } catch (e) {
      Get.snackbar('Error', 'Login gagal: $e');
      print('[AUTH] Login error: $e');
      isLoading.value = false;
    }
  }

  /// Process session after OAuth callback
  Future<void> _processSession(Session session) async {
    try {
      isLoading.value = true;
      print(
          '[AUTH] Session user: ${session.user.id}, Email: ${session.user.email}');

      final name = session.user.userMetadata?['full_name'] ??
          session.user.userMetadata?['name'] ??
          session.user.email?.split('@')[0] ??
          'User';

      final photoUrl = session.user.userMetadata?['avatar_url'] ??
          session.user.userMetadata?['picture'];

      print('[AUTH] Derived name: $name');
      print('[AUTH] Photo URL: $photoUrl');

      // Call backend login - userId extracted from JWT
      print('[AUTH] Calling backend login...');
      final response = await _apiClient.dio.post('/auth/login', data: {
        'name': name,
        'photoUrl': photoUrl, // Send photoUrl to backend
      });
      print('[AUTH] Backend response: ${response.statusCode}');

      final data = response.data;
      if (data == null) throw Exception('Empty response from backend');

      if (data['status'] == 'needs_profile') {
        print('[AUTH] Status: needs_profile');
        // New user - needs role selection
        await box.write('email', session.user.email ?? '');
        await box.write('name', name);
        Get.offAllNamed(Routes.ROLE_SELECTION);
      } else if (data['status'] == 'success') {
        print('[AUTH] Status: success');
        // Existing user - save role from backend (not frontend)
        final userData = data['user'];
        if (userData == null) throw Exception('User data is null');

        await box.write('user', userData);

        // Update observable state
        user.value = userData;
        role.value = userData['role'];
        profile.value = userData;
        isReady.value = true;

        _redirectByRole(userData['role']);
      } else {
        Get.snackbar('Error', data['pesan'] ?? 'Login gagal');
      }
    } catch (e, stack) {
      print('[AUTH] Process session error: $e');
      print('[AUTH] Stack trace: $stack');

      // Provide specific error messages for common issues
      String errorMsg = 'Terjadi kesalahan saat login';
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMsg =
              'Koneksi terlalu lambat. Pastikan internet stabil dan coba lagi.';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMsg =
              'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        } else if (e.response?.statusCode == 500) {
          errorMsg =
              'Server sedang mengalami gangguan. Silakan coba lagi nanti.';
        }
      }

      Get.snackbar(
        'Error',
        errorMsg,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch user profile from backend (source of truth for role)
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await _apiClient.dio.get('/users/me');
      if (response.data['status'] == 'success') {
        final userData = response.data['user'];
        await box.write('user', userData);

        // Update observable state
        user.value = userData;
        role.value = userData['role'];
        profile.value = userData;
        isReady.value = true;

        return userData;
      }
    } catch (e) {
      print('[AUTH] Fetch profile error: $e');
    }
    return null;
  }

  /// Get current user role from storage (synced from backend)
  String? get userRole => role.value ?? box.read('user')?['role'];

  /// Check if current user can create orders (farmers only)
  bool get canCreateOrder {
    final currentRole = userRole;
    return currentRole == 'farmer' || currentRole == 'warehouse';
  }

  /// Check if current user can apply to orders (workers only)
  bool get canApplyToOrder => userRole == 'worker';

  void _redirectByRole(String? role) {
    if (role == 'worker' || role == 'farmer' || role == 'warehouse') {
      Get.offAllNamed(Routes.MAIN);
    } else {
      Get.offAllNamed(Routes.ROLE_SELECTION);
    }
  }

  /// Logout - clears session only
  Future<void> logout() async {
    await _supabase.auth.signOut();
    await box.erase();

    // Clear observable state
    user.value = null;
    role.value = null;
    profile.value = null;
    isReady.value = false;

    _hasCheckedSession = false;
    Get.offAllNamed(Routes.LOGIN);
  }
}
