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
    final employerName =
        job.employerName ?? 'Penyedia Kerja'; // Fallback if null

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
                // 0. Employer Identity (Trust Signal)
                Row(
                  children: [
                    const Icon(Icons.business,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      employerName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 1. Job Title (Large, Bold + Hero)
                Hero(
                  tag: 'job_title_${job.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      job.title ?? 'Lowongan Pekerjaan',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
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

                // 4. Date Detail
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: AppColors.textPlaceholder),
                    const SizedBox(width: 6),
                    Text(
                      friendlyDate,
                      style: const TextStyle(
                        fontSize:
                            13, // Kept 13px per visual balance, metadata above bumped
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 5. Secondary Action (Link Button - Outlined/Chip style)
                if (job.mapUrl != null && onMap != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton.icon(
                        onPressed: onMap,
                        icon: const Icon(Icons.map_outlined,
                            size: 16, color: AppColors.primaryGreen),
                        label: const Text('Lihat Peta',
                            style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(color: AppColors.primaryGreen),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),

                // 6. Primary Action (Handle Full State & Application Status)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (isQuotaFull || job.hasApplied) ? null : onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isQuotaFull
                          ? Colors.grey.shade300
                          : (job.applicationStatus == 'accepted'
                              ? Colors.blue.shade100
                              : AppColors.primaryGreen),
                      disabledBackgroundColor:
                          job.applicationStatus == 'accepted'
                              ? Colors.blue.shade100
                              : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      disabledForegroundColor:
                          job.applicationStatus == 'accepted'
                              ? Colors.blue.shade800
                              : Colors.grey.shade600,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _getButtonLabel(),
                      style: const TextStyle(
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

  String _getButtonLabel() {
    if (job.applicationStatus == 'accepted') return 'Diterima';
    if (job.applicationStatus == 'rejected') return 'Ditolak'; // Optional
    if (job.hasApplied) return 'Sudah Dilamar';
    if ((job.acceptedCount ?? 0) >= (job.totalWorkers ?? 1)) {
      return 'Kuota Penuh';
    }
    return 'Lamar Pekerjaan';
  }

  Widget _buildInfoIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14, // Bumped to 14px per audit
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
