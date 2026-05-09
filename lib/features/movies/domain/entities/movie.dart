class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
  });

  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;

  String get releaseYear {
    if (releaseDate.length >= 4) {
      return releaseDate.substring(0, 4);
    }

    return 'N/A';
  }
}