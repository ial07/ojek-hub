import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes.dart';

class AuthService extends GetxService {
  final _supabase = Supabase.instance.client;
  final Rx<User?> currentUser = Rx<User?>(null);
  
  // Storage for our custom user profile (fetched from backend)
  final RxMap<String, dynamic> userProfile = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _supabase.auth.currentUser;
    
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      if (data.event == AuthChangeEvent.signedOut) {
        userProfile.clear();
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }
  
  bool get isLoggedIn => currentUser.value != null;
  
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    // Logic for Google SignOut if needed provided by controller
  }
}
