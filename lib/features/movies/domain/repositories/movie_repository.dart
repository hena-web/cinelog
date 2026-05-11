import '../entities/movie.dart';
import '../entities/movie_detail.dart';

abstract class MovieRepository {
  Future<List<Movie>> getPopularMovies({int page = 1});

  Future<List<Movie>> searchMovies({
    required String query,
    int page = 1,
  });

  Future<MovieDetail> getMovieDetail(int movieId);
}