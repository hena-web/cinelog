import '../../../movies/domain/entities/movie.dart';

abstract class FavoriteRepository {
  List<Movie> getFavoriteMovies();

  Future<void> addFavorite(Movie movie);

  Future<void> removeFavorite(int movieId);

  bool isFavorite(int movieId);
}