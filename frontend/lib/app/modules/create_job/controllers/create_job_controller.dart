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

  // Edit Mode State
  var isEditMode = false.obs;
  String? editingJobId;

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

    // Check Edit Mode
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['jobId'] != null && args['jobData'] != null) {
        isEditMode.value = true;
        editingJobId = args['jobId'];
        _prefillData(args['jobData']);
      }
    }

    isReady.value = true;
    print('[CREATE_JOB] Ready. Mode: ${isEditMode.value ? "EDIT" : "CREATE"}');
  }

  void _prefillData(dynamic jobData) {
    try {
      // Assuming jobData is an OrderModel or Map
      // If passing OrderModel, ensure casting.
      // For now, I'll rely on Map key access or dynamic
      // Adjust based on your calling code.
      // Using dynamic to handle both Map and Model if needed, but best to use Model.

      /*
      Field mapping:
      workerType -> jobData.workerType
      workerCount -> jobData.totalWorkers (or workerCount)
      description -> jobData.description
      location -> jobData.location
      date -> jobData.jobDate
      latitude/longitude -> jobData.latitude, jobData.longitude
      */

      // Simple implementation assuming OrderModel getters work dynamically or it's a model class
      // To be safe, let's treat it as the OrderModel class we know.
      // But simpler to just read fields.

      workerType.value = jobData.workerType == 'harian' ? 'harian' : 'ojek';
      workerCount.value = jobData.totalWorkers ?? 1;

      descriptionController.text = jobData.description ?? '';
      locationController.text = jobData.location ?? '';

      if (jobData.jobDate != null) {
        selectedDate = jobData.jobDate;
        dateController.text =
            "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
      }

      if (jobData.latitude != null && jobData.longitude != null) {
        setLocation(LatLng(jobData.latitude!, jobData.longitude!));
      }
    } catch (e) {
      print('[CREATE_JOB] Error prefilling data: $e');
    }
  }

  // ... (setWorkerType, setWorkerCount, pickDate etc. remain)

  Future<void> submitOrder() async {
    // Guard: not ready
    if (!isReady.value) {
      return;
    }

    // Guard: already loading
    if (isLoading.value) {
      return;
    }

    // Guard: form validation
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    // Guard: date required
    if (selectedDate == null) {
      Get.snackbar('Error', 'Pilih tanggal pekerjaan');
      return;
    }

    // Guard: map location required
    if (selectedLocation.value == null) {
      Get.snackbar('Error', 'Pilih titik lokasi di peta');
      return;
    }

    try {
      isLoading.value = true;
      print(
          '[CREATE_JOB] Submitting ${isEditMode.value ? "UPDATE" : "CREATE"}...');

      final payload = {
        'workerType': workerType.value,
        'workerCount': workerCount.value,
        'description': descriptionController.text,
        'location': locationController.text,
        'jobDate':
            selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'latitude': selectedLocation.value!.latitude,
        'longitude': selectedLocation.value!.longitude,
        'mapUrl': mapUrl.value,
      };

      var response;
      if (isEditMode.value && editingJobId != null) {
        // UPDATE
        response =
            await _apiClient.dio.put('/orders/$editingJobId', data: payload);
      } else {
        // CREATE
        response = await _apiClient.dio.post('/orders', data: payload);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[CREATE_JOB] Operation successful');
        Get.back(result: true); // Return true to trigger refresh
        Get.snackbar(
          'Sukses',
          isEditMode.value
              ? 'Lowongan berhasil diperbarui'
              : 'Lowongan berhasil dibuat',
          backgroundColor: AppColors.pastelGreen,
          colorText: AppColors.pastelGreenText,
        );
      }
    } catch (e) {
      print('[CREATE_JOB] Submit error: $e');

      String errorMessage = 'Terjadi kesalahan';

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
