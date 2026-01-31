import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_button.dart';
import 'widgets/job_card.dart'; // New Widget

import '../controllers/home_worker_controller.dart';
import '../../../services/auth_service.dart';
import '../../../../models/order_model.dart';
import '../../../routes/app_routes.dart';

class HomeWorkerView extends GetView<HomeWorkerController> {
  const HomeWorkerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground, // Very light grey
      appBar: AppBar(
        title: const Text('KerjoCurup',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.primaryBlack)),
        centerTitle: false,
        backgroundColor: Colors.white,
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
          // Header & Filter Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text(
                    'Lowongan Pekerjaan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // Horizontal Scrollable Filters (Replacing Bottom Sheet)
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.filterOptions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final option = controller.filterOptions[index];
                      return Obx(() {
                        final isSelected =
                            controller.viewFilter.value == option;
                        return InkWell(
                          onTap: () => controller.setFilter(option),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryGreen
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Job List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryGreen),
                );
              }

              final jobs = controller.filteredJobs;

              if (jobs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.work_off_outlined,
                          size: 64, color: Colors.grey),
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
                color: AppColors.primaryGreen,
                child: ListView.separated(
                  padding: const EdgeInsets.all(20), // Generous spacing
                  itemCount: jobs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 20), // Generous gap
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return JobCard(
                      job: job,
                      onTap: () =>
                          Get.toNamed(Routes.JOB_DETAIL, arguments: job),
                      onApply: () => controller.confirmApply(job),
                      onMap: job.mapUrl != null
                          ? () => controller.openMap(job.mapUrl!)
                          : null,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage(String filter) {
    if (filter == 'Hari Ini') return 'Tidak ada lowongan untuk hari ini';
    if (filter == 'Besok') return 'Tidak ada lowongan untuk besok';
    if (filter == 'Minggu Ini') return 'Tidak ada lowongan minggu ini';
    return 'Belum ada lowongan tersedia';
  }
}
