import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_movies_provider.dart';
import '../widgets/movie_card.dart';

class SearchMoviesScreen extends ConsumerStatefulWidget {
  const SearchMoviesScreen({super.key});

  @override
  ConsumerState<SearchMoviesScreen> createState() => _SearchMoviesScreenState();
}

class _SearchMoviesScreenState extends ConsumerState<SearchMoviesScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchMoviesProvider.notifier).searchMovies(value);
      setState(() {});
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    ref.read(searchMoviesProvider.notifier).clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchMoviesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              labelText: 'Film adı ara',
              hintText: 'Örn: Inception',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: _SearchResultBody(searchState: searchState),
        ),
      ],
    );
  }
}

class _SearchResultBody extends StatelessWidget {
  const _SearchResultBody({
    required this.searchState,
  });

  final SearchMoviesState searchState;

  @override
  Widget build(BuildContext context) {
    if (searchState.query.isEmpty && !searchState.hasSearched) {
      return const Center(
        child: Text(
          'Film aramak için yukarıya bir film adı yaz.',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (searchState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (searchState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            searchState.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (searchState.hasSearched && searchState.movies.isEmpty) {
      return const Center(
        child: Text(
          'Sonuç bulunamadı.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: searchState.movies.length,
      itemBuilder: (context, index) {
        final movie = searchState.movies[index];

        return MovieCard(movie: movie);
      },
    );
  }
}