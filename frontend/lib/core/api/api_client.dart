import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/env.dart';

class ApiClient extends GetxService {
  late Dio _dio;

  Future<ApiClient> init() async {
    _dio = Dio(BaseOptions(
      baseUrl: Env.baseApiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Log error (can be replaced with proper logging)
        print('API Error: [${e.response?.statusCode}] ${e.message}');
        if (e.response != null) {
          print('Response Data: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));

    return this;
  }

  Dio get dio => _dio;
}
