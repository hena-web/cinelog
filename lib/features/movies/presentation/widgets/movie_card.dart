import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../favorites/presentation/providers/favorite_movies_provider.dart';
import '../../domain/entities/movie.dart';
import '../screens/movie_detail_screen.dart';

class MovieCard extends ConsumerWidget {
  const MovieCard({required this.movie, super.key});

  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posterPath = movie.posterPath;

    final isFavorite = ref
        .watch(favoriteMoviesProvider)
        .any((favoriteMovie) => favoriteMovie.id == movie.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return MovieDetailScreen(movieId: movie.id);
              },
            ),
          );
        },
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 150,
              child: posterPath == null
                  ? const ColoredBox(
                      color: Colors.black12,
                      child: Icon(Icons.image_not_supported),
                    )
                  : CachedNetworkImage(
                      imageUrl: '${ApiConstants.imageBaseUrl}$posterPath',
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorWidget: (context, url, error) {
                        return const Icon(Icons.broken_image);
                      },
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ref
                                .read(favoriteMoviesProvider.notifier)
                                .toggleFavorite(movie);
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Year: ${movie.releaseYear}'),
                    const SizedBox(height: 4),
                    Text('Rating: ${movie.voteAverage.toStringAsFixed(1)}'),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview.isEmpty
                          ? 'No description available.'
                          : movie.overview,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
