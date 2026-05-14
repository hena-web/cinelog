import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../favorites/presentation/providers/favorite_movies_provider.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../providers/movie_detail_provider.dart';
import '../widgets/movie_card.dart';

const _detailBackgroundColor = Color(0xFF061B45);
const _detailSurfaceColor = Color(0xFF0D2F68);
const _detailTextColor = Colors.white;
const _detailMutedTextColor = Color(0xFFC5D3EA);

class MovieDetailScreen extends ConsumerWidget {
  const MovieDetailScreen({required this.movieId, super.key});

  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movieDetailAsync = ref.watch(movieDetailProvider(movieId));

    return movieDetailAsync.when(
      loading: () {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      error: (error, stackTrace) {
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(error.toString(), textAlign: TextAlign.center),
            ),
          ),
        );
      },
      data: (movieDetail) {
        return Scaffold(
          backgroundColor: _detailBackgroundColor,
          body: _MovieDetailBody(movieDetail: movieDetail),
        );
      },
    );
  }
}

class _MovieDetailBody extends ConsumerWidget {
  const _MovieDetailBody({required this.movieDetail});

  final MovieDetail movieDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 270,
          pinned: true,
          stretch: true,
          backgroundColor: _detailBackgroundColor,
          foregroundColor: _detailTextColor,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            background: _BackdropImage(path: movieDetail.backdropPath),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -6),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderSection(movieDetail: movieDetail),
                  const SizedBox(height: 24),
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _detailTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movieDetail.overview.isEmpty
                        ? 'No overview available.'
                        : movieDetail.overview,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _detailMutedTextColor,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recommended Movies',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _detailTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RecommendationList(
                    recommendations: movieDetail.recommendations,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackdropImage extends StatelessWidget {
  const _BackdropImage({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return const ColoredBox(
        color: _detailSurfaceColor,
        child: Center(
          child: Icon(Icons.image_not_supported, color: _detailMutedTextColor),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: '${ApiConstants.imageBaseUrl}$path',
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return const Center(child: CircularProgressIndicator());
          },
          errorWidget: (context, url, error) {
            return const Center(child: Icon(Icons.broken_image));
          },
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                _detailBackgroundColor.withValues(alpha: 0.18),
                _detailBackgroundColor.withValues(alpha: 0.82),
                _detailBackgroundColor,
              ],
              stops: const [0.42, 0.62, 0.84, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.movieDetail});

  final MovieDetail movieDetail;

  @override
  Widget build(BuildContext context) {
    final movie = movieDetail.toMovie();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                movieDetail.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _detailTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Consumer(
              builder: (context, ref, child) {
                final isFavorite = ref
                    .watch(favoriteMoviesProvider)
                    .any((favoriteMovie) => favoriteMovie.id == movieDetail.id);

                return IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: _detailSurfaceColor,
                    foregroundColor: _detailTextColor,
                  ),
                  tooltip: isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  onPressed: () {
                    ref
                        .read(favoriteMoviesProvider.notifier)
                        .toggleFavorite(movie);
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 3),
        _MovieMetaLine(movieDetail: movieDetail),
        const SizedBox(height: 10),
        _RatingBadge(score: movieDetail.voteAverage),
      ],
    );
  }
}

class _MovieMetaLine extends StatelessWidget {
  const _MovieMetaLine({required this.movieDetail});

  final MovieDetail movieDetail;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: _detailMutedTextColor,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        Text(movieDetail.releaseYear, style: textStyle),
        const SizedBox(width: 8),
        Icon(Icons.circle, size: 4, color: _detailMutedTextColor),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            movieDetail.runtimeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.18),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.28)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 6),
          Text(
            score.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: _detailTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationList extends StatelessWidget {
  const _RecommendationList({required this.recommendations});

  final List<Movie> recommendations;

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const Text(
        'No recommended movies found.',
        style: TextStyle(color: _detailMutedTextColor),
      );
    }

    return SizedBox(
      height: 209,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final movie = recommendations[index];

          return SizedBox(width: 280, child: MovieCard(movie: movie));
        },
      ),
    );
  }
}
