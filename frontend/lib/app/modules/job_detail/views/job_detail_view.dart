import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ojek_button.dart';
import '../controllers/job_detail_controller.dart';

class JobDetailView extends GetView<JobDetailController> {
  const JobDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final job = controller.job;

    // Safety check for map coordinates
    final hasCoordinates = job.latitude != null && job.longitude != null;
    final LatLng? jobLocation =
        hasCoordinates ? LatLng(job.latitude!, job.longitude!) : null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Detail Lowongan',
            style: TextStyle(
                color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlack),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.pastelGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          job.workerType?.toUpperCase() ?? 'PEKERJA',
                          style: const TextStyle(
                            color: AppColors.pastelGreenText,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        job.createdAt != null
                            ? DateFormat('dd MMM yyyy').format(job.createdAt!)
                            : 'Baru saja',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    job.title ?? 'Lowongan Pekerjaan',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Dibutuhkan ${job.totalWorkers} Orang',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 2. Map Card
                  if (hasCoordinates)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryWhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Map Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: AppColors.primaryGreen, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    job.location ?? 'Lokasi Pekerjaan',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Actual Map
                          SizedBox(
                            height: 180,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(
                                      0)), // Flat bottom for footer
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: jobLocation!,
                                  initialZoom: 14.0,
                                  interactionOptions: const InteractionOptions(
                                      flags:
                                          InteractiveFlag.none), // Static map
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.example.ojekhub_mobile',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: jobLocation,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(Icons.location_on,
                                            color: AppColors.primaryGreen,
                                            size: 40),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Map Footer (Distance & Action)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                                border: Border(
                                    top: BorderSide(
                                        color: AppColors.borderLight))),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Obx(() {
                                    if (controller.isLoadingLocation.value) {
                                      return const Text('Menghitung jarak...',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary));
                                    }
                                    if (controller.distanceText.value != null) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Jarak dari anda",
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      AppColors.textSecondary)),
                                          Text(
                                            controller.distanceText.value!,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryBlack),
                                          ),
                                        ],
                                      );
                                    }
                                    return const Text('Lokasi aktif',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary));
                                  }),
                                ),
                                OutlinedButton.icon(
                                  onPressed: controller.openMap,
                                  icon: const Icon(Icons.map, size: 16),
                                  label: const Text('Buka Google Maps'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryGreen,
                                    side: const BorderSide(
                                        color: AppColors.primaryGreen),
                                    visualDensity: VisualDensity.compact,
                                    textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                  if (job.employerPhone != null &&
                      job.employerPhone!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: controller.openWhatsApp,
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Hubungi via WhatsApp'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(color: AppColors.primaryGreen),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 3. Description
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job.description ?? 'Tidak ada deskripsi',
                    style: const TextStyle(
                        color: AppColors.textSecondary, height: 1.5),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // 4. Sticky Apply Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: OjekButton(
                text: 'Lamar Pekerjaan',
                onPressed: controller.applyJob,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
