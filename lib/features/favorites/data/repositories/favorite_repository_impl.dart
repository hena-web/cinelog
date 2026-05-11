import '../../../movies/domain/entities/movie.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_local_datasource.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  FavoriteRepositoryImpl(this._localDatasource);

  final FavoriteLocalDatasource _localDatasource;

  @override
  List<Movie> getFavoriteMovies() {
    return _localDatasource.getFavoriteMovies();
  }

  @override
  Future<void> addFavorite(Movie movie) {
    return _localDatasource.addFavorite(movie);
  }

  @override
  Future<void> removeFavorite(int movieId) {
    return _localDatasource.removeFavorite(movieId);
  }

  @override
  bool isFavorite(int movieId) {
    return _localDatasource.isFavorite(movieId);
  }
}