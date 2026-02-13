import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

class OjekHubApp extends StatelessWidget {
  const OjekHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KerjoCurup',
      theme: AppTheme.lightTheme,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      // Fallback for unknown routes - Redirect to Main (Home)
      unknownRoute: GetPage(
        name: Routes.NOT_FOUND,
        page: () => const Scaffold(
          body: Center(child: Text('Halaman tidak ditemukan')),
        ),
      ),
    );
  }
}
