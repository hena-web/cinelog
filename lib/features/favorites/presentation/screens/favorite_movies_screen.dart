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
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: favoriteMovies.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          return _FavoriteMovieTile(movie: favoriteMovies[index]);
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
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
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
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return const Icon(
                            Icons.broken_image,
                            color: _favoritesMutedTextColor,
                          );
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _favoritesTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
