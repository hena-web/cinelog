import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../../movies/presentation/screens/movie_detail_screen.dart';
import '../providers/favorite_movies_provider.dart';

const _favoritesTextColor = Colors.white;
const _favoritesMutedTextColor = Color(0xFFC5D3EA);

class FavoriteMoviesScreen extends ConsumerWidget {
  const FavoriteMoviesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteMovies = ref.watch(favoriteMoviesProvider);

    if (favoriteMovies.isEmpty) {
      return ColoredBox(
        color: Colors.blue.shade900,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'You have not added any favorite movies yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _favoritesMutedTextColor,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: Colors.blue.shade900,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: favoriteMovies.length,
        itemBuilder: (context, index) {
          final movie = favoriteMovies[index];

          return Dismissible(
            key: ValueKey(movie.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              await ref
                  .read(favoriteMoviesProvider.notifier)
                  .removeFavorite(movie.id);
              return false;
            },
            child: _FavoriteMovieTile(movie: movie),
          );
        },
      ),
    );
  }
}

class _FavoriteMovieTile extends StatelessWidget {
  const _FavoriteMovieTile({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF0D2F68),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              width: 82,
              height: 122,
              child: movie.posterPath == null
                  ? const ColoredBox(
                      color: Color(0xFF102B5E),
                      child: Icon(
                        Icons.image_not_supported,
                        color: _favoritesMutedTextColor,
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl:
                          '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorWidget: (context, url, error) {
                        return const Icon(
                          Icons.broken_image,
                          color: _favoritesMutedTextColor,
                        );
                      },
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _favoritesTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview.isEmpty
                          ? 'No overview available.'
                          : movie.overview,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _favoritesMutedTextColor,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.favorite, color: Colors.red, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
