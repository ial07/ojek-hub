import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ojek_card.dart';
import '../../core/widgets/ojek_header.dart';
import 'role_controller.dart';

class RolePage extends GetView<RoleController> {
  const RolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const OjekHeader(
        title: 'Pilih Peran',
        showBack: false, // Usually strictly flow forward, or logout
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'Siapa Anda?',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih peran untuk melanjutkan',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),
            _buildRoleCard('Petani / Pemilik Lahan',
                'Saya ingin mencari pekerja', Icons.agriculture, 'farmer'),
            const SizedBox(height: 16),
            _buildRoleCard('Gudang / Pengepul', 'Saya butuh tenaga angkut',
                Icons.store, 'warehouse'),
            const SizedBox(height: 16),
            _buildRoleCard('Pekerja / Ojek', 'Saya ingin mencari pekerjaan',
                Icons.work, 'worker'),
            const Spacer(),
            Obx(() => controller.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlack))
                : const SizedBox()),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
      String title, String subtitle, IconData icon, String value) {
    return OjekCard(
      onTap: () => controller.selectRole(value),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlack.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.primaryBlack),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              size: 16, color: AppColors.textPlaceholder),
        ],
      ),
    );
  }
}
