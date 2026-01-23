import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/queue_controller.dart';

class QueueView extends GetView<QueueController> {
  const QueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Antrian')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.queueList.isEmpty) {
          return const Center(child: Text('Belum ada pekerja yang bergabung'));
        }

        return ListView.builder(
          itemCount: controller.queueList.length,
          itemBuilder: (context, index) {
            final item = controller.queueList[index];
            final worker = item['worker'] ?? {};
            final joinedAt = item['created_at'];
            final status = item['status'] ?? 'pending';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    status == 'accepted' ? Colors.green : Colors.grey,
                child: Text('${index + 1}'),
              ),
              title: Text(worker['name'] ?? 'Nama Tidak Ada'),
              subtitle: Text(
                  'Status: $status\nTanggal: ${joinedAt != null ? joinedAt.toString().split('T')[0] : "-"}'),
              isThreeLine: true,
              trailing: (worker['phone'] != null &&
                      worker['phone'].toString().isNotEmpty)
                  ? IconButton(
                      icon: const Icon(Icons.chat, color: Colors.green),
                      onPressed: () => controller.openWhatsApp(worker['phone']),
                    )
                  : null,
            );
          },
        );
      }),
    );
  }
}
