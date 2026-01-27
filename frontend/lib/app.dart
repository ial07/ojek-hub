import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'routes.dart';

class OjekHubApp extends StatelessWidget {
  const OjekHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KerjoCurup',
      theme: AppTheme.lightTheme,
      initialRoute: Routes.login,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
