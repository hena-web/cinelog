import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie.dart';
import 'popular_movies_provider.dart';

class SearchMoviesState {
  const SearchMoviesState({
    this.query = '',
    this.movies = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasSearched = false,
  });

  final String query;
  final List<Movie> movies;
  final bool isLoading;
  final String? errorMessage;
  final bool hasSearched;

  SearchMoviesState copyWith({
    String? query,
    List<Movie>? movies,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? hasSearched,
  }) {
    return SearchMoviesState(
      query: query ?? this.query,
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}

final searchMoviesProvider =
    NotifierProvider<SearchMoviesNotifier, SearchMoviesState>(
  SearchMoviesNotifier.new,
);

class SearchMoviesNotifier extends Notifier<SearchMoviesState> {
  @override
  SearchMoviesState build() {
    return const SearchMoviesState();
  }

  Future<void> searchMovies(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      state = const SearchMoviesState();
      return;
    }

    state = state.copyWith(
      query: trimmedQuery,
      isLoading: true,
      movies: [],
      clearError: true,
      hasSearched: true,
    );

    try {
      final repository = ref.read(movieRepositoryProvider);
      final movies = await repository.searchMovies(query: trimmedQuery);

      state = state.copyWith(
        movies: movies,
        isLoading: false,
        clearError: true,
        hasSearched: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
        hasSearched: true,
      );
    }
  }

  void clearSearch() {
    state = const SearchMoviesState();
  }
}