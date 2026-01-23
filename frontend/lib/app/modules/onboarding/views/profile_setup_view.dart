import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class ProfileSetupView extends GetView<OnboardingController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController(); // WhatsApp number
    final TextEditingController locationController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Lengkapi Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() => Text(
              controller.isWorker 
                  ? 'Daftar sebagai ${controller.selectedWorkerType.value == 'ojek' ? 'Ojek' : 'Pekerja Harian'}'
                  : 'Daftar sebagai ${controller.selectedRole.value == 'petani' ? 'Petani' : 'Pemilik Gudang'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
            const SizedBox(height: 24),
            
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Nomor WhatsApp',
                hintText: 'Contoh: 08123456789',
                prefixIcon: Icon(Icons.phone),
                helperText: 'Nomor ini akan digunakan untuk komunikasi',
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasi / Desa',
                hintText: 'Contoh: Desa Suban',
                prefixIcon: Icon(Icons.map),
              ),
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && 
                    phoneController.text.isNotEmpty && 
                    locationController.text.isNotEmpty) {
                  controller.register(
                    nameController.text, 
                    phoneController.text, 
                    locationController.text
                  );
                } else {
                  Get.snackbar('Error', 'Mohon lengkapi semua data');
                }
              },
              child: const Text('Selesai'),
            ),
          ],
        ),
      ),
    );
  }
}
