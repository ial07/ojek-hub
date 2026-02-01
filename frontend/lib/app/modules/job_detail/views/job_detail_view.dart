import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_button.dart';
import '../controllers/job_detail_controller.dart';

class JobDetailView extends GetView<JobDetailController> {
  const JobDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Detail Lowongan',
            style: TextStyle(
                color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlack),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoadingJob.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final job = controller.job.value;
        if (job == null) {
          return const Center(child: Text('Data lowongan tidak ditemukan'));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header Info (Type & Date)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.pastelGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            job.workerType?.toUpperCase() ?? 'PEKERJA',
                            style: const TextStyle(
                              color: AppColors.pastelGreenText,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          job.jobDate != null
                              ? DateFormat('dd MMM yyyy').format(job.jobDate!)
                              : 'Baru saja',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 2. Job Title (Hero Animation)
                    // Hero tag requires unique ID. Using job.id is fine.
                    Hero(
                      tag: 'job_title_${job.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          job.title ?? 'Lowongan Pekerjaan',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlack,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 2.5 Employer Trust Signal (New)
                    Row(
                      children: [
                        const Icon(Icons.business,
                            size: 16, color: AppColors.textPrimary),
                        const SizedBox(width: 8),
                        Text(
                          'Penyedia: ${job.employerName ?? "Penyedia Kerja"}',
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                        // Optional: Verified Badge could go here
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. Worker Count (Metadata)
                    Row(
                      children: [
                        const Icon(Icons.people_outline,
                            size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Dibutuhkan ${job.totalWorkers} Orang',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 24),

                    // 4. Location Section (Grouped)
                    const Text(
                      'Lokasi',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 20, color: AppColors.textPrimary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            job.location ?? 'Alamat tidak tersedia',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              height: 1.5,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (job.latitude != null && job.longitude != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: controller.openMap,
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text('Buka di Google Maps'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryBlack,
                            side:
                                const BorderSide(color: AppColors.borderLight),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // 5. Description
                    const Text(
                      'Deskripsi Pekerjaan',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.description ?? 'Tidak ada deskripsi',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.6,
                          fontSize: 14),
                    ),

                    const SizedBox(height: 24),

                    // 6. WhatsApp Button (Single Instance)
                    if (job.employerPhone != null &&
                        job.employerPhone!.isNotEmpty)
                      Obx(() {
                        if (!controller.isWorker || !controller.isApplied) {
                          return SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: controller.openWhatsApp,
                              icon: const Icon(Icons.chat_bubble_outline,
                                  size: 18),
                              label: const Text('Hubungi via WhatsApp'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryGreen,
                                side: const BorderSide(
                                    color: AppColors.primaryGreen),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // 7. Sticky Apply Button (Sticky Footer)
            if (controller.isWorker)
              Obx(() {
                final isApplied = controller.isApplied; // Reactive
                final hasPhone =
                    job.employerPhone != null && job.employerPhone!.isNotEmpty;

                // If applied and no phone, show status only
                if (isApplied && !hasPhone) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    color: AppColors.pastelGreen,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            color: AppColors.pastelGreenText, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Lamaran Berhasil Dikirim',
                          style: TextStyle(
                              color: AppColors.pastelGreenText,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                if (isApplied) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        )
                      ],
                    ),
                    child: SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: controller.openWhatsApp,
                          icon: const Icon(Icons.chat_bubble, size: 18),
                          label: const Text('Hubungi via WhatsApp'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryGreen,
                            side:
                                const BorderSide(color: AppColors.primaryGreen),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // Not applied -> Show Apply button
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryWhite,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      )
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: OjekButton(
                        text: 'Lamar Pekerjaan Ini',
                        onPressed: controller.applyJob,
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      }),
    );
  }
}
