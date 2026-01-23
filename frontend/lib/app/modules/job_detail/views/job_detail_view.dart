import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_button.dart';
import '../controllers/job_detail_controller.dart';

class JobDetailView extends GetView<JobDetailController> {
  const JobDetailView({Key? key}) : super(key: key);

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
          Container(
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
                child: OjekButton(
                  text: 'Lamar Pekerjaan Ini',
                  onPressed: controller.applyJob,
                ),
              ),
            ),
          ),
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
