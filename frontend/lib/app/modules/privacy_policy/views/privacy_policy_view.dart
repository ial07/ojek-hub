import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/privacy_policy_controller.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Kebijakan Privasi',
          style: TextStyle(
              color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlack),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terakhir Diperbarui: 27 Januari 2026',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),
            _buildSection('1. Pendahuluan',
                'KerjoCurup ("Aplikasi") berkomitmen untuk melindungi privasi pengguna kami. Kebijakan ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi informasi Anda saat menggunakan layanan kami.'),
            _buildSection(
                '2. Informasi yang Kami Kumpulkan',
                'Agar Aplikasi dapat berfungsi dengan baik sebagai penghubung antara Pekerja dan Pemberi Kerja, kami mengumpulkan data berikut:\n\n'
                    '• Informasi Akun: Nama, Alamat Email, dan Nomor Telepon untuk identifikasi dan komunikasi.\n'
                    '• Data Lokasi: Kami mengakses lokasi Anda (tepat atau perkiraan) untuk menampilkan lowongan pekerjaan di sekitar Anda. Data ini digunakan untuk fitur "Lowongan Terdekat".\n'
                    '• Foto Profil: Untuk verifikasi identitas antar pengguna.'),
            _buildSection(
                '3. Penggunaan Informasi',
                'Data Anda digunakan semata-mata untuk:\n'
                    '• Memverifikasi akun dan keamanan.\n'
                    '• Menghubungkan Anda dengan pekerjaan atau pekerja yang relevan.\n'
                    '• Menampilkan peta lokasi pekerjaan.\n'
                    '• Menghubungi Anda melalui WhatsApp (jika Anda melamar atau membuat lowongan).'),
            _buildSection(
                '4. Pihak Ketiga',
                'Kami menggunakan layanan pihak ketiga terpercaya:\n'
                    '• Supabase: Untuk penyimpanan database dan autentikasi yang aman.\n'
                    '• Google Maps: Untuk layanan peta dan lokasi.'),
            _buildSection('5. Keamanan Data',
                'Kami menerapkan langkah-langkah keamanan standar industri untuk melindungi data Anda dari akses yang tidak sah. Data sensitif disimpan di server yang aman.'),
            _buildSection('6. Penghapusan Akun',
                'Anda memiliki hak untuk meminta penghapusan seluruh data akun Anda. Jika Anda ingin menghapus akun, silakan hubungi kami melalui email di bawah ini.'),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Hubungi Kami',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jika ada pertanyaan tentang privasi atau permintaan penghapusan data, hubungi:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            const SelectableText(
              'ialilham77@gmail.com',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
