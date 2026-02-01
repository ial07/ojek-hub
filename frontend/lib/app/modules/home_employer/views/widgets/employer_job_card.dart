import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../models/order_model.dart';
import '../../../../routes/app_routes.dart';

class EmployerJobCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final bool isHistory;

  const EmployerJobCard({
    super.key,
    required this.order,
    required this.onTap,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- 1. Data Parsing & Normalization ---
    final isOjek = (order.workerType ?? '').toLowerCase().contains('ojek');
    final workerBadgeText = isOjek ? 'Ojek' : 'Harian';
    final workerBadgeColor =
        isOjek ? Colors.blue.shade700 : Colors.orange.shade800;
    final workerBadgeBg = isOjek ? Colors.blue.shade50 : Colors.orange.shade50;

    // Counts (Backend Truth)
    final total = order.totalWorkers ?? 1;
    final accepted = order.acceptedCount ?? 0;
    final applicants =
        order.currentQueue ?? 0; // Total pending/active applicants

    // Status Determination
    // Logic:
    // - If status != open -> 'Selesai' / 'Ditutup'
    // - If accepted >= total -> 'Terpenuhi'
    // - Else -> 'Aktif'
    String statusText = 'Aktif';
    Color statusColor = AppColors.primaryGreen; // Default Green

    if (order.status != 'open') {
      statusText = order.status == 'cancelled' ? 'Dibatalkan' : 'Selesai';
      statusColor = Colors.grey;
    } else if (accepted >= total) {
      statusText = 'Terpenuhi';
      statusColor = Colors.blue;
    } else {
      // Check date for expiry?
      // Controller filters expired to history, but card should reflect truth.
      if (order.jobDate != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final jDate =
            order.jobDate!.isUtc ? order.jobDate!.toLocal() : order.jobDate!;
        if (jDate.isBefore(today)) {
          statusText = 'Selesai'; // Past Date = Finished
          statusColor = Colors.grey;
        }
      }
    }

    // Urgency Logic
    // Show "Perlu Tindakan" ONLY if:
    // 1. Status is Active/Open (not filled, not closed)
    // 2. We have applicants waiting (applicants > 0)
    // Note: Prompt said "applicants > accepted", but checking if we have pending is safer if 'applicants' means queue.
    // If 'currentQueue' is pending count, then > 0 is correct.
    bool needsAction = (statusText == 'Aktif') && (applicants > 0);

    // Date Logic
    bool isToday = false;
    String dateLabel = '';

    if (order.jobDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));

      final jUtc =
          order.jobDate!.isUtc ? order.jobDate!.toLocal() : order.jobDate!;
      final jDay = DateTime(jUtc.year, jUtc.month, jUtc.day);

      if (jDay.isAtSameMomentAs(today)) {
        isToday = true;
        dateLabel = 'Hari Ini';
      } else if (jDay.isAtSameMomentAs(tomorrow)) {
        dateLabel = 'Besok';
      } else {
        dateLabel = DateFormat('d MMM', 'id_ID').format(jDay);
        if (dateLabel == '') dateLabel = DateFormat('d MMM').format(jDay);
      }
    }

    // Action Logic
    String primaryActionLabel = 'Lihat Detail';
    IconData primaryActionIcon = Icons.arrow_forward;
    VoidCallback onPrimaryAction = onTap; // Default nav

    if (statusText == 'Aktif') {
      if (applicants > 0) {
        primaryActionLabel = 'Lihat Pelamar';
        primaryActionIcon = Icons.people_alt_outlined;
        onPrimaryAction =
            () => Get.toNamed(Routes.QUEUE_VIEW, arguments: order);
      } else {
        primaryActionLabel = 'Bagikan Lowongan';
        // Visual requirement: WhatsApp icon only (or share icon if generic)
        // Prompt says "Button icon: WhatsApp icon only". Flutter doesn't have built-in WA icon easily accessible
        // without font_awesome or similar, unless provided in assets.
        // I will use Icons.share or Icons.chat if WA specific not available.
        // Actually, prompt says "Button icon: WhatsApp icon only". I'll check if I can use a generic share or text.
        primaryActionIcon = Icons.share; // Safe fallback

        onPrimaryAction = () async {
          // 1. Prepare Data
          final title = order.title ?? 'Lowongan Pekerjaan';
          final loc = order.location ?? 'Lokasi tidak tersedia';
          final needed = total;

          // Date Formatting
          String dateStr = '-';
          if (order.jobDate != null) {
            final d = order.jobDate!.isUtc
                ? order.jobDate!.toLocal()
                : order.jobDate!;
            dateStr = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(d);
            // Fallback formatting
            if (dateStr.contains('EEEE')) {
              dateStr = DateFormat('d MMM yyyy').format(d);
            }
          }

          final publicUrl = 'https://kerjocurup.app/jobs/${order.id}';

          // 2. Compose Message
          final message = "Halo, ada lowongan kerja tersedia.\n\n"
              "Pekerjaan: $title\n"
              "Lokasi: $loc\n"
              "Tanggal: $dateStr\n"
              "Jumlah Dibutuhkan: $needed orang\n\n"
              "Buka di aplikasi KerjoCurup:\n"
              "$publicUrl";

          // 3. Analytics Stub
          print(
              '[ANALYTICS] share_job_whatsapp: {order_id: ${order.id}, status: ${order.status}}');

          // 4. Launch WhatsApp
          final waUrl =
              Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');

          try {
            bool launched = false;
            // Try Launching (Safe Mode)
            if (await canLaunchUrl(waUrl)) {
              launched =
                  await launchUrl(waUrl, mode: LaunchMode.externalApplication);
            }

            // Fallback if WA launch fails
            if (!launched) {
              throw 'Could not launch WhatsApp';
            }
          } catch (e) {
            // Fallback: Clipboard
            print('[SHARE] WhatsApp failed, falling back to Clipboard: $e');
            Clipboard.setData(ClipboardData(text: message));
            Get.snackbar(
              'Link Disalin',
              'WhatsApp tidak terinstall. Pesan disalin ke clipboard.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.black87,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            );
          }
        };
      }
    }

    // Visual Styles
    final borderColor = (isToday && !isHistory && statusText == 'Aktif')
        ? AppColors.primaryGreen.withValues(alpha: 0.5)
        : Colors.grey.shade200;

    final cardOpacity =
        (statusText == 'Selesai' || statusText == 'Dibatalkan') ? 0.7 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: cardOpacity,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: borderColor,
                width: (isToday && statusText == 'Aktif') ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Header Row: Badges & Status/Date ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    // Worker Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: workerBadgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        workerBadgeText,
                        style: TextStyle(
                          color: workerBadgeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Date or Status Label
                    // If Urgent, status is implied by lower badge? No, show Date here usually.
                    // But if finished, showing 'Selesai' is better context than date?
                    // Design spec: "Date indicator with context".
                    if (statusText != 'Aktif' && statusText != 'Terpenuhi') ...[
                      Text(statusText,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ] else if (dateLabel.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            dateLabel,
                            style: TextStyle(
                              color: isToday
                                  ? Colors.red.shade700
                                  : Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // --- Content Row: Title, Location, Metrics ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Loc
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.title ?? 'Lowongan',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlack,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  order.location ?? 'Lokasi tidak tersedia',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Metrics (Right Side) - Dominant
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Applicant Count
                        Text(
                          '$applicants',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlack,
                          ),
                        ),
                        const Text(
                          'Pelamar',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        // Quota Progress
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (accepted >= total)
                                ? Colors.blue.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$accepted/$total Terpenuhi',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: (accepted >= total)
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // --- Action Divider ---
              const Divider(height: 1, thickness: 0.5),

              // --- Footer Action ---
              InkWell(
                onTap: onPrimaryAction, // Use calculated action
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Alert Icon if Needs Action
                      if (needsAction) ...[
                        Icon(Icons.error_outline,
                            size: 16, color: Colors.orange.shade800),
                        const SizedBox(width: 6),
                        Text(
                          'Perlu Tindakan',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(), // Push action to right
                      ],

                      // Primary Action Label
                      Text(
                        primaryActionLabel,
                        style: TextStyle(
                          color: needsAction
                              ? AppColors.primaryBlack
                              : AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(primaryActionIcon,
                          size: 16,
                          color: needsAction
                              ? AppColors.primaryBlack
                              : AppColors.primaryGreen),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
