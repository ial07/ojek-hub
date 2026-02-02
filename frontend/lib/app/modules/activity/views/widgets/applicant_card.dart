import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';

class ApplicantCard extends StatelessWidget {
  final Map<String, dynamic>
      application; // Join result: includes 'status', 'worker' map
  final Function(String) onAccept;
  final Function(String) onReject;
  final Function(String, String) onContact; // phone, jobTitle

  const ApplicantCard({
    super.key,
    required this.application,
    required this.onAccept,
    required this.onReject,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final status = application['status'] ?? 'pending';
    final worker = application['worker'] ?? {};
    final String name = worker['name'] ?? 'Pelamar';
    final String photoUrl = worker['photo_url'] ?? '';
    final String role = worker['worker_type'] ?? 'Pekerja'; // 'daily' usually
    final String phone = worker['phone'] ?? '';

    // Status Config
    final statusConfig = _getStatusConfig(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                child: photoUrl.isEmpty
                    ? Text(name[0],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role == 'daily'
                          ? 'Pekerja Harian'
                          : role.capitalizeFirst!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          const SizedBox(height: 16),

          // ACTIONS
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onReject(application['id']),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAccept(application['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Terima'),
                  ),
                ),
              ],
            )
          else if (status == 'accepted')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => onContact(phone,
                    'pekerjaan ini'), // Job title passed from view usually
                icon: const Icon(Icons.chat_bubble, size: 16),
                label: const Text('Hubungi via WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            )
          else
            // Rejected or others
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  (String, Color, Color) _getStatusConfig(String status) {
    switch (status) {
      case 'accepted':
        return ('Diterima', const Color(0xFFE8F5E9), AppColors.primaryGreen);
      case 'rejected':
        return ('Ditolak', const Color(0xFFFFEBEE), Colors.red);
      case 'pending':
        return ('Menunggu', const Color(0xFFFFF3E0), Colors.orange);
      default:
        return (status, Colors.grey.shade100, Colors.grey);
    }
  }
}
