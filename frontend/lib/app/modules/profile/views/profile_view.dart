import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_button.dart';
import '../../../../core/widgets/ojek_input.dart';
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
          // Allow interaction but show loading indicator on button
          // Actually, standard pattern is to disable inputs or overlay loader
          // For now, we just pass isLoading to the button
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.pastelGreen,
                child:
                    Icon(Icons.person, size: 50, color: AppColors.primaryBlack),
              ),
              const SizedBox(height: 24),

              // Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
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
            ],
          ),
        );
      }),
    );
  }
}
