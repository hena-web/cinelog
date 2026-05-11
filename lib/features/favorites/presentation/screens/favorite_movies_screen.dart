import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../movies/presentation/widgets/movie_card.dart';
import '../providers/favorite_movies_provider.dart';
class FavoriteMoviesScreen extends ConsumerWidget {
  const FavoriteMoviesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteMovies = ref.watch(favoriteMoviesProvider);

    if (favoriteMovies.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Henüz favori film eklemedin.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: favoriteMovies.length,
      itemBuilder: (context, index) {
        final movie = favoriteMovies[index];

        return Dismissible(
          key: ValueKey(movie.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (_) {
            ref
                .read(favoriteMoviesProvider.notifier)
                .removeFavorite(movie.id);
          },
          child: MovieCard(movie: movie),
        );
      },
    );
  }
}