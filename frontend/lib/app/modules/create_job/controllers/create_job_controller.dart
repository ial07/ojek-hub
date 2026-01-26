import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:dio/dio.dart';

class CreateJobController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  final SupabaseClient _supabase = Supabase.instance.client;

  final formKey = GlobalKey<FormState>();

  // State flags
  var isLoading = false.obs;
  var isReady = false.obs;

  // Form Fields
  var workerType = 'ojek'.obs;
  var workerCount = 1.obs;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime? selectedDate;
  var selectedLocation = Rxn<LatLng>();
  var mapUrl = RxnString();

  void setLocation(LatLng loc) {
    selectedLocation.value = loc;
    mapUrl.value =
        'https://www.google.com/maps?q=${loc.latitude},${loc.longitude}';
    print('[CREATE_JOB] Location selected: ${loc.latitude}, ${loc.longitude}');
    print('[CREATE_JOB] Map URL: ${mapUrl.value}');
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  void _initialize() {
    print('[CREATE_JOB] Initializing...');

    // Check session
    final session = _supabase.auth.currentSession;
    if (session == null) {
      print('[CREATE_JOB] No session, blocking');
      Get.snackbar('Error', 'Sesi tidak valid');
      Get.back();
      return;
    }

    isReady.value = true;
    print('[CREATE_JOB] Ready');
  }

  void setWorkerType(String? val) {
    if (val != null) {
      workerType.value = val;
      print('[CREATE_JOB] Worker type: $val');
    }
  }

  void setWorkerCount(String val) {
    workerCount.value = int.tryParse(val) ?? 1;
    print('[CREATE_JOB] Worker count: ${workerCount.value}');
  }

  Future<void> pickDate(BuildContext context) async {
    if (!isReady.value) {
      print('[CREATE_JOB] Not ready, blocking date pick');
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      selectedDate = picked;
      dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      print('[CREATE_JOB] Date selected: ${dateController.text}');
    }
  }

  Future<void> submitOrder() async {
    // Guard: not ready
    if (!isReady.value) {
      print('[CREATE_JOB] Not ready, blocking submit');
      return;
    }

    // Guard: already loading
    if (isLoading.value) {
      print('[CREATE_JOB] Already loading, blocking submit');
      return;
    }

    // Guard: form validation
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      print('[CREATE_JOB] Form validation failed');
      return;
    }

    // Guard: date required
    if (selectedDate == null) {
      print('[CREATE_JOB] No date selected');
      Get.snackbar('Error', 'Pilih tanggal pekerjaan');
      return;
    }

    // Guard: map location required
    if (selectedLocation.value == null) {
      print('[CREATE_JOB] No map location selected');
      Get.snackbar('Error', 'Pilih titik lokasi di peta');
      return;
    }

    try {
      isLoading.value = true;
      print('[CREATE_JOB] Submitting order...');

      final response = await _apiClient.dio.post('/orders', data: {
        'workerType': workerType.value,
        'workerCount': workerCount.value,
        'description': descriptionController.text,
        'location': locationController.text, // Text address
        'jobDate':
            selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'latitude': selectedLocation.value!.latitude,
        'longitude': selectedLocation.value!.longitude,
        'mapUrl': mapUrl.value,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[CREATE_JOB] Order created successfully');
        Get.back(result: true);
        Get.snackbar(
          'Sukses',
          'Lowongan berhasil dibuat',
          backgroundColor: AppColors.pastelGreen,
          colorText: AppColors.pastelGreenText,
        );
      }
    } catch (e) {
      print('[CREATE_JOB] Submit error: $e');

      String errorMessage = 'Terjadi kesalahan saat membuat lowongan';

      if (e is DioException) {
        if (e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map) {
            errorMessage = data['message'] ??
                data['pesan'] ??
                data['error'] ??
                errorMessage;
          } else if (data is String) {
            errorMessage = data;
          }
        } else {
          errorMessage = e.message ?? errorMessage;
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

  @override
  void onClose() {
    descriptionController.dispose();
    locationController.dispose();
    dateController.dispose();
    super.onClose();
  }
}
