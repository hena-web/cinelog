import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../movies/domain/entities/movie.dart';
import '../../data/datasources/favorite_local_datasource.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../domain/repositories/favorite_repository.dart';

final favoriteLocalDatasourceProvider = Provider<FavoriteLocalDatasource>((ref) {
  return FavoriteLocalDatasource();
});

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  final localDatasource = ref.watch(favoriteLocalDatasourceProvider);

  return FavoriteRepositoryImpl(localDatasource);
});

final favoriteMoviesProvider =
    NotifierProvider<FavoriteMoviesNotifier, List<Movie>>(
  FavoriteMoviesNotifier.new,
);

class FavoriteMoviesNotifier extends Notifier<List<Movie>> {
  late final FavoriteRepository _repository;

  @override
  List<Movie> build() {
    _repository = ref.watch(favoriteRepositoryProvider);

    return _repository.getFavoriteMovies();
  }

  bool isFavorite(int movieId) {
    return _repository.isFavorite(movieId);
  }

  Future<void> toggleFavorite(Movie movie) async {
    if (isFavorite(movie.id)) {
      await _repository.removeFavorite(movie.id);
    } else {
      await _repository.addFavorite(movie);
    }

    state = _repository.getFavoriteMovies();
  }

  Future<void> removeFavorite(int movieId) async {
    await _repository.removeFavorite(movieId);

    state = _repository.getFavoriteMovies();
  }
}