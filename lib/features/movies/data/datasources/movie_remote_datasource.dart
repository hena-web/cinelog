import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/movie_detail_model.dart';
import '../models/movie_model.dart';

class MovieRemoteDatasource {
  MovieRemoteDatasource(this._dio);

  final Dio _dio;

  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        ApiConstants.popularMovies,
        queryParameters: {'page': page},
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;

      return results.map((movieJson) {
        return MovieModel.fromJson(movieJson as Map<String, dynamic>);
      }).toList();
    } on DioException catch (error) {
      throw AppException(
        error.message ?? 'A network error occurred while loading movies.',
      );
    } catch (_) {
      throw AppException('An unexpected error occurred while loading movies.');
    }
  }

  Future<List<MovieModel>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchMovies,
        queryParameters: {'query': query, 'page': page},
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>;

      return results.map((movieJson) {
        return MovieModel.fromJson(movieJson as Map<String, dynamic>);
      }).toList();
    } on DioException catch (error) {
      throw AppException(
        error.message ?? 'A network error occurred while searching.',
      );
    } catch (_) {
      throw AppException('An unexpected error occurred while searching.');
    }
  }

  Future<MovieDetailModel> getMovieDetail(int movieId) async {
    try {
      final detailResponse = await _dio.get(ApiConstants.movieDetail(movieId));

      final recommendationResponse = await _dio.get(
        ApiConstants.movieRecommendations(movieId),
      );

      final detailData = detailResponse.data as Map<String, dynamic>;
      final recommendationData =
          recommendationResponse.data as Map<String, dynamic>;

      final recommendationResults =
          recommendationData['results'] as List<dynamic>;

      return MovieDetailModel.fromJson(
        detailJson: detailData,
        recommendationJsonList: recommendationResults,
      );
    } on DioException catch (error) {
      throw AppException(
        error.message ??
            'A network error occurred while loading movie details.',
      );
    } catch (_) {
      throw AppException(
        'An unexpected error occurred while loading movie details.',
      );
    }
  }
}
