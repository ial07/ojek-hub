import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../home_employer/views/home_employer_view.dart';
import '../../home_worker/views/home_worker_view.dart';
import '../../activity/views/activity_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // GUARD: Wait for Auth to be ready
      if (!controller.authController.isReady.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
        );
      }

      return Scaffold(
        // Prevent bottom nav issues when keyboard is animating/open during transition
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            // Tab 0: Home
            controller.isWorker
                ? const HomeWorkerView()
                : const HomeEmployerView(),

            // Tab 1: Activity/Jobs (Placeholder for now as requested default tabs)
            // Using a Scaffold to maintain styling consistency
            // Tab 1: Activity
            const ActivityView(),

            // Tab 2: Profile
            const ProfileView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 26,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.assignment_outlined),
              activeIcon: const Icon(Icons.assignment),
              label: controller.isWorker ? 'Lamaran' : 'Aktivitas',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      );
    });
  }
}
