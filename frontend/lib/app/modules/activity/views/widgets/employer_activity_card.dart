import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../controllers/activity_controller.dart';
import '../../../../../models/order_model.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class EmployerActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const EmployerActivityCard({super.key, required this.activity});

  @override
  @override
  Widget build(BuildContext context) {
    final OrderModel? order = activity.relatedOrder;
    if (order == null) return const SizedBox.shrink();

    // Stats
    final int applicants = order.currentQueue ?? 0;
    final int accepted = order.acceptedCount ?? 0;
    final int quota = order.totalWorkers ?? 1;

    // Status Config
    final statusConfig =
        _getStatusConfig(order.status ?? 'open', accepted, quota);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Title & Status)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    order.title ?? activity.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusConfig.$2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusConfig.$1,
                    style: TextStyle(
                      color: statusConfig.$3,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textSecondary),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      var result = await Get.toNamed(Routes.CREATE_JOB,
                          arguments: {'jobId': order.id, 'jobData': order});
                      if (result == true) {
                        try {
                          Get.find<ActivityController>().fetchActivities();
                        } catch (e) {
                          print('Failed to refresh activities: $e');
                        }
                      }
                    } else if (value == 'close') {
                      _handleClose(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 20, color: AppColors.textPrimary),
                          SizedBox(width: 12),
                          Text('Edit Lowongan'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'close',
                      child: Row(
                        children: [
                          Icon(Icons.highlight_off,
                              size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Tutup Lowongan',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 12),

            // 2. Middle Section (Jadwal, Lokasi, Kebutuhan)
            _buildInfoRow(
                Icons.calendar_today_outlined,
                order.jobDate != null
                    ? DateFormat('EEEE, d MMM yyyy', 'id_ID')
                        .format(order.jobDate!)
                    : 'Jadwal belum diatur'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on_outlined,
                order.location ?? 'Lokasi tidak tersedia'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.people_outline, 'Dibutuhkan $quota orang'),

            const SizedBox(height: 16),

            // 3. Progress Row (Text Stats)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pelamar: $applicants orang',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'Diterima: $accepted / $quota',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: accepted >= quota
                          ? AppColors.primaryGreen
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 4. Footer Note
            Center(
              child: Text(
                'Kelola pelamar dari menu Beranda',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  (String, Color, Color) _getStatusConfig(
      String status, int accepted, int quota) {
    if (accepted >= quota) {
      return ('Penuh', const Color(0xFFE8F5E9), AppColors.primaryGreen);
    }
    switch (status.toLowerCase()) {
      case 'open':
        return ('Terbuka', const Color(0xFFE3F2FD), Colors.blue);
      case 'closed':
        return ('Ditutup', const Color(0xFFFFEBEE), Colors.red);
      default:
        return (status.toUpperCase(), Colors.grey.shade100, Colors.grey);
    }
  }

  void _handleClose(BuildContext context) {
    if (activity.relatedOrder == null || activity.relatedOrder?.id == null) {
      Get.snackbar('Error', 'Data lowongan tidak lengkap');
      return;
    }

    final order = activity.relatedOrder!;
    final controller = Get.find<ActivityController>();
    final accepted = order.acceptedCount ?? 0;
    final applicants = order.currentQueue ?? 0;

    // Scenario C: Accepted Worker Exists (Blocking)
    if (accepted > 0) {
      Get.defaultDialog(
        title: 'Lowongan Sedang Berjalan',
        middleText:
            'Sudah ada pekerja yang diterima.\nLowongan tidak bisa ditutup sekarang.\n\nSelesaikan atau batalkan pekerjaan terlebih dahulu.',
        textConfirm: 'Mengerti',
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
        radius: 8,
      );
      return;
    }

    // Scenario A: No applicants
    if (applicants == 0) {
      Get.defaultDialog(
        title: 'Tutup Lowongan',
        middleText:
            'Belum ada pelamar pada lowongan ini.\nApakah kamu yakin ingin menutup lowongan?',
        textConfirm: 'Tutup Lowongan',
        textCancel: 'Batal',
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () {
          Get.back(); // close dialog
          controller.closeJob(order.id!);
        },
        radius: 8,
      );
      return;
    }

    // Scenario B: Applicants Exist, None Accepted
    Get.defaultDialog(
      title: 'Tidak Bisa Langsung Ditutup',
      radius: 8,
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Lowongan ini sudah memiliki pelamar.\nLowongan tidak bisa ditutup tanpa keputusan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // close dialog
                  controller.rejectAllAndClose(order.id!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Tolak Semua Pelamar dan Tutup',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Get.back();
                Get.toNamed(Routes.EMPLOYER_ACTIVITY_DETAIL,
                    arguments: {'activityId': activity.id});
              },
              child: const Text('Pilih Pelamar Sekarang'),
            )
          ],
        ),
      ),
    );
  }
}
