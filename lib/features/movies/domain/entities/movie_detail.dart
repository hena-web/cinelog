import 'movie.dart';

class MovieDetail {
  const MovieDetail({
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

  String get releaseYear {
    if (releaseDate.length >= 4) {
      return releaseDate.substring(0, 4);
    }

    return 'N/A';
  }

  String get runtimeText {
    if (runtime <= 0) {
      return 'Runtime unavailable';
    }

    final hours = runtime ~/ 60;
    final minutes = runtime % 60;

    if (hours == 0) {
      return '$minutes min';
    }

    return '${hours}h ${minutes}min';
  }

  Movie toMovie() {
    return Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
    );
  }
}
