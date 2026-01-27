import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_button.dart';
import '../../../../core/widgets/ojek_input.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout, color: Colors.red),
          )
        ],
      ),
      backgroundColor: Colors.grey[50], // Light background
      body: Obx(() {
        if (controller.isLoading.value) {
          // Loading state handling if needed
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              Obx(() => UserAvatar(
                    photoUrl: controller.user.value?['photo_url'],
                    name: controller.nameController.text.isNotEmpty
                        ? controller.nameController.text
                        : (controller.user.value?['name']),
                    radius: 50,
                    backgroundColor: AppColors.pastelGreen,
                    textColor: AppColors.primaryBlack,
                  )),

              const SizedBox(height: 24),

              // Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    OjekInput(
                      label: 'Nama Lengkap',
                      controller: controller.nameController,
                      hint: 'Masukkan nama lengkap',
                    ),
                    const SizedBox(height: 16),
                    OjekInput(
                      label: 'Nomor WhatsApp',
                      controller: controller.phoneController,
                      hint: 'Contoh: 08123456789',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    OjekInput(
                      label: 'Alamat',
                      controller: controller.addressController,
                      hint: 'Masukkan alamat lengkap',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              OjekButton(
                text: 'Simpan Perubahan',
                isLoading: controller.isLoading.value,
                onPressed: controller.saveProfile,
              ),

              const SizedBox(height: 24),

              // Privacy Policy Link
              TextButton(
                onPressed: controller.openPrivacyPolicy,
                child: const Text(
                  'Kebijakan Privasi',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
}
