// app_routes.dart - Synchronized with /lib/routes.dart
abstract class Routes {
  Routes._();
  static const SPLASH = '/splash';
  static const LANDING = '/landing'; // New
  static const LOGIN = '/login';
  static const ROLE_SELECTION = '/role';
  static const MAIN = '/main'; // New BottomNav Wrapper
  static const WORKER_TYPE = '/worker-type';
  static const PROFILE_SETUP = '/profile/setup';
  static const PROFILE = '/profile';
  static const HOME_EMPLOYER = '/home/employer';
  static const HOME_WORKER = '/home/worker';
  static const CREATE_JOB = '/orders/create';
  static const ORDERS = '/orders';
  static const QUEUE_VIEW = '/queue';
  static const JOB_DETAIL = '/orders/detail';
  static const EMPLOYER_ACTIVITY_DETAIL =
      '/orders/employer-detail'; // New Route
  static const PRIVACY_POLICY = '/privacy-policy';
}
