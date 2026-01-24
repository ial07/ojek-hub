import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final String status;
  final String type; // 'application' or 'order'

  ActivityModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
    required this.type,
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
    // Fetch applications joined with order details
    final response = await _supabase
        .from('order_applications')
        .select('*, order:orders(*)')
        .eq('worker_id', userId)
        .order('created_at', ascending: false);

    final List<dynamic> data = response;

    activities.value = data.map((item) {
      final order = item['order'] ?? {};
      final status = item['status'] ?? 'pending';

      return ActivityModel(
        id: item['id'],
        title: order['title'] ?? 'Lowongan',
        subtitle: order['worker_type'] != null
            ? 'Lamaran sebagai ${order['worker_type']}'
            : 'Lamaran Pekerjaan',
        date: DateTime.parse(item['created_at']),
        status: status,
        type: 'application',
      );
    }).toList();
  }

  Future<void> _fetchEmployerActivities(String userId) async {
    // Fetch orders created by employer
    final response = await _supabase
        .from('orders')
        .select('*')
        .eq('employer_id', userId)
        .order('created_at', ascending: false);

    final List<dynamic> data = response;

    activities.value = data.map((item) {
      final status = item['status'] ?? 'open';

      return ActivityModel(
        id: item['id'],
        title: item['title'] ?? 'Lowongan',
        subtitle: '${item['worker_count']} Pekerja dibutuhkan',
        date: DateTime.parse(item['created_at']),
        status: status,
        type: 'order',
      );
    }).toList();
  }

  // Filtered lists for Tabs
  List<ActivityModel> get activeActivities {
    return activities.where((a) {
      final s = a.status.toLowerCase();
      // Worker: Only Pending (Waiting for confirmation)
      // Employer: Open
      // User request: Active = "Lowongan lamar = pending"
      return ['pending', 'open'].contains(s);
    }).toList();
  }

  List<ActivityModel> get historyActivities {
    return activities.where((a) {
      final s = a.status.toLowerCase();
      // Worker: Accepted (Approved), Rejected
      // Employer: Closed, Filled
      // User request: History = "Lowongan already approved"
      return [
        'accepted',
        'rejected',
        'completed',
        'cancelled',
        'closed',
        'filled'
      ].contains(s);
    }).toList();
  }

  String get role {
    final userData = box.read('user');
    return userData?['role'] ?? 'worker';
  }
}
