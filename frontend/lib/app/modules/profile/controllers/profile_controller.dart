import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ojekhub_mobile/modules/auth/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseClient _supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  void _loadProfileData() {
    final user = _authController.user.value;
    if (user != null) {
      nameController.text = user['name'] ?? '';
      phoneController.text = user['phone'] ?? '';
      addressController.text = user['address'] ?? '';
    }
  }

  Future<void> saveProfile() async {
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Nama tidak boleh kosong');
      return;
    }

    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        Get.snackbar('Error', 'User ID not found');
        return;
      }

      final updates = {
        'name': nameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('users').update(updates).eq('id', userId);

      // Refresh AuthController data
      await _authController.fetchUserProfile();

      Get.snackbar('Sukses', 'Profil berhasil diperbarui');
    } catch (e) {
      print('[PROFILE] Save error: $e');
      Get.snackbar('Error', 'Gagal menyimpan profil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authController.logout();
  }
}
