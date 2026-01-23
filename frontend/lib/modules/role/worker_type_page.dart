import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ojek_card.dart';
import '../../core/widgets/ojek_header.dart';
import 'role_controller.dart';

class WorkerTypePage extends GetView<RoleController> {
  const WorkerTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const OjekHeader(
        title: 'Jenis Keahlian',
        showBack: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            const Text(
              'Apa keahlian utama Anda?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 48),
            _buildTypeCard('Ojek Motor', 'Jasa angkut hasil panen / orang',
                Icons.two_wheeler, 'ojek'),
            const SizedBox(height: 16),
            _buildTypeCard('Pekerja Harian', 'Tenaga tani / serabutan',
                Icons.people, 'pekerja'),
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

  Widget _buildTypeCard(
      String title, String subtitle, IconData icon, String value) {
    return OjekCard(
      onTap: () => controller.selectWorkerType(value),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.pastelGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.pastelGreenText),
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
