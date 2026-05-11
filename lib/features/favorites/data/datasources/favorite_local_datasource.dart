import 'package:hive/hive.dart';

import '../../../../core/constants/storage_constants.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../../movies/domain/entities/movie.dart';

class FavoriteLocalDatasource {
  Box<dynamic> get _box {
    return Hive.box<dynamic>(StorageConstants.favoriteMoviesBox);
  }

  List<Movie> getFavoriteMovies() {
    return _box.values.map((value) {
      final json = Map<String, dynamic>.from(value as Map);

      return MovieModel.fromJson(json).toEntity();
    }).toList();
  }

  Future<void> addFavorite(Movie movie) async {
    final movieModel = MovieModel.fromEntity(movie);

    await _box.put(
      movie.id.toString(),
      movieModel.toJson(),
    );
  }

  Future<void> removeFavorite(int movieId) async {
    await _box.delete(movieId.toString());
  }

  bool isFavorite(int movieId) {
    return _box.containsKey(movieId.toString());
  }
}