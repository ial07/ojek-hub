import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class EmployerSummaryWidget extends StatelessWidget {
  final int activeCount;
  final int actionCount;
  final int completedCount;
  final Function(String section) onSectionTap;

  const EmployerSummaryWidget({
    super.key,
    required this.activeCount,
    required this.actionCount,
    required this.completedCount,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildSummaryCard(
            'Perlu Tindakan',
            actionCount,
            Colors.orange,
            Icons.warning_amber_rounded,
            'action',
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            'Lowongan Aktif',
            activeCount,
            AppColors.primaryGreen,
            Icons.work_outline,
            'active',
          ),
          const SizedBox(width: 12),
          _buildSummaryCard(
            'Selesai',
            completedCount,
            Colors.grey,
            Icons.check_circle_outline,
            'history',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, int count, Color color, IconData icon, String sectionKey) {
    return GestureDetector(
      onTap: () => onSectionTap(sectionKey),
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(minWidth: 140),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const Spacer(),
                if (count > 0 && sectionKey == 'action')
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
