import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/popular_movies_provider.dart';
import '../widgets/movie_card.dart';

class PopularMoviesScreen extends ConsumerStatefulWidget {
  const PopularMoviesScreen({super.key});

  @override
  ConsumerState<PopularMoviesScreen> createState() =>
      _PopularMoviesScreenState();
}

class _PopularMoviesScreenState extends ConsumerState<PopularMoviesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 300) {
      ref.read(popularMoviesProvider.notifier).loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final popularMoviesState = ref.watch(popularMoviesProvider);

    if (popularMoviesState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (popularMoviesState.errorMessage != null &&
        popularMoviesState.movies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            popularMoviesState.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (popularMoviesState.movies.isEmpty) {
      return const Center(
        child: Text('Popüler film bulunamadı.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return ref.read(popularMoviesProvider.notifier).refreshMovies();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: popularMoviesState.movies.length +
            (popularMoviesState.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == popularMoviesState.movies.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final movie = popularMoviesState.movies[index];

          return MovieCard(movie: movie);
        },
      ),
    );
  }
}