import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_button.dart';
import '../../../../core/widgets/ojek_card.dart';
import '../../../../core/widgets/ojek_header.dart';
import '../controllers/home_employer_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../../models/order_model.dart';
import '../../../services/auth_service.dart';

class HomeEmployerView extends GetView<HomeEmployerController> {
  const HomeEmployerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: OjekHeader(
        title: 'Dashboard Saya',
        subtitle: 'Kelola lowongan dan pekerja',
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

        if (controller.myOrders.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.pastelGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.playlist_add,
                          size: 48, color: AppColors.pastelGreenText),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Belum ada lowongan',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Buat lowongan pertamamu untuk mulai mencari pekerja.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OjekButton(
                        text: 'Buat Lowongan',
                        icon: Icons.add,
                        onPressed: controller.isReady.value
                            ? () => Get.toNamed(Routes.CREATE_JOB)
                                ?.then((_) => controller.refreshOrders())
                            : null,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          color: AppColors.primaryBlack,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
                16, 8, 16, 100), // Bottom padding for FAB
            itemCount: controller.myOrders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = controller.myOrders[index];
              return _buildOrderCard(order);
            },
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

  Widget _buildOrderCard(OrderModel order) {
    final bool isOpen = order.status == 'open';

    return OjekCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.title ?? 'Lowongan',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dibuat: ${order.createdAt?.toIso8601String().split('T')[0] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPlaceholder,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen ? AppColors.pastelGreen : AppColors.pastelRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOpen ? 'BUKA' : 'TUTUP',
                  style: TextStyle(
                    color: isOpen
                        ? AppColors.pastelGreenText
                        : AppColors.pastelRedText,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Butuh', '${order.totalWorkers} Org'),
                _buildStat('Tipe', (order.workerType ?? 'Umum').toUpperCase()),
                _buildStat('Pelamar', '${order.currentQueue ?? 0}'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Full Width Action
          SizedBox(
            width: double.infinity,
            child: OjekButton(
              text: 'Lihat Pelamar',
              isSecondary: true,
              icon: Icons.people_outline,
              onPressed: () {
                Get.toNamed(Routes.QUEUE_VIEW, arguments: order.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
