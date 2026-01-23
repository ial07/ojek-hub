import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import '../../../../routes.dart';

class RoleSelectionView extends GetView<OnboardingController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Peran')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Siapa Anda?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih peran untuk melanjutkan pendaftaran',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            _buildRoleCard(
              'Petani', 
              'Saya pemilik lahan yang butuh tenaga kerja',
              Icons.agriculture,
              'petani',
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              'Gudang', 
              'Saya pemilik gudang yang butuh tenaga angkut',
              Icons.store,
              'warehouse',
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              'Pekerja', 
              'Saya mencari pekerjaan (Ojek / Harian)',
              Icons.work,
              'worker',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(String title, String subtitle, IconData icon, String value) {
    return Obx(() {
      final isSelected = controller.selectedRole.value == value;
      return InkWell(
        onTap: () {
          controller.selectedRole.value = value;
          if (value == 'worker') {
             // If worker, show bottom sheet or dialog for type, or simple expand
             // For Flow simplicity: Navigate to next step or expand inline?
             // Let's navigate to Profile Setup directly, but pass logic to check worker type there?
             // Prompt says: "Worker must select worker_type".
             // Let's show a dialog for Worker Type immediately if Worker is clicked.
             _showWorkerTypeDialog();
          } else {
             // Go to Profile Setup
             controller.selectedWorkerType.value = ''; // clear
             Get.toNamed(Routes.PROFILE_SETUP);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.green),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      );
    });
  }

  void _showWorkerTypeDialog() {
    Get.defaultDialog(
      title: 'Pilih Jenis Pekerjaan',
      content: Column(
        children: [
          ListTile(
            title: const Text('Ojek (Motor)'),
            subtitle: const Text('Transportasi & Angkut'),
            leading: const Icon(Icons.motorcycle),
            onTap: () {
              controller.selectedWorkerType.value = 'ojek';
              Get.back();
              Get.toNamed(Routes.PROFILE_SETUP);
            },
          ),
          ListTile(
            title: const Text('Pekerja Harian'),
            subtitle: const Text('Panen, Loading, dll'),
            leading: const Icon(Icons.people),
            onTap: () {
              controller.selectedWorkerType.value = 'pekerja';
              Get.back();
              Get.toNamed(Routes.PROFILE_SETUP);
            },
          ),
        ],
      ),
    );
  }
}
