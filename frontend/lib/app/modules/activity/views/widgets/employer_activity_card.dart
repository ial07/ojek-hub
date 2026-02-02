import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../controllers/activity_controller.dart';
import '../../../../../models/order_model.dart';
import '../../../../routes/app_routes.dart';

class EmployerActivityCard extends StatelessWidget {
  final ActivityModel activity;

  const EmployerActivityCard({super.key, required this.activity});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Title & Status)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
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
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // 2. Body (Meta & Stats)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Meta Row
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today_outlined,
                        order.jobDate != null
                            ? DateFormat('d MMM yyyy').format(order.jobDate!)
                            : 'N/A',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.location_on_outlined,
                        order.location ?? 'Lokasi tidak tersedia',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats Row (Pelamar vs Diterima)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                          'Pelamar', '$applicants', Icons.people_outline),
                      Container(
                          height: 24, width: 1, color: Colors.grey.shade300),
                      _buildStatItem('Diterima', '$accepted / $quota',
                          Icons.check_circle_outline,
                          isHighlight: accepted >= quota),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.toNamed(Routes.EMPLOYER_ACTIVITY_DETAIL,
                          arguments: order);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Detail'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Direct to Detail for now, maybe with flag to open applicants tab if we had tabs
                      Get.toNamed(Routes.EMPLOYER_ACTIVITY_DETAIL,
                          arguments: order);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Lihat Pelamar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      {bool isHighlight = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isHighlight ? AppColors.primaryGreen : Colors.grey),
            const SizedBox(width: 4),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isHighlight
                        ? AppColors.primaryGreen
                        : AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
        return ('Tersedia', const Color(0xFFE3F2FD), Colors.blue);
      case 'closed':
        return ('Ditutup', const Color(0xFFFFEBEE), Colors.red);
      default:
        return (status.toUpperCase(), Colors.grey.shade100, Colors.grey);
    }
  }
}
