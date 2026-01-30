import 'package:flutter/material.dart';
import 'package:KerjoCurup/core/theme/app_colors.dart';
import 'package:KerjoCurup/core/utils/date_helper.dart';
import 'package:KerjoCurup/models/order_model.dart';

class JobCard extends StatelessWidget {
  final OrderModel job;
  final VoidCallback? onApply;
  final VoidCallback? onMap;
  final VoidCallback? onTap; // Added onTap

  const JobCard({
    super.key,
    required this.job,
    this.onApply,
    this.onMap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine labels
    final dateLabel = DateHelper.getRelativeLabel(job.jobDate);
    final friendlyDate = DateHelper.formatJobDate(job.jobDate);
    final isQuotaFull = (job.acceptedCount ?? 0) >= (job.totalWorkers ?? 1);
    final location = job.location ?? 'Lokasi tidak tersedia';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Job Title (Large, Bold)
                Text(
                  job.title ?? 'Lowongan Pekerjaan',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // 2. Job Description (Max 2 lines)
                Text(
                  job.description ?? 'Tidak ada deskripsi pekerjaan.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Key Information Row (Time | Location | Quota)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildInfoIcon(Icons.access_time_filled,
                          dateLabel.isNotEmpty ? dateLabel : 'Mendatang'),
                      _buildDivider(),
                      _buildInfoIcon(
                          Icons.location_on, _truncate(location, 12)),
                      _buildDivider(),
                      _buildInfoIcon(
                          Icons.people, '${job.totalWorkers ?? 1} Orang'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Date Detail (Small, Gray)
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.textPlaceholder),
                    const SizedBox(width: 6),
                    Text(
                      friendlyDate,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 5. Secondary Action (Link Button)
                if (job.mapUrl != null && onMap != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: onMap,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          const Icon(Icons.map_outlined,
                              size: 16, color: AppColors.primaryGreen),
                          const SizedBox(width: 8),
                          const Text(
                            'Lihat Peta',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 6. Only show Primary Action if NOT full
                if (!isQuotaFull)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Lamar Pekerjaan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 12,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  String _truncate(String text, int length) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }
}
