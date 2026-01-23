import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'queue_controller.dart';
import '../../../../core/theme/app_colors.dart';

class QueueWidget extends GetView<QueueController> {
  const QueueWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Order & Antrian'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memuat data pelamar...',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // EMPLOYER VIEW: Show List of Applicants
        if (!controller.isWorker) {
          return _buildEmployerView();
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

  Widget _buildOrderHeader() {
    return Obx(() {
      final order = controller.order.value;
      if (order == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.title ?? 'Detail Lowongan',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  order.location ?? '-',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.pastelGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (order.status ?? 'OPEN').toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pastelGreenText),
                  ),
                ),
              ],
            ),
            if (order.description != null) ...[
              const SizedBox(height: 8),
              Text(
                order.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ]
          ],
        ),
      );
    });
  }

  Widget _buildEmployerView() {
    if (controller.queueList.isEmpty) {
      return Column(
        children: [
          _buildOrderHeader(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Belum ada pelamar',
                      style: TextStyle(color: Colors.grey)),
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
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.queueList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.queueList[index];
              final worker = item['worker'] ?? {};
              final status = item['status'] ?? 'pending';
              final isPending = status == 'pending';
              final workerId = worker['id'] ?? item['worker_id'];

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: worker['photo_url'] != null
                                ? NetworkImage(worker['photo_url'])
                                : null,
                            child: worker['photo_url'] == null
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  worker['name'] ?? 'Pekerja',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                // Contact Details - Prominent Actions
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Nomor WhatsApp',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey)),
                                          const SizedBox(height: 2),
                                          Text(
                                            worker['phone'] ?? '-',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (worker['phone'] != null &&
                                        worker['phone'].toString().isNotEmpty)
                                      ElevatedButton.icon(
                                        onPressed: () => controller
                                            .openWhatsApp(worker['phone']),
                                        icon: const Icon(Icons.chat, size: 18),
                                        label: const Text('Chat WhatsApp'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          visualDensity: VisualDensity.compact,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                      )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                    Icons.email, worker['email'] ?? '-'),
                                _buildDetailRow(Icons.location_on,
                                    worker['address'] ?? '-'),
                              ],
                            ),
                          ),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPending
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toString().toUpperCase(),
                              style: TextStyle(
                                  color:
                                      isPending ? Colors.orange : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      if (isPending) ...[
                        const Divider(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (workerId != null) {
                                controller.acceptApplicant(workerId);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('TERIMA LAMARAN'),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    if (text == '-' || text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

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
            const Text(
              'Apakah Anda ingin mengambil pekerjaan ini?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Obx(() => controller.joinLoading.value
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: controller.joinQueue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'AMBIL ORDER',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  )),
          ]
        ],
      ),
    );
  }
}
