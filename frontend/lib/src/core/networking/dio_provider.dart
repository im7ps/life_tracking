import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/auth_state_provider.dart';
import '../storage/storage_provider.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import 'server_settings_provider.dart';

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final storage = ref.watch(secureStorageProvider);
  final baseUrl = ref.watch(serverUrlProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      storage,
      onUnauthorized: () async {
        // 1. Cancella il token
        await storage.delete(key: StorageKeys.accessToken);
        // 2. Invalida lo stato di Auth (che triggera il Router redirect)
        ref.invalidate(authStateProvider);
      },
    ),
  );
  
  dio.interceptors.add(ErrorInterceptor());
  
  // Loggare SEMPRE per debug pivot
  dio.interceptors.add(LogInterceptor(
    responseBody: true, 
    requestBody: true,
    requestHeader: true,
    responseHeader: false,
  ));

  return dio;
}
