import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get_storage/get_storage.dart';
import '../../home_worker/controllers/home_worker_controller.dart';
import '../../../../models/order_model.dart';
import '../../../../core/api/api_client.dart'; // Added
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart'; // Added for DioException handling
import 'package:share_plus/share_plus.dart';
import '../../../routes/app_routes.dart';
import '../../../../modules/auth/auth_controller.dart';

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

    try {
      // RBAC GUARD: Handled by AuthController before navigation
      // Deep links are validated in auth_controller.dart:_navigateToJob()
      // This controller only handles data loading for authorized Workers

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
        print('[JobDetail] Invalid arguments: $args');
        Get.snackbar('Error', 'Data lowongan tidak valid');
        isLoadingJob.value = false;
        // SAFEGUARD: Redirect to Home instead of showing empty screen
        Get.offAllNamed(Routes.MAIN);
      }

      // Try to find HomeWorkerController if it exists
      if (Get.isRegistered<HomeWorkerController>()) {
        _homeWorkerController = Get.find<HomeWorkerController>();
      }
    } catch (e) {
      print('[JobDetail] onInit Error: $e');
      isLoadingJob.value = false;
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

      // Handle 404 explicitly
      if (response.statusCode == 404) {
        print('[JobDetail] Job not found: $id');
        Get.snackbar(
          'Lowongan Tidak Ditemukan',
          'Lowongan mungkin sudah dihapus atau tidak tersedia.',
          duration: const Duration(seconds: 4),
        );
        Get.offAllNamed(Routes.MAIN);
        return;
      }

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

        // PERSISTENCE: Clear pending job ID from storage now that we've found it
        // This prevents re-opening the same job on next app launch
        if (Get.isRegistered<AuthController>()) {
          Get.find<AuthController>().clearPendingJobId();
        }

        _calculateDistance();
      } else {
        // Malformed response
        print('[JobDetail] Invalid response structure');
        Get.snackbar(
          'Gagal Memuat',
          'Format data tidak valid. Silakan coba lagi.',
          duration: const Duration(seconds: 3),
        );
        if (Get.isRegistered<AuthController>()) {
          Get.find<AuthController>().clearPendingJobId();
        }
        Get.offAllNamed(Routes.MAIN);
      }
    } on DioException catch (e) {
      print('[JobDetail] Network Error: ${e.type}');

      String errorMsg = 'Tidak dapat memuat detail lowongan.';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Koneksi terlalu lambat. Periksa koneksi internet Anda.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
      } else if (e.response?.statusCode == 404) {
        errorMsg = 'Lowongan tidak ditemukan atau sudah dihapus.';
      } else if (e.response?.statusCode == 403) {
        errorMsg = 'Lowongan ini tidak tersedia untuk Anda.';
      }

      Get.snackbar(
        'Gagal Memuat',
        errorMsg,
        duration: const Duration(seconds: 4),
      );

      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().clearPendingJobId();
      }
      Get.offAllNamed(Routes.MAIN);
    } catch (e) {
      print('[JobDetail] Unexpected Error: $e');
      Get.snackbar(
        'Terjadi Kesalahan',
        'Gagal memuat lowongan. Silakan coba lagi.',
        duration: const Duration(seconds: 3),
      );

      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().clearPendingJobId();
      }
      Get.offAllNamed(Routes.MAIN);
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

  Future<void> shareJob() async {
    final currentJob = job.value;
    if (currentJob == null) return;

    final String url = 'https://kerjocurup.app/j/${currentJob.id}';
    final String text = '''
Lowongan: ${currentJob.title ?? 'Pekerjaan Baru'}
Lokasi: ${currentJob.location ?? 'Rejang Lebong'}

Lihat detail & lamar di sini:
$url
''';

    // Using share_plus
    await Share.share(text, subject: 'Lowongan Kerja: ${currentJob.title}');
  }
}
