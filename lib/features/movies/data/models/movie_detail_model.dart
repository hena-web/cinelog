import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import 'movie_model.dart';

class MovieDetailModel {
  const MovieDetailModel({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.runtime,
    required this.genres,
    required this.recommendations,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int runtime;
  final List<String> genres;
  final List<Movie> recommendations;

  factory MovieDetailModel.fromJson({
    required Map<String, dynamic> detailJson,
    required List<dynamic> recommendationJsonList,
  }) {
    final genresJson = detailJson['genres'] as List<dynamic>? ?? [];

    final recommendations = recommendationJsonList.map((movieJson) {
      return MovieModel.fromJson(movieJson as Map<String, dynamic>).toEntity();
    }).toList();

    return MovieDetailModel(
      id: detailJson['id'] as int,
      title: detailJson['title'] as String? ?? 'Başlıksız',
      overview: detailJson['overview'] as String? ?? '',
      posterPath: detailJson['poster_path'] as String?,
      backdropPath: detailJson['backdrop_path'] as String?,
      releaseDate: detailJson['release_date'] as String? ?? '',
      voteAverage: (detailJson['vote_average'] as num?)?.toDouble() ?? 0.0,
      runtime: detailJson['runtime'] as int? ?? 0,
      genres: genresJson.map((genreJson) {
        final genreMap = genreJson as Map<String, dynamic>;

        return genreMap['name'] as String? ?? '';
      }).where((genreName) {
        return genreName.isNotEmpty;
      }).toList(),
      recommendations: recommendations,
    );
  }

  MovieDetail toEntity() {
    return MovieDetail(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      runtime: runtime,
      genres: genres,
      recommendations: recommendations,
    );
  }
}