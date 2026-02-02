import 'package:get/get.dart';
import 'package:KerjoCurup/modules/auth/auth_binding.dart';
import 'package:KerjoCurup/modules/auth/auth_page.dart';
import 'package:KerjoCurup/app/modules/create_job/bindings/create_job_binding.dart';
import 'package:KerjoCurup/app/modules/create_job/views/create_job_view.dart';
import 'package:KerjoCurup/app/modules/home_employer/bindings/home_employer_binding.dart';
import 'package:KerjoCurup/app/modules/home_employer/views/home_employer_view.dart';
import 'package:KerjoCurup/app/modules/home_worker/bindings/home_worker_binding.dart';
import 'package:KerjoCurup/app/modules/home_worker/views/home_worker_view.dart';
import 'package:KerjoCurup/app/modules/landing/bindings/landing_binding.dart';
import 'package:KerjoCurup/app/modules/landing/views/landing_view.dart';
import 'package:KerjoCurup/app/modules/main/bindings/main_binding.dart';
import 'package:KerjoCurup/app/modules/main/views/main_view.dart';
import 'package:KerjoCurup/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:KerjoCurup/app/modules/onboarding/views/profile_setup_view.dart';
import 'package:KerjoCurup/app/modules/onboarding/views/role_selection_view.dart';
import 'package:KerjoCurup/app/modules/queue/bindings/queue_binding.dart';
import 'package:KerjoCurup/app/modules/queue/views/queue_view.dart';
import 'package:KerjoCurup/app/modules/splash/bindings/splash_binding.dart';
import 'package:KerjoCurup/app/modules/splash/views/splash_view.dart';
import 'package:KerjoCurup/app/modules/job_detail/bindings/job_detail_binding.dart';
import 'package:KerjoCurup/app/modules/job_detail/views/job_detail_view.dart';
import 'package:KerjoCurup/app/modules/privacy_policy/bindings/privacy_policy_binding.dart';
import 'package:KerjoCurup/app/modules/privacy_policy/views/privacy_policy_view.dart';
import 'package:KerjoCurup/app/modules/activity/views/employer_activity_detail_view.dart';
import 'package:KerjoCurup/app/modules/activity/bindings/employer_activity_detail_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.LANDING,
      page: () => const LandingView(),
      binding: LandingBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const AuthPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.ROLE_SELECTION,
      page: () => const RoleSelectionView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.PROFILE_SETUP,
      page: () => const ProfileSetupView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.HOME_EMPLOYER,
      page: () => const HomeEmployerView(),
      binding: HomeEmployerBinding(),
    ),
    GetPage(
      name: Routes.HOME_WORKER,
      page: () => const HomeWorkerView(),
      binding: HomeWorkerBinding(),
    ),
    GetPage(
      name: Routes.CREATE_JOB,
      page: () => const CreateJobView(),
      binding: CreateJobBinding(),
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: Routes.QUEUE_VIEW,
      page: () => const QueueView(),
      binding: QueueBinding(),
    ),
    GetPage(
      name: Routes.JOB_DETAIL,
      page: () => const JobDetailView(),
      binding: JobDetailBinding(),
    ),
    GetPage(
      name: Routes.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
      binding: PrivacyPolicyBinding(),
    ),
    GetPage(
      name: Routes.EMPLOYER_ACTIVITY_DETAIL,
      page: () => const EmployerActivityDetailView(),
      binding: EmployerActivityDetailBinding(),
    ),
  ];
}
