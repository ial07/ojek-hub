import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../controllers/activity_controller.dart';
import '../../../../../models/order_model.dart';

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
                'Kelola pelamar dari menu Lowongan',
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
}
