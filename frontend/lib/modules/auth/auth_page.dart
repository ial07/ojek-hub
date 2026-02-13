import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_button.dart';
import 'auth_controller.dart';

class AuthPage extends GetView<AuthController> {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: SizedBox.expand(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60), // Top spacing

                    // 1. Logo (Larger, No Background)
                    Image.asset(
                      'assets/images/logo_kerjocurup.png',
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 40),

                    // 2. Headings
                    const Text(
                      'Solusi Kerja Harian & Ojek',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.5,
                        color: AppColors.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Penghubung cepat antara pekerja lokal dan masyarakat yang membutuhkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // 3. Login Button
                    Obx(() => OjekButton(
                          text: 'Lanjutkan dengan Google',
                          icon: Icons.login,
                          isLoading: controller.isLoading.value,
                          onPressed: controller.login,
                        )),

                    const SizedBox(height: 24),

                    // 4. Trust & Role Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline,
                                  size: 16, color: AppColors.textSecondary),
                              SizedBox(width: 8),
                              Text(
                                'Data terenkripsi & aman',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Anda bisa memilih peran (Pekerja/Pemberi Kerja) setelah masuk.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // 5. Version
                    const Text(
                      'Versi 1.5.0',
                      style: TextStyle(
                        color: AppColors.textPlaceholder,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Memproses login...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
