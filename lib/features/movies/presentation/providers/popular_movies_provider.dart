import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/movie_remote_datasource.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final movieRemoteDatasourceProvider = Provider<MovieRemoteDatasource>((ref) {
  final dioClient = ref.watch(dioClientProvider);

  return MovieRemoteDatasource(dioClient.dio);
});

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  final remoteDatasource = ref.watch(movieRemoteDatasourceProvider);

  return MovieRepositoryImpl(remoteDatasource);
});

class PopularMoviesState {
  const PopularMoviesState({
    this.movies = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.errorMessage,
    this.currentPage = 1,
  });

  final List<Movie> movies;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final String? errorMessage;
  final int currentPage;

  PopularMoviesState copyWith({
    List<Movie>? movies,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    String? errorMessage,
    int? currentPage,
    bool clearError = false,
  }) {
    return PopularMoviesState(
      movies: movies ?? this.movies,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

final popularMoviesProvider =
    NotifierProvider<PopularMoviesNotifier, PopularMoviesState>(
  PopularMoviesNotifier.new,
);

class PopularMoviesNotifier extends Notifier<PopularMoviesState> {
  late final MovieRepository _repository;

  @override
  PopularMoviesState build() {
    _repository = ref.watch(movieRepositoryProvider);

    Future.microtask(loadInitialMovies);

    return const PopularMoviesState();
  }

  Future<void> loadInitialMovies() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      movies: [],
      currentPage: 1,
      hasReachedEnd: false,
    );

    try {
      final movies = await _repository.getPopularMovies(page: 1);

      state = state.copyWith(
        movies: movies,
        isLoading: false,
        currentPage: 1,
        hasReachedEnd: movies.isEmpty,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedEnd) {
      return;
    }

    state = state.copyWith(
      isLoadingMore: true,
      clearError: true,
    );

    try {
      final nextPage = state.currentPage + 1;
      final newMovies = await _repository.getPopularMovies(page: nextPage);

      if (newMovies.isEmpty) {
        state = state.copyWith(
          isLoadingMore: false,
          hasReachedEnd: true,
        );
        return;
      }

      state = state.copyWith(
        movies: [...state.movies, ...newMovies],
        currentPage: nextPage,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshMovies() async {
    await loadInitialMovies();
  }
}