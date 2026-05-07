class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  static const String popularMovies = '/movie/popular';
  static const String searchMovies = '/search/movie';

  static String movieDetail(int movieId) => '/movie/$movieId';

  static String movieRecommendations(int movieId) {
    return '/movie/$movieId/recommendations';
  }
}