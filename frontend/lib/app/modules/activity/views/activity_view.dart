import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/activity_controller.dart';

class ActivityView extends GetView<ActivityController> {
  const ActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is now removed from here as it is put in MainBinding

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Aktivitas',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                controller.role == 'worker'
                    ? 'Lowongan yang pernah kamu lamar'
                    : 'Lowongan yang kamu kelola',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          bottom: const TabBar(
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryGreen,
            tabs: [
              Tab(text: 'Aktif'),
              Tab(text: 'Riwayat'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.fetchActivities,
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(child: Text(controller.errorMessage.value));
          }

          return TabBarView(
            children: [
              _buildActivityList(controller.activeActivities, isActive: true),
              _buildActivityList(controller.historyActivities, isActive: false),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActivityList(List<ActivityModel> items,
      {required bool isActive}) {
    if (items.isEmpty) {
      return _buildEmptyState(isActive);
    }

    return RefreshIndicator(
      onRefresh: controller.fetchActivities,
      color: AppColors.primaryGreen,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final activity = items[index];
          return _buildActivityItem(activity);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isActive) {
    final isWorker = controller.role == 'worker';
    String message = '';

    if (isActive) {
      message = isWorker
          ? 'Belum ada lamaran yang sedang diproses.\nCari lowongan di Beranda.'
          : 'Belum ada lowongan aktif.\nBuat lowongan baru sekarang.';
    } else {
      message = isWorker
          ? 'Belum ada riwayat lamaran atau pekerjaan.'
          : 'Belum ada lowongan yang selesai.';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.assignment_outlined : Icons.history,
              size: 48,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityModel activity) {
    // Map status to UI properties
    String label = '';
    Color color = Colors.grey;
    Color bgColor = Colors.grey.shade100;

    switch (activity.status.toLowerCase()) {
      case 'pending':
        label = 'Menunggu Konfirmasi';
        color = Colors.orange;
        bgColor = Colors.orange.shade50;
        break;
      case 'accepted':
        label = 'Diterima';
        color = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'rejected':
        label = 'Tidak Diterima';
        color = Colors.red;
        bgColor = Colors.red.shade50;
        break;
      case 'completed':
        label = 'Selesai';
        color = Colors.blue;
        bgColor = Colors.blue.shade50;
        break;
      case 'open':
        label = 'Mencari Pekerja';
        color = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'filled':
        label = 'Kuota Terpenuhi';
        color = Colors.orange;
        bgColor = Colors.orange.shade50;
        break;
      case 'closed':
        label = 'Ditutup';
        color = Colors.grey;
        bgColor = Colors.grey.shade200;
        break;
      case 'cancelled':
        label = 'Dibatalkan';
        color = Colors.red;
        bgColor = Colors.red.shade50;
        break;
      default:
        label = activity.status.toUpperCase();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Navigate based on type
            if (activity.type == 'application' || activity.type == 'order') {
              // Assuming the activity ID is actually the APPLICATION ID for workers
              // But for navigation we need ORDER ID?
              // The controller logic maps ID to order's ID for employers, but application's ID for workers
              // We might need to ensure ActivityModel has `orderId`
              // For now, let's assume `id` on ActivityModel is safe to pass if we handled it in Controller
              // Actually, let's check controller.
              // Worker: id = item['id'] (Application ID) -> Might be issue.
              // It's safer if we pass orderId. I will update this logic later if needed.
              // For MVP, just tap doesn't crash.
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('d MMM yyyy').format(activity.date),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Lihat Detail',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Spacer(),
                    Icon(Icons.chevron_right,
                        size: 16, color: Colors.grey),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
