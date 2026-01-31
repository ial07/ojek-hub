import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Added intl import
import '../../../../../core/theme/app_colors.dart';
import '../../../../../models/order_model.dart'; // Corrected path
import '../../../../../routes.dart';
import '../../controllers/activity_controller.dart'; // Corrected path: ../../controllers/
import 'package:url_launcher/url_launcher.dart';

class ActivityTimelineCard extends StatelessWidget {
  final ActivityModel activity;
  final bool isFeatured; // For Today/Tomorrow cards to give extra emphasis

  const ActivityTimelineCard({
    super.key,
    required this.activity,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Determine Colors & Status Text
    Color statusColor;
    Color statusBgColor;
    String statusText;
    bool isAccepted = false;

    final s = activity.status.toLowerCase();
    switch (s) {
      case 'accepted':
        statusColor = AppColors.primaryGreen;
        statusBgColor = AppColors.primaryGreen.withValues(alpha: 0.1);
        statusText = 'Lamaran Diterima';
        isAccepted = true;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.withValues(alpha: 0.1);
        statusText = 'Menunggu Konfirmasi';
        break;
      case 'rejected':
      case 'cancelled':
        statusColor = Colors.red;
        statusBgColor = Colors.red.withValues(alpha: 0.1);
        statusText = s == 'rejected' ? 'Lamaran Ditolak' : 'Dibatalkan';
        break;
      case 'filled':
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withValues(alpha: 0.1);
        statusText = 'Kuota Penuh';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.withValues(alpha: 0.1);
        statusText = 'Selesai';
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withValues(alpha: 0.1);
        statusText = activity.status.toUpperCase();
    }

    // Border for featured cards
    final border = isFeatured
        ? Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.5)
        : Border.all(color: Colors.grey.shade200);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (activity.relatedOrder != null) {
              Get.toNamed(Routes.JOB_DETAIL, arguments: activity.relatedOrder);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Trust Header (Employer Name)
                if (activity.relatedOrder?.employerName != null)
                  Row(
                    children: [
                      Icon(Icons.business,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        activity.relatedOrder!.employerName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified,
                          size: 12, color: AppColors.primaryGreen),
                    ],
                  ),
                const SizedBox(height: 8),

                // 2. Job Identity
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity
                                .subtitle, // e.g. "Lamaran sebagai Tenaga Panen"
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (activity.relatedOrder?.jobDate != null)
                            Text(
                              DateFormat('d MMMM yyyy').format(
                                  activity.relatedOrder!.jobDate!.toLocal()),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Hari Ini',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 12),

                // 3. Status Banner
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Icon based on status
                      Icon(
                        isAccepted ? Icons.check_circle : Icons.info_outline,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Action Area
                if (isAccepted && activity.relatedOrder?.employerPhone != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Open WhatsApp
                        _openWhatsApp(activity.relatedOrder!.employerPhone!,
                            activity.title);
                      },
                      icon: const Icon(Icons.chat_bubble, size: 18),
                      label: const Text('Hubungi via WhatsApp'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        if (activity.relatedOrder != null) {
                          Get.toNamed(Routes.JOB_DETAIL,
                              arguments: activity.relatedOrder);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Lihat Detail'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openWhatsApp(String phone, String title) async {
    final url =
        'https://wa.me/$phone?text=Halo,%20saya%20tertarik%20dengan%20${Uri.encodeComponent(title)}';
    if (!await launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Tidak dapat membuka WhatsApp');
    }
  }
}
