import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ojek_button.dart';
import '../../../../core/widgets/ojek_header.dart';
import '../../../../core/widgets/ojek_input.dart';
import '../controllers/create_job_controller.dart';

class CreateJobView extends GetView<CreateJobController> {
  const CreateJobView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: const OjekHeader(
        title: 'Buat Lowongan',
        showBack: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Worker Type Dropdown (Custom styled)
                    const Text('Jenis Pekerja',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.inputBackground,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.workerType.value,
                              isExpanded: true,
                              icon: const Icon(
                                  Icons.arrow_drop_down_circle_outlined),
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Plus Jakarta Sans'),
                              items: const [
                                DropdownMenuItem(
                                    value: 'ojek',
                                    child: Text('Ojek (Motor/Angkut)')),
                                DropdownMenuItem(
                                    value: 'pekerja',
                                    child:
                                        Text('Pekerja Harian (Tani/Gudang)')),
                              ],
                              onChanged: controller.setWorkerType,
                            ),
                          ),
                        )),

                    const SizedBox(height: 24),

                    // Worker Count
                    OjekInput(
                      label: 'Jumlah Orang',
                      hint: 'Contoh: 5',
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      validator: (val) => (int.tryParse(val ?? '') ?? 0) > 0
                          ? null
                          : 'Minimal 1 orang',
                      onChanged: controller.setWorkerCount,
                    ),

                    const SizedBox(height: 24),

                    // Location
                    OjekInput(
                      label: 'Lokasi Pekerjaan',
                      hint: 'Alamat lengkap / Nama Desa',
                      controller: controller.locationController,
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                      suffixIcon: const Icon(Icons.location_on_outlined,
                          color: AppColors.textPlaceholder),
                    ),

                    const SizedBox(height: 24),

                    // Date Picker
                    OjekInput(
                      label: 'Tanggal Pelaksanaan',
                      hint: 'Pilih Tanggal',
                      controller: controller.dateController,
                      readOnly: true,
                      suffixIcon: const Icon(Icons.calendar_today_outlined,
                          color: AppColors.textPlaceholder),
                      onTap: () => controller.pickDate(context),
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                    ),

                    const SizedBox(height: 24),

                    // Description
                    OjekInput(
                      label: 'Deskripsi Pekerjaan',
                      hint: 'Jelaskan detail tugas, jam kerja, dsb...',
                      controller: controller.descriptionController,
                      maxLines: 4,
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                    ),

                    const SizedBox(height: 32), // Bottom padding for scroll
                  ],
                ),
              ),
            ),
          ),

          // Sticky Bottom Button
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
            child: Obx(() => OjekButton(
                  text: 'Posting Lowongan',
                  icon: Icons.send_rounded,
                  isLoading: controller.isLoading.value,
                  onPressed: controller.submitOrder,
                )),
          ),
        ],
      ),
    );
  }
}

// Extension to support initialValue in OjekInput without breaking encapsulation too much
// We'll modify OjekInput to accept initialValue or just handle it here.
// Actually since we didn't add initialValue to OjekInput, let's fix that or use controller.
// The original code used TextFormField(initialValue: '1').
// Let's assume we modify OjekInput or use a controller for count.
// Since OjekInput wraps TextFormField, we should add initialValue support to it.
