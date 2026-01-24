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
      backgroundColor: AppColors.primaryWhite,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Hero Section
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: const BoxDecoration(
                      color: AppColors.pastelGreen,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo_kerjocurup.png',
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Selamat Datang di KerjoCurup',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight
                          .w700, // Reduced from w800 for better legibility
                      height: 1.2,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(
                      height: 12), // Reduced from 16 for tighter grouping
                  const Text(
                    'Platform penghubung Petani dan Penyedia Jasa Angkut',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const Spacer(),

                  // Bottom Action
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: OjekButton(
                          text: 'Masuk dengan Google',
                          icon: Icons.login,
                          isLoading: controller.isLoading.value,
                          onPressed: controller.login,
                        ),
                      )),

                  const SizedBox(height: 32),
                  const Text(
                    'Versi 1.0.0',
                    style: TextStyle(
                        color: AppColors.textPlaceholder, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Loading overlay
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black54,
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
