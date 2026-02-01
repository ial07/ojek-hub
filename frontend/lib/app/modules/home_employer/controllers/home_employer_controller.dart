import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/api/api_client.dart';
import '../../../../models/order_model.dart';
import '../../../services/auth_service.dart';

class HomeEmployerController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final SupabaseClient _supabase = Supabase.instance.client;
  final box = GetStorage();

  // State flags
  var isLoading = false.obs;
  var isReady = false.obs;

  // Nullable model
  var myOrders = <OrderModel>[].obs;
  var user = Rxn<Map<String, dynamic>>();
  var errorMessage = ''.obs;

  // Filter
  var filterType = 'all'.obs; // all, daily, ojek

  List<OrderModel> get filteredOrders {
    if (filterType.value == 'all') return myOrders;
    // Map filter 'daily' -> 'pekerja' (since frontend model uses 'harian'/'pekerja' mapped from backend 'daily')
    // Wait, backend response with mapping: "daily" -> "harian" (Phase 22).
    // And "ojek" -> "ojek".
    // So we filter by 'harian' or 'ojek'.

    // Let's check what the model actually holds.
    // Backend sends "harian" for daily worker.
    // So filter value 'harian' matches 'harian'.
    // Let's use 'harian' as key to match UI.

    if (filterType.value == 'harian') {
      return myOrders
          .where((o) => o.workerType == 'harian' || o.workerType == 'pekerja')
          .toList();
    }
    return myOrders.where((o) => o.workerType == filterType.value).toList();
  }

  void setFilter(String val) {
    filterType.value = val;
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    print('[HOME_EMPLOYER] Initializing...');

    // Check session first
    final session = _supabase.auth.currentSession;
    if (session == null) {
      print('[HOME_EMPLOYER] No session, cannot initialize');
      errorMessage.value = 'Sesi tidak valid';
      return;
    }

    // Load user from storage
    user.value = box.read('user');
    print('[HOME_EMPLOYER] User loaded: ${user.value?['email']}');

    // Fetch orders
    await fetchMyOrders();

    // Mark as ready
    isReady.value = true;
    print('[HOME_EMPLOYER] Ready');
  }

  Future<void> fetchMyOrders() async {
    if (isLoading.value) {
      print('[HOME_EMPLOYER] Already loading, skipping');
      return;
    }

    try {
      isLoading.value = true;
      print('[HOME_EMPLOYER] Fetching orders...');

      final response = await _apiClient.dio.get('/orders/my');

      print('[HOME_EMPLOYER] Fetching orders response: ${response.statusCode}');

      if (response.statusCode == 200) {
        List data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data is Map && response.data['data'] != null) {
          data = response.data['data'];
        } else {
          print('[HOME_EMPLOYER] Unexpected response format: ${response.data}');
        }

        myOrders.value = data.map((e) => OrderModel.fromJson(e)).toList();
        print('[HOME_EMPLOYER] Loaded ${myOrders.length} orders');

        // Fix: Root Cause Analysis - Backend 'myOrders' doesn't return accepted_count.
        // We must verify "accepted" count manually for active orders to show correct progress.
        fetchAcceptedCounts();
      }
    } catch (e) {
      print('[HOME_EMPLOYER] Fetch error: $e');
      if (e is DioException && e.response?.statusCode == 401) {
        print('[HOME_EMPLOYER] 401 Unauthorized - Signing out...');
        Get.find<AuthService>().signOut();
        return;
      }
      errorMessage.value = 'Gagal memuat lowongan: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Frontend-Only Fix for Missing Accepted Counts
  Future<void> fetchAcceptedCounts() async {
    // Only check active orders to save bandwidth
    final targets = activeOrders;
    if (targets.isEmpty) return;

    print(
        '[HOME_EMPLOYER] Lazy loading accepted counts for ${targets.length} active orders...');

    for (var order in targets) {
      if (order.id == null) continue;
      try {
        // Silence individual errors to not break the loop
        final response = await _apiClient.dio.get('/orders/${order.id}/queue');
        if (response.statusCode == 200 && response.data != null) {
          final List queue = response.data['data'] ?? [];
          // Filter for 'accepted' status
          final int realAccepted = queue.where((q) {
            final status = q['status'] as String? ?? 'pending';
            return status == 'accepted';
          }).length;

          // Update Model
          if (order.acceptedCount != realAccepted) {
            print(
                '[HOME_EMPLOYER] Correcting Order ${order.id}: ${order.acceptedCount} -> $realAccepted accepted');
            order.acceptedCount = realAccepted;
          }

          // Safety: If filled (e.g. status implies filled), ensure full count?
          // But trust the count first.
        }
      } catch (e) {
        print('[HOME_EMPLOYER] Failed to load queue for ${order.id}: $e');
      }
    }
    // Trigger UI Refresh
    myOrders.refresh();
  }

  Future<void> refreshOrders() async {
    if (!isReady.value) {
      print('[HOME_EMPLOYER] Not ready, blocking refresh');
      return;
    }
    await fetchMyOrders();
  }

  // --- Simplified Dashboard Logic (Design Fix) ---

  /// Section 1: Sedang Berjalan & Akan Datang (Active)
  /// Rules: Status is 'open' AND Date >= Today
  List<OrderModel> get activeOrders {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      return myOrders.where((o) {
        // Status allowlist
        if (o.status != 'open') return false;

        // Date check (Greater or Equal to Today)
        if (o.jobDate != null) {
          final j = o.jobDate!.toLocal();
          final jobDay = DateTime(j.year, j.month, j.day);
          if (jobDay.isBefore(todayStart)) return false;
        }

        return true;
      }).toList()
        ..sort((a, b) {
          // Ascending Date (Earliest first)
          if (a.jobDate == null) return 1;
          if (b.jobDate == null) return -1;
          return a.jobDate!.compareTo(b.jobDate!);
        });
    } catch (e) {
      print('[HOME_EMPLOYER] Error activeOrders: $e');
      return [];
    }
  }

  /// Section 2: Riwayat / Ditutup (History)
  /// Rules: Status NOT 'open' OR Date < Today
  List<OrderModel> get historyOrders {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      return myOrders.where((o) {
        // 1. If closed/completed/filled/cancelled -> History
        if (o.status != 'open') return true;

        // 2. If status is open but Date < Today -> History (Expired)
        if (o.jobDate != null) {
          final j = o.jobDate!.toLocal();
          final jobDay = DateTime(j.year, j.month, j.day);
          if (jobDay.isBefore(todayStart)) return true;
        }

        return false;
      }).toList()
        ..sort((a, b) {
          // Descending Date (Newest first)
          // Prefer createdAt for history if jobDate is equal or null
          final dateA = a.jobDate ?? a.createdAt;
          final dateB = b.jobDate ?? b.createdAt;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
    } catch (e) {
      print('[HOME_EMPLOYER] Error historyOrders: $e');
      return [];
    }
  }

  // Debug Stats
  String get debugStats {
    return 'Raw: ${myOrders.length} | Active: ${activeOrders.length} | History: ${historyOrders.length}';
  }

  /// Check if user can create orders
  bool get canCreateOrder {
    final role = user.value?['role'];
    return role == 'farmer' || role == 'warehouse';
  }
}
