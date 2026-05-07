class Env {
  Env._();

  static const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');

  static bool get hasApiKey => tmdbApiKey.isNotEmpty;
}
