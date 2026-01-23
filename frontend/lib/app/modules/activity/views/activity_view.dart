import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_card.dart';
import '../controllers/activity_controller.dart';

class ActivityView extends GetView<ActivityController> {
  const ActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized if not already
    if (!Get.isRegistered<ActivityController>()) {
      Get.put(ActivityController());
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Aktivitas'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
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
            child: CircularProgressIndicator(color: AppColors.primaryBlack),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.pastelRedText),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchActivities,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                  ),
                  child: const Text('Coba Lagi',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        if (controller.activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.pastelGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history,
                      size: 48, color: AppColors.pastelGreenText),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada aktivitas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aktivitas aplikasi Anda akan muncul di sini',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchActivities,
          color: AppColors.primaryBlack,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.activities.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final activity = controller.activities[index];
              return _buildActivityCard(activity);
            },
          ),
        );
      }),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    Color statusColor;
    Color statusBgColor;
    String statusText = activity.status.toUpperCase();

    // Determine colors based on status
    switch (activity.status.toLowerCase()) {
      case 'accepted':
      case 'open':
        statusColor = AppColors.pastelGreenText;
        statusBgColor = AppColors.pastelGreen;
        break;
      case 'rejected':
      case 'closed':
      case 'cancelled':
        statusColor = AppColors.pastelRedText;
        statusBgColor = AppColors.pastelRed;
        break;
      case 'pending':
      default:
        statusColor = AppColors.textSecondary; // Greyish for neutral/pending
        statusBgColor = AppColors.borderLight;
        break;
    }

    // Translate status for display if needed
    if (activity.status == 'pending') statusText = 'MENUNGGU';
    if (activity.status == 'accepted') statusText = 'DITERIMA';
    if (activity.status == 'rejected') statusText = 'DITOLAK';
    if (activity.status == 'open') statusText = 'BUKA';
    if (activity.status == 'closed') statusText = 'TUTUP';

    return OjekCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon based on type
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity.type == 'application'
                  ? Icons.assignment_ind_outlined
                  : Icons.work_outline,
              color: AppColors.primaryBlack,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(activity.date),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textPlaceholder,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
