import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_movies_provider.dart';
import '../widgets/movie_card.dart';

const _searchBackgroundColor = Color(0xFF061B45);
const _searchTextColor = Colors.white;
const _searchMutedTextColor = Color(0xFFC5D3EA);
const _searchFieldColor = Color(0xFF0A285D);
const _searchRedColor = Color(0xFFFF1616);

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
      _search(value);
    }); // debounde timer
      }

  void _search(String value) {
    ref.read(searchMoviesProvider.notifier).searchMovies(value);
    setState(() {});
  }

  void _selectRecentSearch(String query) {
    _debounce?.cancel();
    _searchController
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);
    _search(query);
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

    return ColoredBox(
      color: _searchBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: _searchTextColor),
                  cursorColor: _searchRedColor,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: _searchFieldColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    labelText: 'Search by movie title',
                    hintText: 'Ex: Inception',
                    labelStyle: const TextStyle(color: _searchMutedTextColor),
                    hintStyle: TextStyle(
                      color: _searchMutedTextColor.withValues(alpha: 0.72),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: _searchMutedTextColor,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: _searchRedColor,
                      size: 22,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 42,
                      minHeight: 42,
                    ),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(
                              Icons.clear,
                              color: _searchRedColor,
                              size: 20,
                            ),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _searchRedColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: _searchRedColor,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: _searchRedColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                _RecentSearchesList(
                  recentSearches: searchState.recentSearches,
                  onRecentSearchSelected: _selectRecentSearch,
                ),
              ],
            ),
          ),
          Expanded(child: _SearchResultBody(searchState: searchState)),
        ],
      ),
    );
  }
}

class _SearchResultBody extends StatelessWidget {
  const _SearchResultBody({required this.searchState});

  final SearchMoviesState searchState;

  @override
  Widget build(BuildContext context) {
    if (searchState.query.isEmpty && !searchState.hasSearched) {
      return const SizedBox.shrink();
    }

    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            searchState.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _searchMutedTextColor),
          ),
        ),
      );
    }

    if (searchState.hasSearched && searchState.movies.isEmpty) {
      return const Center(
        child: Text(
          'No results found.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _searchMutedTextColor),
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

class _RecentSearchesList extends StatelessWidget {
  const _RecentSearchesList({
    required this.recentSearches,
    required this.onRecentSearchSelected,
  });

  final List<String> recentSearches;
  final ValueChanged<String> onRecentSearchSelected;

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recent searches',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: _searchTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recentSearches.map((query) {
                return InkWell(
                  onTap: () {
                    onRecentSearchSelected(query);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      query,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _searchMutedTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
