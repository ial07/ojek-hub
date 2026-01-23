import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'orders_controller.dart';

class CreateOrderPage extends GetView<OrdersController> {
  const CreateOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final countController = TextEditingController(text: '1');
    final locationController = TextEditingController();
    final workerType = 'daily'.obs; // 'ojek' or 'daily' (pekerja)

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Lowongan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Worker Type Selection
            const Text(
              'Tipe Pekerja yang Dibutuhkan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildTypeCard(
                        'Ojek (Motor)',
                        Icons.motorcycle,
                        workerType.value == 'ojek',
                        () => workerType.value = 'ojek',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeCard(
                        'Pekerja Harian',
                        Icons.person,
                        workerType.value == 'daily',
                        () => workerType.value = 'daily',
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 24),

            // Title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Pekerjaan',
                hintText: 'Contoh: Panen Cabe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Detail pekerjaan...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Location
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasi',
                hintText: 'Desa / Kecamatan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),

            // Worker Count
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Pekerja',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      final desc = descController.text.trim();
                      final location = locationController.text.trim();
                      final count = int.tryParse(countController.text) ?? 1;

                      if (title.isEmpty) {
                        Get.snackbar('Error', 'Judul pekerjaan harus diisi');
                        return;
                      }
                      if (desc.isEmpty) {
                        Get.snackbar('Error', 'Deskripsi harus diisi');
                        return;
                      }
                      if (location.isEmpty) {
                        Get.snackbar('Error', 'Lokasi harus diisi');
                        return;
                      }
                      if (count < 1) {
                        Get.snackbar('Error', 'Jumlah pekerja minimal 1');
                        return;
                      }

                      controller.createOrderWithDetails(
                        title: title,
                        description: desc,
                        location: location,
                        workerCount: count,
                        workerType: workerType.value,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text(
                      'Posting Lowongan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(
      String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.green.shade50 : Colors.white,
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 32, color: isSelected ? Colors.green : Colors.grey),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? Colors.green.shade700 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
