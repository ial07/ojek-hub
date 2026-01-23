import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_button.dart';
import 'auth_controller.dart';

class AuthPage extends GetView<AuthController> {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check session after first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      controller.checkSessionAndRedirect();
    });

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Hero Section
              Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.agriculture,
                    size: 80, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 32),

              const Text(
                'Selamat Datang di\nOjekHub',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Platform penghubung Petani dan\nPenyedia Jasa Angkut',
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

              const SizedBox(height: 16),
              const Text(
                'Versi 1.0.0',
                style:
                    TextStyle(color: AppColors.textPlaceholder, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
