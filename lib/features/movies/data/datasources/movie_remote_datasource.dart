import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/movie_model.dart';



class MovieRemoteDatasource {
  MovieRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.popularMovies,
        queryParameters: {
          'page': page,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;

      return results
          .map((movieJson) {
            return MovieModel.fromJson(movieJson as Map<String, dynamic>);
          })
          .toList();
    } on DioException catch (error) {
      throw AppException(
        error.message ?? 'Filmler yüklenirken bir ağ hatası oluştu.',
      );
    } catch (_) {
      throw AppException('Filmler yüklenirken beklenmeyen bir hata oluştu.');
    }
  }
} 