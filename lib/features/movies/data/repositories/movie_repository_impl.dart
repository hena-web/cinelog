import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_datasource.dart';

class MovieRepositoryImpl implements MovieRepository {
  MovieRepositoryImpl(this._remoteDatasource);

  final MovieRemoteDatasource _remoteDatasource;

  @override
  Future<List<Movie>> getPopularMovies({int page = 1}) async {
    final movieModels = await _remoteDatasource.getPopularMovies(page: page);

    return movieModels.map((movieModel) => movieModel.toEntity()).toList();
  }

  @override
  Future<List<Movie>> searchMovies({
    required String query,
    int page = 1,
  }) async {
    final movieModels = await _remoteDatasource.searchMovies(
      query: query,
      page: page,
    );

    return movieModels.map((movieModel) => movieModel.toEntity()).toList();
  }

  @override
  Future<MovieDetail> getMovieDetail(int movieId) async {
    final movieDetailModel = await _remoteDatasource.getMovieDetail(movieId);

    return movieDetailModel.toEntity();
  }
}