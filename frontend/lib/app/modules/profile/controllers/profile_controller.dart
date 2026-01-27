import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:KerjoCurup/modules/auth/auth_controller.dart';
import '../../privacy_policy/views/privacy_policy_view.dart';
import '../../privacy_policy/bindings/privacy_policy_binding.dart';

class ProfileController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final SupabaseClient _supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  final isLoading = false.obs;

  // Expose user observable from AuthController
  Rx<Map<String, dynamic>?> get user => _authController.user;

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  void _loadProfileData() {
    final user = _authController.user.value;
    if (user != null) {
      nameController.text = user['name'] ?? '';
      phoneController.text = user['phone'] ?? user['phone_number'] ?? '';
      addressController.text = user['location'] ?? '';
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
        'phone': _normalizePhone(phoneController.text),
        'location': addressController.text,
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

  Future<void> logout() async {
    await _authController.logout();
  }

  void openPrivacyPolicy() {
    Get.to(
      () => const PrivacyPolicyView(),
      binding: PrivacyPolicyBinding(),
    );
  }
}
