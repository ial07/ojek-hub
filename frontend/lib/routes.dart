import 'package:get/get.dart';
import 'modules/auth/auth_binding.dart';
import 'modules/auth/auth_page.dart';
import 'modules/role/role_binding.dart';
import 'modules/role/role_page.dart';
import 'modules/role/worker_type_page.dart';
import 'modules/orders/orders_binding.dart';
import 'modules/orders/order_list_page.dart';
import 'modules/queue/queue_binding.dart';
import 'modules/queue/queue_widget.dart';
import 'modules/profile/profile_binding.dart';
import 'modules/profile/profile_page.dart';
import 'app/modules/splash/views/splash_view.dart';
import 'app/modules/splash/bindings/splash_binding.dart';
import 'app/modules/home_employer/bindings/home_employer_binding.dart';
import 'app/modules/home_employer/views/home_employer_view.dart';
import 'app/modules/home_worker/bindings/home_worker_binding.dart';
import 'app/modules/home_worker/views/home_worker_view.dart';
import 'app/modules/create_job/bindings/create_job_binding.dart';
import 'app/modules/create_job/views/create_job_view.dart';
import 'app/modules/main/bindings/main_binding.dart';
import 'app/modules/main/views/main_view.dart';

class Routes {
  static const login = '/login';
  static const role = '/role';
  static const workerType = '/worker-type';
  static const orders = '/orders'; // Open Orders List (General/Worker)
  static const createOrder = '/orders/create';
  static const profile = '/profile';
  static const queue = '/queue';

  static const homeById = '/home'; // Logic to decide?
  static const homeEmployer = '/home/employer';
  static const homeWorker = '/home/worker';

  // Aliases for compatibility with older generated code
  static const LOGIN = login;
  static const ROLE_SELECTION = role;
  static const WORKER_TYPE = workerType;
  static const ORDERS = orders;
  static const CREATE_JOB = createOrder;
  static const QUEUE_VIEW = queue;
  static const PROFILE_SETUP =
      '/profile/setup'; // Assuming this was what was meant? Or generic profile.
  static const PROFILE = profile;
  static const HOME_WORKER = homeWorker;
  static const HOME_EMPLOYER = homeEmployer;
  static const SPLASH = '/splash';
  static const MAIN = '/main';
  static const LANDING = '/landing';
}

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const AuthPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.role,
      page: () => const RolePage(),
      binding: RoleBinding(),
    ),
    GetPage(
      name: Routes.workerType,
      page: () => const WorkerTypePage(),
      binding: RoleBinding(),
    ),
    GetPage(
      name: Routes.orders,
      page: () => const OrderListPage(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: Routes.createOrder,
      page: () => const CreateJobView(),
      binding: CreateJobBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.queue,
      page: () => const QueueWidget(),
      binding: QueueBinding(),
    ),
    GetPage(
      name: Routes.homeEmployer,
      page: () => const HomeEmployerView(),
      binding: HomeEmployerBinding(),
    ),
    GetPage(
      name: Routes.homeWorker,
      page: () => const HomeWorkerView(),
      binding: HomeWorkerBinding(),
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
  ];
}
