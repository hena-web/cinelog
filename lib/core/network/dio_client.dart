import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../env/env.dart';

class DioClient {
  DioClient()
      : dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            queryParameters: {
              'api_key': Env.tmdbApiKey,
              'language': 'tr-TR',
            },
          ),
        );

  final Dio dio;
}