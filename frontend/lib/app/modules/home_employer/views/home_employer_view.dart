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
        title: 'Lowongan Saya',
        subtitle: 'Kelola lowongan yang kamu buat',
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
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          color: AppColors.primaryBlack,
          child: Column(
            children: [
              // Filter Section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: AppColors.primaryWhite,
                child: Row(
                  children: [
                    _buildFilterChip('Semua', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Harian', 'harian'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Ojek', 'ojek'),
                  ],
                ),
              ),

              Expanded(
                child: controller.filteredOrders.isEmpty
                    ? Center(
                        child: Text(
                            "Tidak ada lowongan ${controller.filterType.value == 'all' ? '' : controller.filterType.value}",
                            style: const TextStyle(
                                color: AppColors.textSecondary)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: controller.filteredOrders.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final order = controller.filteredOrders[index];
                          return _buildOrderCard(order);
                        },
                      ),
              ),
            ],
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

  Widget _buildFilterChip(String label, String value) {
    return Obx(() {
      final isSelected = controller.filterType.value == value;
      return InkWell(
        onTap: () => controller.setFilter(value),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primaryBlack : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryBlack : AppColors.borderLight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
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
                'Mulai buat lowongan pertama kamu',
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

  Widget _buildOrderCard(OrderModel order) {
    final bool isOpen = order.status == 'open';
    final bool isHarian =
        (order.workerType == 'harian' || order.workerType == 'pekerja');

    return OjekCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Title + Badge Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  order.title ?? 'Lowongan',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isHarian ? AppColors.pastelGreen : AppColors.pastelOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isHarian ? 'HARIAN' : 'OJEK',
                  style: TextStyle(
                    color: isHarian
                        ? AppColors.pastelGreenText
                        : AppColors.pastelOrangeText,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Created Date
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                order.createdAt != null
                    ? 'Dibuat: ${order.createdAt!.toIso8601String().split('T')[0]}'
                    : '-',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // 3. Workers Needed
          Row(
            children: [
              const Icon(Icons.people_alt_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Butuh ${order.totalWorkers} orang',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // 4. Applicants Count
          Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 14,
                  color: isOpen
                      ? AppColors.textSecondary
                      : AppColors.textPlaceholder),
              const SizedBox(width: 6),
              Text(
                'Pelamar: ${order.currentQueue ?? 0}',
                style: TextStyle(
                    fontSize: 12,
                    color: isOpen
                        ? AppColors.textPrimary
                        : AppColors.textPlaceholder,
                    fontWeight: isOpen ? FontWeight.w600 : FontWeight.normal),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 5. Actions
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Get.toNamed(Routes.QUEUE_VIEW, arguments: order);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.borderLight),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Lihat Pelamar',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
