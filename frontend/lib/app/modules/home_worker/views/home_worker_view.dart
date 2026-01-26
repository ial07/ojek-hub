import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_button.dart';
import '../../../../core/widgets/ojek_card.dart';

import '../../../../core/utils/date_helper.dart';
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
      appBar: AppBar(
        title: const Text('KerjoCurup',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.primaryBlack)),
        centerTitle: false,
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.pastelRedText),
            onPressed: () => Get.find<AuthService>().signOut(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.primaryWhite,
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lowongan di Sekitarmu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Dipilih berdasarkan lokasi kamu',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Filter Trigger (Inline)
                Obx(() => InkWell(
                      onTap: () => _showFilterBottomSheet(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tune_rounded,
                              size: 18, color: AppColors.textPrimary),
                          const SizedBox(width: 8),
                          Text(
                            controller.viewFilter.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 18, color: AppColors.textPlaceholder),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          // Job List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryBlack),
                );
              }

              final jobs = controller.filteredJobs;

              if (jobs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 64, color: AppColors.textPlaceholder),
                      const SizedBox(height: 16),
                      Text(
                        _getEmptyStateMessage(controller.viewFilter.value),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: controller.refreshJobs,
                        child: const Text('Muat Ulang',
                            style: TextStyle(
                                color: AppColors.primaryBlack,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshJobs,
                color: AppColors.primaryBlack,
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: jobs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return _buildJobCard(job);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.7),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const Text(
              'Filter Pekerjaan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: controller.filterOptions
                      .map((option) => _buildRadioOption(option))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OjekButton(
                text: 'Terapkan Filter',
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildRadioOption(String value) {
    return Obx(() {
      final isSelected = controller.viewFilter.value == value;
      return InkWell(
        onTap: () => controller.setFilter(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? AppColors.primaryBlack
                    : AppColors.textPlaceholder,
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _getEmptyStateMessage(String filter) {
    if (filter.contains('Harian')) return 'Tidak ada lowongan harian';
    if (filter.contains('Ojek')) return 'Tidak ada lowongan ojek';
    if (filter == 'Hari Ini') return 'Tidak ada lowongan hari ini';
    return 'Belum ada lowongan tersedia';
  }

  Widget _buildJobCard(OrderModel job) {
    // 1. Format Date
    String friendlyDate = DateHelper.formatJobDate(job.jobDate);
    bool isUrgent = DateHelper.isUrgent(job.jobDate);
    final isApplied = controller.appliedJobIds.contains(job.id);
    final isHarian =
        (job.workerType == 'harian' || job.workerType == 'pekerja');

    return OjekCard(
      onTap: () => Get.toNamed(Routes.JOB_DETAIL, arguments: job),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title + Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job.title ?? 'Lowongan',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    height: 1.3,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Job Type Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color:
                      isHarian ? AppColors.pastelGreen : AppColors.pastelOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isHarian ? 'HARIAN' : 'OJEK',
                  style: TextStyle(
                      color: isHarian
                          ? AppColors.pastelGreenText
                          : AppColors.pastelOrangeText,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 2: Urgency (if applicable) -> Clean and simple
          if (isUrgent)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.pastelRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_filled,
                            size: 12, color: AppColors.pastelRedText),
                        const SizedBox(width: 4),
                        Text(
                          DateHelper.getRelativeLabel(
                              job.jobDate), // Hari ini / Besok
                          style: const TextStyle(
                            color: AppColors.pastelRedText,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Row 3: Location (Lihat Peta)
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job.location ?? 'Lokasi tidak tersedia',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (job.mapUrl != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => controller.openMap(job.mapUrl!),
                  child: const Text('Lihat Peta',
                      style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                )
              ]
            ],
          ),

          const SizedBox(height: 8),

          // Row 4: Date
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                friendlyDate,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 5: Workers
          Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Butuh ${job.totalWorkers ?? 1} orang',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: OjekButton(
              text: isApplied ? 'Sudah Dilamar' : 'Lamar Pekerjaan',
              onPressed: (job.id != null &&
                      !isApplied &&
                      controller.isReady.value &&
                      !controller.isLoading.value)
                  ? () => controller.confirmApply(job)
                  : null,
              isLoading: controller.isLoading.value && !isApplied,
              isSecondary: isApplied,
            ),
          ),
        ],
      ),
    );
  }
}
