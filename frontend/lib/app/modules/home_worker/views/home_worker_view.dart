import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_button.dart';
import '../../../../core/widgets/ojek_card.dart';
import '../../../../core/widgets/ojek_header.dart';
import '../controllers/home_worker_controller.dart';
import '../../../services/auth_service.dart';
import '../../../../models/order_model.dart';
import '../../../routes/app_routes.dart';

class HomeWorkerView extends GetView<HomeWorkerController> {
  const HomeWorkerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: OjekHeader(
        title: 'Lowongan Tersedia',
        subtitle: 'Cari pekerjaan yang cocok untukmu',
        trailing: IconButton(
          icon: const Icon(Icons.logout, color: AppColors.pastelRedText),
          onPressed: () => Get.find<AuthService>().signOut(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlack),
          );
        }

        if (controller.availableJobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off,
                    size: 64, color: AppColors.textPlaceholder),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada lowongan tersedia',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: controller.refreshJobs,
                  child: const Text('Muat Ulang',
                      style: TextStyle(color: AppColors.primaryBlack)),
                )
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshJobs,
          color: AppColors.primaryBlack,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.availableJobs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final job = controller.availableJobs[index];
              return _buildJobCard(job);
            },
          ),
        );
      }),
    );
  }

  Widget _buildJobCard(OrderModel job) {
    // Format date properly if possible
    String dateStr = '-';
    if (job.jobDate != null) {
      try {
        dateStr = DateFormat('dd MMM yyyy').format(job.jobDate!);
      } catch (e) {
        dateStr = job.jobDate.toString().split(' ')[0];
      }
    }

    return OjekCard(
      onTap: () => Get.toNamed(Routes.JOB_DETAIL, arguments: job),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title and Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job.title ?? 'Lowongan',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16, // Slightly smaller for density
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pastelGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BARU',
                  style: TextStyle(
                    color: AppColors.pastelGreenText,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Metadata Row (Location & Date)
          Row(
            children: [
              Flexible(
                child: _buildMetadataItem(
                    Icons.location_on_outlined, job.location ?? 'Lokasi?'),
              ),
              const SizedBox(width: 12),
              _buildMetadataItem(Icons.calendar_today_outlined, dateStr),
              if (job.mapUrl != null) ...[
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => controller.openMap(job.mapUrl!),
                  child: const Row(
                    children: [
                      Icon(Icons.map, size: 14, color: AppColors.primaryGreen),
                      SizedBox(width: 4),
                      Text("Peta",
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ]
            ],
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            job.description ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.4,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          // Footer: Worker Count & Action
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dibutuhkan',
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  Text(
                    '${job.totalWorkers} Orang',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Full Width CTA
          Obx(() {
            final isApplied = controller.appliedJobIds.contains(job.id);

            return SizedBox(
              width: double.infinity,
              child: OjekButton(
                text: isApplied ? 'Sudah Dilamar' : 'Lamar Pekerjaan Ini',
                // Disable button if applied
                onPressed: (job.id != null &&
                        !isApplied &&
                        controller.isReady.value &&
                        !controller.isLoading.value)
                    ? () => controller.confirmApply(job)
                    : null,
                isLoading: controller.isLoading.value && !isApplied,
                isSecondary:
                    isApplied, // Use secondary style for disabled/applied state visual
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
