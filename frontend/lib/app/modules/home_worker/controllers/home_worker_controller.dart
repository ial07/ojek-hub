import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/api/api_client.dart';
import '../../../../models/order_model.dart';
import '../../../../core/theme/app_colors.dart';

class HomeWorkerController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final SupabaseClient _supabase = Supabase.instance.client;
  final box = GetStorage();

  // State flags
  var isLoading = false.obs;
  var isReady = false.obs;

  // Filters
  var viewFilter = 'Semua'.obs; // Unified filter state
  final filterOptions = [
    'Semua',
    'Lowongan Harian',
    'Lowongan Ojek',
    'Hari Ini',
    'Besok',
    'Minggu Ini'
  ];

  // Nullable models
  var availableJobs = <OrderModel>[].obs;
  // Track applied jobs locally
  var appliedJobIds = <String>{}.obs;
  var user = Rxn<Map<String, dynamic>>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    print('[HOME_WORKER] Initializing...');

    // Check session first
    final session = _supabase.auth.currentSession;
    if (session == null) {
      print('[HOME_WORKER] No session, cannot initialize');
      errorMessage.value = 'Sesi tidak valid';
      return;
    }

    // Load user from storage
    user.value = box.read('user');
    print('[HOME_WORKER] User loaded: ${user.value?['email']}');

    // Fetch jobs and applied status parallelly
    await Future.wait([
      fetchJobs(),
      fetchAppliedJobs(),
    ]);

    // Mark as ready
    isReady.value = true;
    print('[HOME_WORKER] Ready');
  }

  Future<void> fetchAppliedJobs() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('order_applications')
          .select('order_id')
          .eq('worker_id', userId);

      final List<dynamic> data = response;
      final appliedIds = data.map((e) => e['order_id'] as String).toSet();
      appliedJobIds.assignAll(appliedIds);
      print('[HOME_WORKER] Fetched ${appliedIds.length} existing applications');
    } catch (e) {
      print('[HOME_WORKER] Failed to fetch applied jobs: $e');
    }
  }

  Future<void> fetchJobs() async {
    if (isLoading.value) {
      print('[HOME_WORKER] Already loading, skipping');
      return;
    }

    try {
      isLoading.value = true;
      print('[HOME_WORKER] Fetching jobs...');

      final response = await _apiClient.dio.get('/orders');

      if (response.statusCode == 200 && response.data['data'] != null) {
        final List data = response.data['data'];
        availableJobs.value = data.map((e) => OrderModel.fromJson(e)).toList();
        print('[HOME_WORKER] Loaded ${availableJobs.length} jobs');
      }
    } catch (e) {
      print('[HOME_WORKER] Fetch error: $e');
      errorMessage.value = 'Gagal memuat lowongan';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshJobs() async {
    if (!isReady.value) {
      print('[HOME_WORKER] Not ready, blocking refresh');
      return;
    }
    await fetchJobs();
  }

  Future<void> openMap(String url) async {
    final uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar('Error', 'Tidak dapat membuka peta');
      }
    } catch (e) {
      print('Launch error: $e');
      Get.snackbar('Error', 'Gagal membuka aplikasi peta');
    }
  }

  void confirmApply(OrderModel job) {
    if (job.id == null) return;

    Get.defaultDialog(
      title: 'Konfirmasi Lamaran',
      titleStyle: const TextStyle(
          fontFamily: 'Plus Jakarta Sans', fontWeight: FontWeight.bold),
      content: Column(
        children: [
          const Text(
            'Apakah anda yakin ingin melamar pekerjaan ini?',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (job.mapUrl != null)
            TextButton.icon(
              icon: const Icon(Icons.map,
                  size: 16, color: AppColors.primaryGreen),
              label: const Text('Lihat Lokasi di Peta',
                  style: TextStyle(color: AppColors.primaryGreen)),
              onPressed: () => openMap(job.mapUrl!),
            ),
        ],
      ),
      textConfirm: 'Ya, Lamar',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primaryBlack,
      onConfirm: () {
        Get.back(); // Close dialog
        _submitApplication(job.id!);
      },
    );
  }

  Future<void> _submitApplication(String orderId) async {
    if (!isReady.value) {
      print('[HOME_WORKER] Not ready, blocking apply');
      return;
    }

    if (isLoading.value) {
      print('[HOME_WORKER] Already loading, blocking apply');
      return;
    }

    try {
      isLoading.value = true;

      // Enhanced logging for debugging
      final currentUser = _supabase.auth.currentUser;
      print('[HOME_WORKER] Applying to order: $orderId');
      print('[HOME_WORKER] User ID: ${currentUser?.id}');
      print('[HOME_WORKER] User Email: ${currentUser?.email}');
      print('[HOME_WORKER] User Role from storage: ${user.value?['role']}');

      final response = await _apiClient.dio.post('/orders/$orderId/apply');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[HOME_WORKER] Application successful');

        // Update local state instantly
        appliedJobIds.add(orderId);

        Get.snackbar(
          'Sukses',
          'Lamaran berhasil dikirim',
          backgroundColor: AppColors.pastelGreen,
          colorText: AppColors.pastelGreenText,
        );
        await fetchJobs();
      }
    } catch (e) {
      print('[HOME_WORKER] Apply error: $e');

      // Enhanced error handling with specific messages
      String errorMessage = 'Gagal melamar lowongan';

      if (e is DioException) {
        print('[HOME_WORKER] DioException - Status: ${e.response?.statusCode}');
        print('[HOME_WORKER] Response data: ${e.response?.data}');

        // Extract specific error message from backend
        if (e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map && data.containsKey('message')) {
            errorMessage = data['message'];
          } else if (data is Map && data.containsKey('pesan')) {
            errorMessage = data['pesan'];
          } else if (data is String) {
            errorMessage = data;
          }
        }

        // Add status code to message for debugging
        if (e.response?.statusCode != null) {
          errorMessage += ' (Kode: ${e.response!.statusCode})';
        }
      }

      Get.snackbar(
        'Gagal',
        errorMessage,
        backgroundColor: AppColors.pastelRed,
        colorText: AppColors.pastelRedText,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if user can apply to orders
  bool get canApplyToOrder {
    return user.value?['role'] == 'worker';
  }

  void setFilter(String filter) {
    viewFilter.value = filter;
  }

  List<OrderModel> get filteredJobs {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Base Filter (Standard validity check)
    var jobs = availableJobs.where((job) {
      if (job.jobDate == null) return false;

      // Strict status check (Secondary Safety Layer)
      if (job.status == 'closed' || job.status == 'filled') return false;

      // Strict quota check (Secondary Safety Layer)
      // approved_workers_count should be used if available, mapped to acceptedCount in model
      final approved = job.acceptedCount ?? 0;
      final total = job.totalWorkers ?? 1;

      if (approved >= total) return false;

      // Legacy queue check (if backend still sends currentQueue for some reason)
      if (job.currentQueue != null && job.totalWorkers != null) {
        // This check is less reliable than acceptedCount but kept as fallback
        // if (job.currentQueue! >= job.totalWorkers!) return false;
      }

      // Simple 7-day window check for relevance
      final jobDate =
          DateTime(job.jobDate!.year, job.jobDate!.month, job.jobDate!.day);
      final diff = jobDate.difference(today).inDays;
      return diff >= 0 && diff <= 7;
    }).toList();

    // 2. Apply Unified View Filter
    final filter = viewFilter.value;

    if (filter == 'Lowongan Harian') {
      jobs = jobs
          .where((job) =>
              job.workerType == 'harian' || job.workerType == 'pekerja')
          .toList();
    } else if (filter == 'Lowongan Ojek') {
      jobs = jobs.where((job) => job.workerType == 'ojek').toList();
    } else if (filter == 'Hari Ini') {
      jobs = jobs.where((job) {
        final jobDate =
            DateTime(job.jobDate!.year, job.jobDate!.month, job.jobDate!.day);
        return jobDate.difference(today).inDays == 0;
      }).toList();
    } else if (filter == 'Besok') {
      jobs = jobs.where((job) {
        final jobDate =
            DateTime(job.jobDate!.year, job.jobDate!.month, job.jobDate!.day);
        return jobDate.difference(today).inDays == 1;
      }).toList();
    } else if (filter == 'Minggu Ini') {
      // 'Minggu Ini' logic is implicitly 7 days (Base filter), so show all from base.
    }

    // 3. Sort: Urgent first (Today), then Date ASC
    jobs.sort((a, b) {
      final dateA = DateTime(a.jobDate!.year, a.jobDate!.month, a.jobDate!.day);
      final dateB = DateTime(b.jobDate!.year, b.jobDate!.month, b.jobDate!.day);

      return dateA.compareTo(dateB);
    });

    return jobs;
  }
}
