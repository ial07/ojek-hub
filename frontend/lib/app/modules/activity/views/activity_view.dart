import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/activity_controller.dart';
import 'widgets/activity_list_card.dart';
import 'widgets/employer_activity_card.dart';

class ActivityView extends GetView<ActivityController> {
  const ActivityView({super.key});

  @override
  Widget build(BuildContext context) {
    // Check role from controller getter logic (reactive-ish if rebuild occurs, but role is static per session mostly)
    final bool isEmployer = controller.isEmployer;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEmployer ? 'Lowongan Saya' : 'Aktivitas Saya',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              isEmployer
                  ? 'Pantau lamaran masuk'
                  : 'Pantau semua lamaran dan pekerjaanmu',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchActivities,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        // Check overall emptiness
        if (controller.activities.isEmpty) {
          return _buildGlobalEmptyState(isEmployer);
        }

        // EMPLOYER UI: Flat List
        if (isEmployer) {
          return RefreshIndicator(
            onRefresh: controller.fetchActivities,
            color: AppColors.primaryGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.activities.length,
              itemBuilder: (context, index) {
                final activity = controller.activities[index];
                return EmployerActivityCard(activity: activity);
              },
            ),
          );
        }

        // WORKER UI: Timeline Sections
        return RefreshIndicator(
          onRefresh: controller.fetchActivities,
          color: AppColors.primaryGreen,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Hari Ini (High Priority)
              if (controller.todayActivities.isNotEmpty) ...[
                _buildSectionHeader(
                    'HARI INI', Icons.today, AppColors.primaryGreen),
                ...controller.todayActivities.map(
                    (a) => ActivityListCard(activity: a, isFeatured: true)),
                const SizedBox(height: 12),
              ],

              // 2. Besok
              if (controller.tomorrowActivities.isNotEmpty) ...[
                _buildSectionHeader('BESOK', Icons.event, Colors.orange),
                ...controller.tomorrowActivities.map((a) => ActivityListCard(
                    activity: a,
                    isFeatured: false)), // isFeatured false for Tomorrow
                const SizedBox(height: 12),
              ],

              // 3. Mendatang
              if (controller.upcomingActivities.isNotEmpty) ...[
                _buildSectionHeader(
                    'AKAN DATANG', Icons.date_range, Colors.blue),
                ...controller.upcomingActivities
                    .map((a) => ActivityListCard(activity: a)),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 8),

              // 4. 7 Hari Terakhir (Recent History)
              if (controller.recentHistoryActivities.isNotEmpty) ...[
                _buildSectionHeader(
                    '7 HARI TERAKHIR', Icons.history, Colors.grey.shade700),
                ...controller.recentHistoryActivities
                    .map((a) => ActivityListCard(activity: a)),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 8),

              // 5. Riwayat Lama
              if (controller.olderHistoryActivities.isNotEmpty) ...[
                _buildSectionHeader(
                    'RIWAYAT LAMA', Icons.history_edu, Colors.grey.shade500),
                ...controller.olderHistoryActivities
                    .map((a) => ActivityListCard(activity: a)),
              ],

              // Bottom padding
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Divider(color: color.withValues(alpha: 0.2), thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildGlobalEmptyState(bool isEmployer) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEmployer ? Icons.post_add : Icons.work_off_outlined,
              size: 48,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isEmployer
                ? 'Belum ada lowongan dibuat.'
                : 'Belum ada aktivitas lamaran.',
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: Colors.grey, height: 1.5, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(
              onPressed: () {
                // Assuming navigation to Home is handled by parent or BottomNav
                // For now just refresh
                controller.fetchActivities();
              },
              child: Text(isEmployer ? 'Refresh' : 'Cari Lowongan'))
        ],
      ),
    );
  }
}
