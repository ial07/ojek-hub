import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../models/order_model.dart'; // Import OrderModel

class ActivityModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final String status;
  final String type; // 'application' or 'order'
  final OrderModel? relatedOrder; // Added for navigation

  ActivityModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
    required this.type,
    this.relatedOrder,
  });
}

class ActivityController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;
  final box = GetStorage();

  var isLoading = false.obs;
  var activities = <ActivityModel>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActivities();
  }

  Future<void> fetchActivities() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = _supabase.auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Sesi tidak valid';
        return;
      }

      // Check role from storage
      final userData = box.read('user');
      final role = userData?['role'] ?? 'worker';

      if (role == 'worker') {
        await _fetchWorkerActivities(user.id);
      } else {
        await _fetchEmployerActivities(user.id);
      }
    } catch (e) {
      print('[ACTIVITY] Fetch error: $e');
      errorMessage.value = 'Gagal memuat aktivitas';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchWorkerActivities(String userId) async {
    // Fetch applications joined with order details AND employer details
    // Backend equivalent: order:orders(..., employer:users(name, photo_url, location))
    final response = await _supabase
        .from('order_applications')
        .select('*, order:orders(*, employer:users(name, photo_url, location))')
        .eq('worker_id', userId)
        .order('created_at', ascending: false);

    final List<dynamic> data = response;

    activities.value = data.map((item) {
      final orderData = item['order'] ?? {};
      final status = item['status'] ?? 'pending';

      // Parse OrderModel safely
      OrderModel? orderModel;
      if (item['order'] != null) {
        try {
          orderModel = OrderModel.fromJson(item['order']);

          // Manually Map Employer Info if not covered by fromJson automatic flattening
          // (OrderModel.fromJson usually handles flat fields, but here we have nested 'employer')
          if (item['order']['employer'] != null) {
            final emp = item['order']['employer'];
            orderModel.employerName = emp['name'];
            orderModel.employerPhotoUrl = emp['photo_url']; // Map Photo URL
            // For now, let's store it dynamically or update OrderModel later
          }
        } catch (e) {
          print('[ACTIVITY] Error parsing order model: $e');
        }
      }

      return ActivityModel(
        id: item['id'],
        title: orderData['title'] ?? 'Lowongan',
        // New Subtitle Logic: "Penyedia: [Name]"
        subtitle: orderModel?.employerName != null
            ? 'Penyedia: ${orderModel!.employerName}'
            : (orderData['worker_type'] != null
                ? 'Lamaran sebagai ${orderData['worker_type']}'
                : 'Lamaran Pekerjaan'),
        date: DateTime.tryParse(item['created_at']) ?? DateTime.now(),
        status: status,
        type: 'application',
        relatedOrder: orderModel,
      );
    }).toList();
  }

  Future<void> _fetchEmployerActivities(String userId) async {
    // 1. Fetch orders created by employer
    final response = await _supabase
        .from('orders')
        .select('*')
        .eq('employer_id', userId)
        .order('created_at', ascending: false);

    final List<dynamic> ordersData = response;

    // 2. Fetch counts for these orders
    // We need to know: Total Applicants, Accepted Applicants
    final List<String> orderIds =
        ordersData.map((e) => e['id'].toString()).toList();

    Map<String, int> totalAppsMap = {};
    Map<String, int> acceptedAppsMap = {};

    if (orderIds.isNotEmpty) {
      // Create a map to store counts
      // Optimization: Fetch only id, order_id, status
      final appsResponse = await _supabase
          .from('order_applications')
          .select('order_id, status')
          .inFilter('order_id', orderIds);

      final List<dynamic> appsData = appsResponse;

      for (var app in appsData) {
        final oId = app['order_id'];
        final status = app['status'];

        // Count Total
        totalAppsMap[oId] = (totalAppsMap[oId] ?? 0) + 1;

        // Count Accepted
        if (status == 'accepted') {
          acceptedAppsMap[oId] = (acceptedAppsMap[oId] ?? 0) + 1;
        }
      }
    }

    // 3. Map to ActivityModel
    activities.value = ordersData.map((item) {
      final status = item['status'] ?? 'open';
      final oId = item['id'];

      OrderModel? orderModel;
      try {
        orderModel = OrderModel.fromJson(item);
        // Inject counts
        orderModel.currentQueue = totalAppsMap[oId] ?? 0;
        orderModel.acceptedCount = acceptedAppsMap[oId] ?? 0;
      } catch (e) {
        print('[ACTIVITY] Error parsing order model: $e');
      }

      return ActivityModel(
        id: item['id'],
        title: item['title'] ?? 'Lowongan',
        subtitle:
            '${totalAppsMap[oId] ?? 0} Pelamar', // Fallback subtitle if card not used
        date: DateTime.tryParse(item['created_at']) ?? DateTime.now(),
        status: status,
        type: 'order',
        relatedOrder: orderModel,
      );
    }).toList();
  }

  // Helper date normalization (remove time)
  DateTime _normalizeDate(DateTime date) {
    final localDate = date.toLocal();
    return DateTime(localDate.year, localDate.month, localDate.day);
  }

  // --- Grouping Logic ---

  // 1. TODAY: jobDate == Today
  List<ActivityModel> get todayActivities {
    final now = _normalizeDate(DateTime.now());
    return activities.where((a) {
      final dateToCheck = a.relatedOrder?.jobDate;
      if (dateToCheck == null) return false;
      return _normalizeDate(dateToCheck).isAtSameMomentAs(now);
    }).toList();
  }

  // 2. TOMORROW: jobDate == Tomorrow
  List<ActivityModel> get tomorrowActivities {
    final now = _normalizeDate(DateTime.now());
    final tomorrow = now.add(const Duration(days: 1));
    return activities.where((a) {
      final dateToCheck = a.relatedOrder?.jobDate;
      if (dateToCheck == null) return false;
      return _normalizeDate(dateToCheck).isAtSameMomentAs(tomorrow);
    }).toList();
  }

  // 3. UPCOMING: jobDate > Tomorrow
  List<ActivityModel> get upcomingActivities {
    final now = _normalizeDate(DateTime.now());
    final tomorrow = now.add(const Duration(days: 1));
    return activities.where((a) {
      final dateToCheck = a.relatedOrder?.jobDate;
      if (dateToCheck == null) return false;
      return _normalizeDate(dateToCheck).isAfter(tomorrow);
    }).toList();
  }

  // 4. LAST 7 DAYS (Recent History): jobDate < Today but >= Today-7 OR fallback to CreatedAt
  List<ActivityModel> get recentHistoryActivities {
    final now = _normalizeDate(DateTime.now());
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    return activities.where((a) {
      // Logic: This section is for "What happened recently?"
      // If it's a future job, it goes to Today/Tomorrow/Upcoming.
      // So checking if jobDate < Today OR if jobDate is null (use application date)

      DateTime dateToCheck = a.relatedOrder?.jobDate ?? a.date;
      final normalizedInfo = _normalizeDate(dateToCheck);

      // If it's in future (>= Today), it's already covered above IF it has relatedOrder.
      // If relatedOrder is null, we treat as history context based on application date.
      if (a.relatedOrder?.jobDate != null && !normalizedInfo.isBefore(now)) {
        return false; // It's in Today/Tomorrow/Upcoming
      }

      // Check range: [Today-7, Today)
      return normalizedInfo
              .isAfter(sevenDaysAgo.subtract(const Duration(seconds: 1))) &&
          normalizedInfo.isBefore(now);
    }).toList();
  }

  // 5. OLDER HISTORY: < Today-7
  List<ActivityModel> get olderHistoryActivities {
    final now = _normalizeDate(DateTime.now());
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    return activities.where((a) {
      DateTime dateToCheck = a.relatedOrder?.jobDate ?? a.date;
      final normalizedInfo = _normalizeDate(dateToCheck);

      if (a.relatedOrder?.jobDate != null && !normalizedInfo.isBefore(now)) {
        return false; // Future
      }

      return normalizedInfo.isBefore(sevenDaysAgo);
    }).toList();
  }

  String get role {
    final userData = box.read('user');
    return userData?['role'] ?? 'worker';
  }

  bool get isEmployer => role != 'worker';
}
