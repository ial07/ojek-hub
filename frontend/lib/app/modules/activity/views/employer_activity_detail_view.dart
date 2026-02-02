import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/employer_activity_detail_controller.dart';
import 'widgets/applicant_card.dart';

class EmployerActivityDetailView
    extends GetView<EmployerActivityDetailController> {
  const EmployerActivityDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Register controller if not bound (or use Get.put in Route)
    // Assuming Get.put(EmployerActivityDetailController()) is called in Route binding.

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Detail Lowongan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen));
        }

        final order = controller.orderData;
        final applicants = controller.applicants;
        final acceptedCount =
            applicants.where((a) => a['status'] == 'accepted').length;
        final workerCount =
            int.tryParse(order['worker_count']?.toString() ?? '0') ?? 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Job Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['title'] ?? 'Lowongan',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Kuota: $acceptedCount / $workerCount Terpenuhi',
                            style: TextStyle(
                                color: acceptedCount >= workerCount
                                    ? AppColors.primaryGreen
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                            order['job_date'] != null
                                ? order['job_date'].toString().substring(0, 10)
                                : 'Tanggal N/A',
                            style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Applicant List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Daftar Pelamar (${applicants.length})',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  if (applicants.isNotEmpty)
                    TextButton.icon(
                      onPressed: controller.fetchApplicants,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                    )
                ],
              ),
              const SizedBox(height: 12),

              // 3. List
              if (applicants.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.person_search,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Belum ada pelamar',
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text(
                          'Bagikan lowonganmu agar lebih banyak dilihat.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: applicants.length,
                  itemBuilder: (context, index) {
                    final app = applicants[index];
                    return ApplicantCard(
                      application: app,
                      onAccept: (id) => controller.updateStatus(id, 'accepted'),
                      onReject: (id) => controller.updateStatus(id, 'rejected'),
                      onContact: controller.openWhatsApp,
                    );
                  },
                ),

              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}
