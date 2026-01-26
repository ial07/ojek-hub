import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:get_storage/get_storage.dart';
import '../../home_worker/controllers/home_worker_controller.dart';
import '../../../../models/order_model.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailController extends GetxController {
  late OrderModel job;

  // Optional HomeWorkerController (only available for Worker flow)
  HomeWorkerController? _homeWorkerController;
  final _box = GetStorage();

  // Getters for UI logic
  bool get isApplied {
    if (_homeWorkerController == null) return false;
    return _homeWorkerController!.appliedJobIds.contains(job.id);
  }

  bool get isWorker {
    // Check storage directly as source of truth
    final user = _box.read('user');
    return user?['role'] == 'worker';
  }

  var distanceText = RxnString();
  var isLocationPermissionGranted = false.obs;
  var isLoadingLocation = true.obs;

  @override
  void onInit() {
    super.onInit();
    job = Get.arguments as OrderModel;

    // Try to find HomeWorkerController if it exists
    if (Get.isRegistered<HomeWorkerController>()) {
      _homeWorkerController = Get.find<HomeWorkerController>();
    }

    _calculateDistance();
  }

  // ... distance methods ...

  void applyJob() {
    if (_homeWorkerController != null) {
      _homeWorkerController!.confirmApply(job);
    } else {
      Get.snackbar('Error', 'Anda tidak dapat melamar pekerjaan ini');
    }
  }

  Future<void> _calculateDistance() async {
    if (job.latitude == null || job.longitude == null) {
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
        LatLng(job.latitude!, job.longitude!),
      );

      // Handle small distances
      if (km < 1) {
        final double meters = distance.as(
          LengthUnit.Meter,
          LatLng(position.latitude, position.longitude),
          LatLng(job.latitude!, job.longitude!),
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
    if (job.mapUrl != null) {
      final uri = Uri.parse(job.mapUrl!);
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
    if (job.employerPhone == null || job.employerPhone!.isEmpty) {
      Get.snackbar('Info', 'Nomor WhatsApp pemberi kerja tidak tersedia');
      return;
    }

    final phone = job.employerPhone!;
    final url =
        'https://wa.me/$phone?text=Halo,%20saya%20tertarik%20dengan%20${Uri.encodeComponent(job.title ?? "pekerjaan")}';

    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        Get.snackbar('Error', 'Tidak dapat membuka WhatsApp');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka WhatsApp');
    }
  }
}
