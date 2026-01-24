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
    final job = controller.job;

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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Info (Cleaner)
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
                        job.createdAt != null
                            ? DateFormat('dd MMM yyyy').format(job.createdAt!)
                            : 'Baru saja',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    job.title ?? 'Lowongan Pekerjaan',
                    style: const TextStyle(
                      fontSize: 22, // Slightly reduced for mobile balance
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metadata Row (Location & People)
                  Row(
                    children: [
                      _buildMetadataItem(
                          Icons.location_on_outlined, job.location ?? '-'),
                      const SizedBox(width: 16),
                      _buildMetadataItem(Icons.people_outline,
                          'Butuh ${job.totalWorkers} Orang'),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 24),

                  // 2. Actionable Links (Instead of full map)
                  if (job.latitude != null && job.longitude != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.map,
                            color: AppColors.primaryGreen, size: 20),
                      ),
                      title: const Text('Lihat Lokasi di Google Maps',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Tap untuk membuka peta',
                          style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 14, color: AppColors.textPlaceholder),
                      onTap: controller.openMap,
                    ),

                  // WhatsApp Button in Body
                  Obx(() {
                    if (job.employerPhone != null &&
                        job.employerPhone!.isNotEmpty &&
                        (!controller.isWorker || !controller.isApplied)) {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          SizedBox(
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
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  // WhatsApp Button in Body (Visible only if NOT applied or NOT worker)
                  // If applied, it moves to the sticky footer
                  Obx(() {
                    if (job.employerPhone != null &&
                        job.employerPhone!.isNotEmpty &&
                        (!controller.isWorker || !controller.isApplied)) {
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          SizedBox(
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
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),

                  const SizedBox(height: 16),

                  // 3. Description
                  const Text(
                    'Deskripsi Pekerjaan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
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

          // 4. Sticky Apply Button (Mobile First Interaction)
          Obx(() {
            // Only show sticky footer for Workers
            if (!controller.isWorker) return const SizedBox.shrink();

            final isApplied = controller.isApplied; // Reactive
            final hasPhone =
                job.employerPhone != null && job.employerPhone!.isNotEmpty;

            // If applied and no phone, hide the section entirely (or show status)
            if (isApplied && !hasPhone) {
              return Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                color: Colors.grey.shade100,
                child: const Text(
                  'Lamaran Sudah Terkirim',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              );
            }

            // If applied and has phone -> Show "Hubungi via WhatsApp" (Follow up)
            // If not applied -> Show "Lamar Pekerjaan"

            return Container(
              padding: const EdgeInsets.all(16), // Standard mobile padding
              decoration: BoxDecoration(
                color: AppColors.primaryWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: isApplied
                      ? OutlinedButton.icon(
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
                        )
                      : OjekButton(
                          text: 'Lamar Pekerjaan Ini',
                          onPressed: controller.applyJob,
                        ),
                ),
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
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
