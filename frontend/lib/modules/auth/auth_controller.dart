import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart'; // Added
import 'package:dio/dio.dart'; // Added
import 'package:app_links/app_links.dart'; // Added for Deep Linking
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

  // Deep Link State
  String? _pendingJobId;
  var _hasCheckedSession = false;

  @override
  void onInit() {
    super.onInit();
    // Initialize deep links listener immediately
    _initDeepLinks();

    // PERSISTENCE: Restore pending job ID if exists (survived app kill)
    try {
      final storedJobId = box.read('pending_job_id');
      if (storedJobId != null && _pendingJobId == null) {
        _pendingJobId = storedJobId;
        print('[AUTH] Restored pending_job_id from storage: $_pendingJobId');
      }
    } catch (e) {
      print('[AUTH] Storage Read Error (onInit): $e');
    }
  }

  /// Called by SplashController to determine where to go
  void handleAppLaunch() {
    print('[AUTH] Handling App Launch...');

    // PERSISTENCE: Double-check storage in case it was set just now
    try {
      if (_pendingJobId == null) {
        final stored = box.read('pending_job_id');
        if (stored != null) {
          _pendingJobId = stored;
          print('[AUTH] handleAppLaunch restored pending_job_id: $stored');
        }
      }
    } catch (e) {
      print('[AUTH] Storage Read Error (handleAppLaunch): $e');
    }

    // Check session
    final session = _supabase.auth.currentSession;
    if (session != null) {
      print(
          '[AUTH] Session found. Processing session for user: ${session.user.email}');
      _processSession(session);
    } else {
      print('[AUTH] No session found. Redirecting to Login.');
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  /// Clear pending job ID from storage and memory
  /// Called by JobDetailController when job is successfully loaded/viewed
  void clearPendingJobId() {
    print('[AUTH] Clearing pending_job_id');
    _pendingJobId = null;
    box.remove('pending_job_id');
  }

  /// Initialize AppLinks for Deep Linking
  Future<void> _initDeepLinks() async {
    try {
      final appLinks = AppLinks();
      print('[AUTH] Initializing Deep Links...');

      // 1. Cold Start
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        print('[AUTH] Cold Start URI received: $initialUri');
        _handleDeepLink(initialUri);
      } else {
        print('[AUTH] No Cold Start URI');
      }

      // 2. Background / Foreground Stream
      appLinks.uriLinkStream.listen((uri) {
        print('[AUTH] Stream URI received: $uri');
        _handleDeepLink(uri);
      }, onError: (err) {
        print('[AUTH] Deep Link Stream Error: $err');
      });
    } catch (e) {
      print('[AUTH] Deep Link Init Error: $e');
    }
  }

  /// Handle incoming deep link URI
  void _handleDeepLink(Uri uri) {
    // Expected format: https://kerjocurup.app/jobs/{id}
    // OR scheme: kerjocurup://jobs/{id}
    // OR https://kerjocurup-link.vercel.app/jobs/{id}
    print('[AUTH] _handleDeepLink processing: $uri');
    print('[AUTH] Path segments: ${uri.pathSegments}');

    // We don't strictly enforce host here because IntentFilter already filters it.
    // We just care about the path structure: /jobs/{id} or /j/{id}

    if (uri.pathSegments.isNotEmpty) {
      String? jobId;

      // Logic: Find 'jobs' or 'j' and get the NEXT segment
      // Example: /jobs/123 -> segments: ['jobs', '123']
      int index = -1;
      if (uri.pathSegments.contains('j')) {
        index = uri.pathSegments.indexOf('j');
      } else if (uri.pathSegments.contains('jobs')) {
        index = uri.pathSegments.indexOf('jobs');
      }

      if (index != -1 && index + 1 < uri.pathSegments.length) {
        jobId = uri.pathSegments[index + 1];
      }

      if (jobId != null && jobId.isNotEmpty) {
        print('[AUTH] Parsed Job ID: $jobId');

        // PERSISTENCE: Save Job ID immediately to survive app kill
        box.write('pending_job_id', jobId);
        print('[AUTH] Saved pending_job_id to storage: $jobId');

        // Save pending Job ID immediately to memory as well
        _pendingJobId = jobId;

        // If we are already ready, navigate. If not, wait for handleAppLaunch.
        if (isReady.value) {
          _navigateToJob(jobId);
        } else {
          print(
              '[AUTH] Auth not ready yet. Job ID stored pending initialization.');
        }
      } else {
        print('[AUTH] Could not parse Job ID from segments');
      }
    } else {
      print('[AUTH] URI path segments empty');
    }
  }

  Future<void> _navigateToJob(String jobId) async {
    print('[AUTH] _navigateToJob called for ID: $jobId');
    print(
        '[AUTH] State - IsReady: ${isReady.value}, User: ${user.value != null ? "Present" : "Null"}, Role: ${role.value}');

    // 1. Check if user is fully ready (logged in & profile loaded)
    if (isReady.value && user.value != null) {
      final currentRole = userRole;
      print('[AUTH] User is Ready. Detected Role: $currentRole');

      // 2. Role Guard - Strict Access Control
      if (currentRole == 'worker' || currentRole == 'ojek') {
        print('[AUTH] Role ALLOWED. Navigating to JOB_DETAIL.');
        // Ensure we are not already there to prevent stacking (optional, but good)
        Get.offAllNamed(Routes.JOB_DETAIL, arguments: jobId);
      } else if (currentRole == 'farmer' ||
          currentRole == 'petani' ||
          currentRole == 'warehouse') {
        // BLOCK Employer Access + FORCE LOGOUT
        print('[AUTH] ACCESS DENIED (Employer: $currentRole). Forcing Logout.');

        Get.dialog(
          AlertDialog(
            title: const Text('Akses Ditolak'),
            content: const Text(
                'Lowongan ini hanya bisa diakses oleh Pekerja.\n\nAkun Anda akan keluar otomatis untuk keamanan.'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // close dialog handled by logout flow usually, but safe to close
                },
                child: const Text('Mengerti'),
              ),
            ],
          ),
          barrierDismissible: false,
        );

        // Delay slightly to let user see the dialog (or just logout immediately)
        await Future.delayed(const Duration(seconds: 3));

        // Force Logout
        await logout();

        // Ensure redirect to Login (logout does this, but being explicit)
        Get.offAllNamed(Routes.LOGIN);
      } else {
        // Unknown role or incomplete profile
        print('[AUTH] Unknown Role: $currentRole. Redirecting to selection.');
        Get.offAllNamed(Routes.ROLE_SELECTION);
      }
    } else {
      // 3. User NOT logged in -> Save for later
      print('[AUTH] User NOT Ready. Saving Pending Job ID: $jobId');
      _pendingJobId = jobId;

      // Force navigation to Login if not already there or loading
      // If we are in Splash, let Splash finish and checkSessionAndRedirect handle it.
      // But if we are clearly idle (e.g. no session found yet), ensure Login.
      if (Get.currentRoute != Routes.LOGIN &&
          Get.currentRoute != Routes.SPLASH) {
        print('[AUTH] Not on Login/Splash. Redirecting to Login.');
        Get.toNamed(Routes.LOGIN);
        Get.snackbar(
          'Login Diperlukan',
          'Silakan masuk akun terlebih dahulu untuk melihat detail lowongan.',
          duration: const Duration(seconds: 3),
        );
      } else {
        print(
            '[AUTH] Currently on ${Get.currentRoute}. Waiting for session check or user action.');
      }
    }
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

        // PERSISTENCE: Check for pending job ID (Memory OR Storage)
        String? targetJobId = _pendingJobId ?? box.read('pending_job_id');

        if (targetJobId != null) {
          print('[AUTH] Found pending job redirect: $targetJobId');

          // Clear Persistence immediately as we are consuming it now
          _pendingJobId = null;
          box.remove('pending_job_id');

          // Check Role for Pending Job
          if (role.value == 'worker' || role.value == 'ojek') {
            print('[AUTH] Navigating to Pending Job: $targetJobId');
            Get.offAllNamed(Routes.JOB_DETAIL, arguments: targetJobId);
          } else {
            Get.snackbar('Akses Ditolak',
                'Hanya Pekerja/Ojek yang bisa melihat lowongan.');
            _redirectByRole(userData['role']);
          }
        } else {
          _redirectByRole(userData['role']);
        }
      } else {
        // Unknown status from backend
        Get.snackbar('Error', data['pesan'] ?? 'Login gagal');
        // Safeguard: Don't stay on Splash
        await _supabase.auth.signOut();
        Get.offAllNamed(Routes.LOGIN);
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

      // CRITICAL: Ensure we don't get stuck on Splash
      // If session processing failed, force logout and go to Login
      print('[AUTH] Critical Session Error. Falling back to Login.');
      await _supabase.auth.signOut(); // Ensure clean slate
      Get.offAllNamed(Routes.LOGIN);
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
        await setUserData(userData); // Use unified setter
        return userData;
      }
    } catch (e) {
      print('[AUTH] Fetch profile error: $e');
    }
    return null;
  }

  /// Explicitly set user data (e.g. from OnboardingController)
  /// key: Single Source of Truth update
  Future<void> setUserData(Map<String, dynamic> userData) async {
    await box.write('user', userData);

    // Update observable state
    user.value = userData;
    role.value = userData['role'];
    profile.value = userData;
    isReady.value = true;
    print('[AUTH] User data updated explicitly. Role: ${role.value}');
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
    print('[AUTH] Redirecting by role: $role');
    if (role == 'worker' || role == 'farmer' || role == 'warehouse') {
      print('[AUTH] Role valid. Going to MAIN.');
      Get.offAllNamed(Routes.MAIN);
    } else {
      print('[AUTH] Role invalid or unknown. Going to ROLE_SELECTION.');
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
