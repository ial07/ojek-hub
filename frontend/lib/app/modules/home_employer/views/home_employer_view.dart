import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_header.dart';
import '../controllers/home_employer_controller.dart';
import '../../../routes/app_routes.dart';
import 'widgets/employer_job_card.dart';
// import 'widgets/employer_summary_widget.dart'; // Removed for 2-section simplicity
// import '../../../../models/order_model.dart';
import '../../../services/auth_service.dart';

class HomeEmployerView extends GetView<HomeEmployerController> {
  const HomeEmployerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: OjekHeader(
        title: 'Beranda',
        subtitle: 'Kelola lowongan yang sedang berjalan',
        trailing: IconButton(
          icon: const Icon(Icons.logout, color: AppColors.pastelRedText),
          onPressed: () => Get.find<AuthService>().signOut(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlack));
        }

        // Always show content if ready, even if empty (to see debug header)
        if (!controller.isReady.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlack));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          color: AppColors.primaryBlack,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Debug / Error Info
                if (controller.errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    color: Colors.red.shade100,
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Section 1: Active & Upcoming (Sedang Berjalan)
                if (controller.activeOrders.isNotEmpty) ...[
                  _buildSectionTitle('Sedang Berjalan & Akan Datang'),
                  ...controller.activeOrders.map((order) {
                    return EmployerJobCard(
                      order: order,
                      onTap: () => Get.toNamed(Routes.EMPLOYER_ACTIVITY_DETAIL,
                          arguments: order.id),
                    );
                  }),
                  const SizedBox(height: 24),
                ] else ...[
                  _buildSectionTitle('Sedang Berjalan & Akan Datang'),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("Tidak ada lowongan aktif.",
                        style: TextStyle(color: Colors.grey)),
                  ),
                ],

                // Section 2: History (Riwayat)
                if (controller.historyOrders.isNotEmpty) ...[
                  _buildSectionTitle('Riwayat Lowongan', isMuted: true),
                  ...controller.historyOrders.map((order) {
                    return EmployerJobCard(
                      order: order,
                      isHistory: true, // Hint to card
                      onTap: () => Get.toNamed(Routes.EMPLOYER_ACTIVITY_DETAIL,
                          arguments: order.id),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      }),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            onPressed: controller.isReady.value
                ? () => Get.toNamed(Routes.CREATE_JOB)
                    ?.then((_) => controller.refreshOrders())
                : null,
            backgroundColor: AppColors.primaryBlack,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add),
            label: const Text('Buat Lowongan',
                style: TextStyle(fontWeight: FontWeight.bold)),
          )),
    );
  }

  Widget _buildSectionTitle(String title,
      {bool isHighlighted = false, bool isMuted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (isHighlighted)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.error_outline, size: 18, color: Colors.orange),
            ),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlighted
                  ? Colors.orange.shade800
                  : (isMuted ? Colors.grey : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
