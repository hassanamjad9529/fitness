// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../constants/app_constants.dart';

// class ApiClient {
//   final Dio _dio;
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   ApiClient()
//       : _dio = Dio(BaseOptions(
//           baseUrl: AppConstants2.baseUrl,
//           headers: {'Content-Type': 'application/json'},
//         )) {
//     _dio.interceptors.add(InterceptorsWrapper(
//       onRequest: (options, handler) async {
//         final token = await _storage.read(key: 'access_token');
//         if (token != null) {
//           options.headers['Authorization'] = 'Bearer $token';
//         }
//         return handler.next(options);
//       },
//       onError: (error, handler) async {
//         if (error.response?.statusCode == 401) {
//           await _storage.deleteAll();
//           // Navigate to login (handled in controller)
//         }
//         return handler.next(error);
//       },
//     ));
//   }

//   Future<Response> post(String path, {dynamic data}) => _dio.post(path, data: data);

//   Future<void> saveToken(String token) async =>
//       await _storage.write(key: 'access_token', value: token);

//   Future<void> clearToken() async => await _storage.delete(key: 'access_token');
// }