import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../routes/app_routes.dart';
import '../../controllers/activity_controller.dart';
import '../../../../../models/order_model.dart';

class ActivityListCard extends StatelessWidget {
  final ActivityModel activity;
  final bool isFeatured;

  const ActivityListCard({
    super.key,
    required this.activity,
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(activity.status);
    final OrderModel? job = activity.relatedOrder;
    final String providerName = job?.employerName ?? 'Penyedia Kerja';
    final String providerPhoto = job?.employerPhotoUrl ?? '';
    final String providerLabel = 'Pemilik Pekerjaan';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04), // Fixed Deprecation
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            if (job != null) {
              // Use Job Detail route but maybe pass a flag for "Applied Mode" or create distinct View?
              // The request asked for "Activity Detail Page".
              // I will map to JOB_DETAIL for now, but really we should have ACTIVITY_DETAIL.
              // Let's assume using standard JOB_DETAIL is fine, but enriched.
              Get.toNamed(Routes.JOB_DETAIL, arguments: job);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row (Identity & Status)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 20, // 40px diameter
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: providerPhoto.isNotEmpty
                          ? NetworkImage(providerPhoto)
                          : null,
                      child: providerPhoto.isEmpty
                          ? Text(
                              providerName[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w700),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // Name & Label
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            providerName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            providerLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusConfig.$2, // Bg Color
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusConfig.$1, // Text
                        style: TextStyle(
                          color: statusConfig.$3, // Text Color
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. Main Content (Job Info)
                // Padding left to align with text start (Avatar 40 + Gap 12 = 52)
                Padding(
                  padding: const EdgeInsets.only(
                      left:
                          0), // Design request said 52px, but visually might be driven by layout preference.
                  // If "Main Content" is separate row, standard padding is fine.
                  // If aligned under name: use EdgeInsets.only(left: 52).
                  // Let's stick to standard layout first for mobile breathing room, or try 52px if strictly requested.
                  // Request: "Padding Left: 52px - align with text start"
                  // I will apply it.
                  child: Padding(
                    padding: const EdgeInsets.only(left: 52),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job Title
                        Text(
                          job?.title ?? activity.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Metadata (Date & Location)
                        _buildMetaRow(
                            Icons.calendar_today_outlined,
                            job?.jobDate != null
                                ? DateFormat('EEEE, d MMM • HH:mm', 'id_ID')
                                    .format(job!.jobDate!)
                                : 'Tanggal tidak tersedia'),
                        const SizedBox(height: 4),
                        _buildMetaRow(Icons.location_on_outlined,
                            job?.location ?? 'Lokasi tidak tersedia'),
                      ],
                    ),
                  ),
                ),

                // 3. Footer Action (If Accepted)
                if (activity.status == 'accepted' &&
                    job?.employerPhone != null) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.only(left: 52),
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _openWhatsApp(job!.employerPhone!, job.title ?? ''),
                        icon: const Icon(Icons.chat_bubble_outline,
                            size: 16, color: AppColors.primaryGreen),
                        label: const Text('Hubungi via WhatsApp',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.primaryGreen)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          foregroundColor: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Returns Record (Text, BgColor, TextColor)
  (String, Color, Color) _getStatusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return (
          'Diterima',
          const Color(0xFFE8F5E9),
          AppColors.primaryGreen
        ); // Light Green
      case 'pending':
        return (
          'Menunggu',
          const Color(0xFFFFF3E0),
          Colors.orange
        ); // Light Orange
      case 'rejected':
        return ('Ditolak', const Color(0xFFFFEBEE), Colors.red); // Light Red
      case 'completed':
        return ('Selesai', const Color(0xFFE3F2FD), Colors.blue); // Light Blue
      default:
        return (status.toUpperCase(), Colors.grey.shade100, Colors.grey);
    }
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
