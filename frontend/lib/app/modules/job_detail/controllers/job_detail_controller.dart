import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../home_worker/controllers/home_worker_controller.dart';
import '../../../../models/order_model.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailController extends GetxController {
  late OrderModel job;
  final HomeWorkerController _homeWorkerController =
      Get.find<HomeWorkerController>();

  var distanceText = RxnString();
  var isLocationPermissionGranted = false.obs;
  var isLoadingLocation = true.obs;

  @override
  void onInit() {
    super.onInit();
    job = Get.arguments as OrderModel;
    _calculateDistance();
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
          desiredAccuracy: LocationAccuracy.medium);

      // Calculate distance
      final Distance distance = const Distance();
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

  void applyJob() {
    // Reuse HomeWorkerController logic or call it
    _homeWorkerController.confirmApply(job);
  }

  Future<void> openWhatsApp() async {
    if (job.employerPhone == null || job.employerPhone!.isEmpty) {
      Get.snackbar('Info', 'Nomor WhatsApp pemberi kerja tidak tersedia');
      return;
    }

    final phone = job.employerPhone!;
    final url =
        'https://wa.me/$phone?text=Halo,%20saya%20tertarik%20dengan%20lowongan%20${Uri.encodeComponent(job.title ?? "pekerjaan")}';

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
