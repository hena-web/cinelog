import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../providers/popular_movies_provider.dart';
import 'movie_detail_screen.dart';

class PopularMoviesScreen extends ConsumerStatefulWidget {
  const PopularMoviesScreen({required this.isCompactView, super.key});

  final bool isCompactView;

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
      return const Center(child: CircularProgressIndicator());
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
      return const Center(child: Text('No popular movies found.'));
    }

    return Container(
      color: Colors.blue.shade900,
      child: RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.blue.shade900,
        onRefresh: () {
          return ref.read(popularMoviesProvider.notifier).refreshMovies();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final gridMetrics = _MovieGridMetrics.fromWidth(
                    constraints.crossAxisExtent,
                    isCompactView: widget.isCompactView,
                  );

                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == popularMoviesState.movies.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final movie = popularMoviesState.movies[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return MovieDetailScreen(movieId: movie.id);
                                },
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    widget.isCompactView ? 6 : 8,
                                  ),
                                  child: movie.posterPath == null
                                      ? const ColoredBox(
                                          color: Colors.black12,
                                          child: Icon(
                                            Icons.image_not_supported,
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl:
                                              '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          },
                                          errorWidget: (context, url, error) {
                                            return const Icon(
                                              Icons.broken_image,
                                            );
                                          },
                                        ),
                                ),
                              ),
                              SizedBox(height: widget.isCompactView ? 6 : 8),
                              Text(
                                movie.title,
                                maxLines: widget.isCompactView ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: widget.isCompactView
                                          ? 12
                                          : null,
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount:
                          popularMoviesState.movies.length +
                          (popularMoviesState.isLoadingMore ? 1 : 0),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridMetrics.crossAxisCount,
                      childAspectRatio: gridMetrics.childAspectRatio,
                      crossAxisSpacing: gridMetrics.spacing,
                      mainAxisSpacing: gridMetrics.spacing,
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _MovieGridMetrics {
  const _MovieGridMetrics({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.spacing,
  });

  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;

  factory _MovieGridMetrics.fromWidth(
    double width, {
    required bool isCompactView,
  }) {
    if (!isCompactView) {
      return _MovieGridMetrics(
        crossAxisCount: width >= 700 ? 3 : 2,
        childAspectRatio: 0.6,
        spacing: 12,
      );
    }

    if (width >= 900) {
      return const _MovieGridMetrics(
        crossAxisCount: 5,
        childAspectRatio: 0.57,
        spacing: 12,
      );
    }

    if (width >= 560) {
      return const _MovieGridMetrics(
        crossAxisCount: 4,
        childAspectRatio: 0.57,
        spacing: 10,
      );
    }

    return const _MovieGridMetrics(
      crossAxisCount: 3,
      childAspectRatio: 0.56,
      spacing: 10,
    );
  }
}
