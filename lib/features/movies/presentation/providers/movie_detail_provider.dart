import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/movie_detail.dart';
import 'popular_movies_provider.dart';

final movieDetailProvider =
    FutureProvider.family<MovieDetail, int>((ref, movieId) async {
  final repository = ref.watch(movieRepositoryProvider);

  return repository.getMovieDetail(movieId);
});