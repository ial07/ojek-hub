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

        final bool hasApplied = controller.isApplied; // Reactive
        // TEMPORARY: Reset status logic for stable UI
        final String status =
            'open'; // job.applicationStatus ?? (hasApplied ? 'pending' : 'open');
        final String statusLabel = hasApplied
            ? (status == 'accepted'
                ? 'Diterima'
                : (status == 'rejected' ? 'Ditolak' : 'Menunggu Konfirmasi'))
            : 'Tersedia';
        final Color statusColor = status == 'accepted'
            ? AppColors.primaryGreen
            : (status == 'rejected'
                ? Colors.red
                : (hasApplied ? Colors.orange : Colors.grey));

        return Column(
          children: [
            // 0. Context Header (Sticky Top)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              color: const Color(0xFFF5F5F5), // Neutral background
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${job.workerType?.toUpperCase() ?? "PEKERJA"}  •  ${job.jobDate != null ? DateFormat('d MMM').format(job.jobDate!) : "N/A"}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Provider Identity Section (Hero Card)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30, // 60px size
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: job.employerPhotoUrl != null
                                ? NetworkImage(job.employerPhotoUrl!)
                                : null,
                            child: job.employerPhotoUrl == null
                                ? Text(job.employerName?[0] ?? '?',
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.grey))
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.employerName ?? 'Penyedia Kerja',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlack,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Pemilik Pekerjaan',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                if (job.employerPhone != null)
                                  const Text(
                                    'Terverifikasi', // Placeholder trust signal
                                    style: TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ),
                          // (Button removed)
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 1.5 Contact Card (New High-Attention Zone)
                    // TEMPORARY: Contact Card removed for workers
                    /* 
                    if (controller.isWorker) ...[...]
                    */
                    const SizedBox(height: 24),

                    // 2. Job Title & Role Context
                    Text(
                      job.title ?? 'Lowongan Pekerjaan',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlack,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.badge_outlined,
                              size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Kamu mendaftar sebagai ${job.workerType ?? "Pekerja"}', // "Peran Kamu"
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. Location (Static Preview)
                    const Text('Lokasi Pekerjaan',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: controller.openMap,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                              ),
                              child: const Center(
                                  child: Icon(Icons.map, color: Colors.grey)),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.location ?? 'Lokasi tidak tersedia',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text('Ketuk untuk lihat di peta',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primaryGreen)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 4. Job Details
                    const Text('Deskripsi',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      job.description ?? 'Tidak ada deskripsi',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.6,
                          fontSize: 14),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // 7. Action Bar (Bottom Fixed)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Sticky Chat Action (Stacked Top)
                    // Visible for Workers if Phone exists, unless Status is 'accepted' (covered by primary button)
                    // TEMPORARY: Sticky Chat Action removed
                    /*
                    if (controller.isWorker &&
                        job.employerPhone != null &&
                        status != 'accepted') ...[...]
                    */

                    // Primary State Actions (Stacked Bottom)
                    if (status == 'accepted' && job.employerPhone != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.openWhatsApp,
                          icon: const Icon(Icons.chat_bubble, size: 18),
                          label: const Text('Hubungi Penyedia'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      )
                    else if (hasApplied && status == 'pending')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                            child: Text('Menunggu Konfirmasi',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold))),
                      )
                    else if (hasApplied)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cari Lowongan Lain'),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: OjekButton(
                          text: 'Lamar Pekerjaan Ini',
                          onPressed: controller.applyJob,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
