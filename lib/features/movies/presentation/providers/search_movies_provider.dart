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
    List<String>? recentSearches,
  }) : _recentSearches = recentSearches;

  final String query;
  final List<Movie> movies;
  final bool isLoading;
  final String? errorMessage;
  final bool hasSearched;
  final List<String>? _recentSearches;

  List<String> get recentSearches => _recentSearches ?? const [];

  SearchMoviesState copyWith({
    String? query,
    List<Movie>? movies,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? hasSearched,
    List<String>? recentSearches,
  }) {
    return SearchMoviesState(
      query: query ?? this.query,
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      hasSearched: hasSearched ?? this.hasSearched,
      recentSearches: recentSearches ?? this.recentSearches,
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
      clearSearch();
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
        recentSearches: _updatedRecentSearches(trimmedQuery),
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
    state = state.copyWith(
      query: '',
      movies: [],
      isLoading: false,
      clearError: true,
      hasSearched: false,
    );
  }

  List<String> _updatedRecentSearches(String query) {
    final normalizedQuery = query.toLowerCase();
    final searches = [
      query,
      ...state.recentSearches.where(
        (search) => search.toLowerCase() != normalizedQuery,
      ),
    ];

    return searches.take(5).toList();
  }
}
