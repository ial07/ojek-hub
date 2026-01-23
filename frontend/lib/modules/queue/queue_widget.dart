import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ojek_button.dart';
import 'queue_controller.dart';

class QueueWidget extends GetView<QueueController> {
  const QueueWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Order & Antrian',
            style: TextStyle(
                color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlack),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryGreen),
                SizedBox(height: 16),
                Text('Memuat data...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // EMPLOYER VIEW: Show List of Applicants
        if (!controller.isWorker) {
          return _buildEmployerView(context);
        }

        // WORKER VIEW: Join Queue / Status
        return Column(
          children: [
            _buildOrderHeader(),
            Expanded(child: _buildWorkerView()),
          ],
        );
      }),
    );
  }

  // 1. Order Header (Compact summary)
  Widget _buildOrderHeader() {
    return Obx(() {
      final order = controller.order.value;
      if (order == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.pastelGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (order.status ?? 'OPEN').toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pastelGreenText),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  order.location ?? '-',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              order.title ?? 'Detail Lowongan',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary),
            ),
          ],
        ),
      );
    });
  }

  // 2. Employer View: List of Applicants (Mobile First)
  Widget _buildEmployerView(BuildContext context) {
    if (controller.queueList.isEmpty) {
      return Column(
        children: [
          _buildOrderHeader(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.people_outline,
                        size: 48, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  const Text('Belum ada pelamar',
                      style: TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildOrderHeader(),
        // Section Title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          color: Colors.white,
          child: Text(
            'Daftar Pelamar (${controller.queueList.length})',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 100), // Space for FAB maybe?
            itemCount: controller.queueList.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final item = controller.queueList[index];
              final worker = item['worker'] ?? {};
              final status = item['status'] ?? 'pending';

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onTap: () => _showApplicantBottomSheet(context, item),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: worker['photo_url'] != null
                      ? NetworkImage(worker['photo_url'])
                      : null,
                  child: worker['photo_url'] == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                title: Text(
                  worker['name'] ?? 'Pelamar',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      worker['phone'] ?? 'No HP tidak tersedia',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: _buildStatusBadge(status),
              );
            },
          ),
        ),
      ],
    );
  }

  // 3. Worker View: Queue Position
  Widget _buildWorkerView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.people_outline, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          Text(
            'Antrian Saat Ini: ${controller.queueList.length} Orang',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          if (controller.isJoined) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  const Text('Posisi Anda',
                      style: TextStyle(color: Colors.green)),
                  Text(
                    '#${controller.myPosition}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Silakan tunggu konfirmasi atau instruksi selanjutnya.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          ] else ...[
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OjekButton(
                text: 'AMBIL ORDER INI',
                isLoading: controller.joinLoading.value,
                onPressed: controller.joinQueue,
              ),
            ),
            const SizedBox(height: 16),
          ]
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }

  // 4. Bottom Sheet Interaction (The Core interaction)
  void _showApplicantBottomSheet(
      BuildContext context, Map<String, dynamic> item) {
    final worker = item['worker'] ?? {};
    final phone = worker['phone'];
    final workerId = worker['id'] ?? item['worker_id'];
    final isPending = (item['status'] ?? 'pending') == 'pending';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Worker Profile
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade100,
                backgroundImage: worker['photo_url'] != null
                    ? NetworkImage(worker['photo_url'])
                    : null,
                child: worker['photo_url'] == null
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                worker['name'] ?? 'Pelamar',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (phone != null)
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),

              const SizedBox(height: 32),

              // Actions
              if (phone != null && phone.toString().isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back(); // Close sheet first
                      controller.openWhatsApp(phone);
                    },
                    icon: const Icon(Icons.chat_bubble, color: Colors.white),
                    label: const Text('Chat WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF25D366), // WhatsApp Green
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              if (isPending && workerId != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                      controller.acceptApplicant(workerId);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Terima Lamaran'),
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
