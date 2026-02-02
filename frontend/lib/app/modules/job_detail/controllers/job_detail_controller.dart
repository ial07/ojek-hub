import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get_storage/get_storage.dart';
import '../../home_worker/controllers/home_worker_controller.dart';
import '../../../../models/order_model.dart';
import '../../../../core/api/api_client.dart'; // Added
import 'package:url_launcher/url_launcher.dart';

class JobDetailController extends GetxController {
  // Refactor: job is now reactive to support async loading (Deep Link)
  final job = Rxn<OrderModel>();
  final isLoadingJob = true.obs;

  // Optional HomeWorkerController (only available for Worker flow)
  HomeWorkerController? _homeWorkerController;
  final _box = GetStorage();

  // Getters for UI logic
  bool get isApplied {
    if (job.value == null || _homeWorkerController == null) return false;
    // Fix: appliedJobIds was changed to myApplications map
    return _homeWorkerController!.myApplications.containsKey(job.value!.id);
  }

  bool get isWorker {
    // Check storage directly as source of truth
    final user = _box.read('user');
    return user?['role'] == 'worker';
  }

  var distanceText = RxnString();
  var isLocationPermissionGranted = false.obs;
  var isLoadingLocation = true.obs;

  final ApiClient _apiClient = Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    if (args is OrderModel) {
      job.value = args;
      isLoadingJob.value = false;
      _calculateDistance();
    } else if (args is String) {
      // Deep Link Case: ID passed
      fetchJobDetail(args);
    } else {
      // Fallback/Error case
      Get.snackbar('Error', 'Data lowongan tidak valid');
      isLoadingJob.value = false;
    }

    // Try to find HomeWorkerController if it exists
    if (Get.isRegistered<HomeWorkerController>()) {
      _homeWorkerController = Get.find<HomeWorkerController>();
    }
  }

  Future<void> fetchJobDetail(String id) async {
    try {
      isLoadingJob.value = true;
      final response = await _apiClient.dio.get('/orders/$id');

      // DEBUG: Log raw response
      print('━━━ [JobDetailController] Raw API Response ━━━');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data['data'] != null) {
        final rawData = response.data['data'];

        // DEBUG: Log critical fields
        print('━━━ [JobDetailController] Parsing Critical Fields ━━━');
        print('application_status: ${rawData['application_status']}');
        print('employer.phone: ${rawData['employer']?['phone']}');
        print(
            'employer.whatsapp_number: ${rawData['employer']?['whatsapp_number']}');
        print('employer.photo_url: ${rawData['employer']?['photo_url']}');

        job.value = OrderModel.fromJson(rawData);

        // DEBUG: Log parsed model
        print('━━━ [JobDetailController] Parsed Model ━━━');
        print('Model applicationStatus: ${job.value?.applicationStatus}');
        print('Model employerPhone: ${job.value?.employerPhone}');
        print('Model employerName: ${job.value?.employerName}');
        print('Model employerPhotoUrl: ${job.value?.employerPhotoUrl}');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        _calculateDistance();
      } else {
        Get.snackbar('Error', 'Lowongan tidak ditemukan');
      }
    } catch (e) {
      print('Error fetching job detail: $e');
      Get.snackbar('Error', 'Gagal memuat lowongan');
    } finally {
      isLoadingJob.value = false;
    }
  }

  // ... distance methods ...

  void applyJob() {
    if (_homeWorkerController != null && job.value != null) {
      _homeWorkerController!.confirmApply(job.value!);
    } else {
      Get.snackbar('Error', 'Anda tidak dapat melamar pekerjaan ini');
    }
  }

  Future<void> _calculateDistance() async {
    final currentJob = job.value;
    if (currentJob == null ||
        currentJob.latitude == null ||
        currentJob.longitude == null) {
      isLoadingLocation.value = false;
      return;
    }

    try {
      // check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLoadingLocation.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        isLoadingLocation.value = false;
        return;
      }

      isLocationPermissionGranted.value = true;

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.medium));

      // Calculate distance
      const Distance distance = Distance();
      final double km = distance.as(
        LengthUnit.Kilometer,
        LatLng(position.latitude, position.longitude),
        LatLng(currentJob.latitude!, currentJob.longitude!),
      );

      // Handle small distances
      if (km < 1) {
        final double meters = distance.as(
          LengthUnit.Meter,
          LatLng(position.latitude, position.longitude),
          LatLng(currentJob.latitude!, currentJob.longitude!),
        );
        distanceText.value = '${meters.round()} m';
      } else {
        distanceText.value = '${km.toStringAsFixed(1)} km';
      }
    } catch (e) {
      print('Error calculating distance: $e');
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> openMap() async {
    final currentJob = job.value;
    if (currentJob != null && currentJob.mapUrl != null) {
      final uri = Uri.parse(currentJob.mapUrl!);
      try {
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          Get.snackbar('Error', 'Tidak dapat membuka peta');
        }
      } catch (e) {
        Get.snackbar('Error', 'Gagal membuka aplikasi peta');
      }
    }
  }

  Future<void> openWhatsApp() async {
    final currentJob = job.value;
    if (currentJob == null ||
        currentJob.employerPhone == null ||
        currentJob.employerPhone!.isEmpty) {
      Get.snackbar('Info', 'Nomor WhatsApp pemberi kerja tidak tersedia');
      return;
    }

    final phone = _normalizePhone(currentJob.employerPhone!);
    // Pre-filled message for "Hubungi Penyedia" (Accepted candidates)
    final url =
        'https://wa.me/$phone?text=Halo,%20saya%20tertarik%20dengan%20${Uri.encodeComponent(currentJob.title ?? "pekerjaan")}';

    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar('Error', 'Tidak dapat membuka WhatsApp');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka WhatsApp');
    }
  }

  Future<void> openWhatsAppInquiry() async {
    final currentJob = job.value;
    if (currentJob == null ||
        currentJob.employerPhone == null ||
        currentJob.employerPhone!.isEmpty) {
      Get.snackbar('Info', 'Nomor WhatsApp pemberi kerja tidak tersedia');
      return;
    }

    final phone = _normalizePhone(currentJob.employerPhone!);
    // Specific message for "Chat via WhatsApp" (Inquiry)
    final message =
        'Hello, saya mau bertanya terkait ${currentJob.title ?? "lowongan ini"}';
    final url = 'https://wa.me/$phone?text=${Uri.encodeComponent(message)}';

    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar('Error', 'Tidak dapat membuka WhatsApp');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka WhatsApp');
    }
  }

  String _normalizePhone(String phone) {
    String p = phone.replaceAll(RegExp(r'\D'), ''); // Remove non-digits
    if (p.startsWith('0')) {
      return '62${p.substring(1)}';
    }
    if (p.startsWith('8')) {
      return '62$p';
    }
    return p;
  }
}
