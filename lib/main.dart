import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/env/env.dart';

void main() {
  runApp(
    const ProviderScope(
      child: CineLogApp(),
    ),
  );
}

class CineLogApp extends StatelessWidget {
  const CineLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: Env.hasApiKey
    ? const MainNavigationScreen()
    : const MissingApiKeyScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    PopularMoviesScreen(),
    SearchMoviesScreen(),
    FavoriteMoviesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String get _appBarTitle {
    if (_selectedIndex == 0) return 'Popüler Filmler';
    if (_selectedIndex == 1) return 'Film Ara';
    return 'Favoriler';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Popüler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Arama',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
        ],
      ),
    );
  }
}

class PopularMoviesScreen extends StatelessWidget {
  const PopularMoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Popüler filmler burada listelenecek.',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class SearchMoviesScreen extends StatelessWidget {
  const SearchMoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Film arama ekranı burada olacak.',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class FavoriteMoviesScreen extends StatelessWidget {
  const FavoriteMoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Favori filmler burada gösterilecek.',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
class MissingApiKeyScreen extends StatelessWidget {
  const MissingApiKeyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'TMDB API key bulunamadı.\n\n'
            'Uygulamayı şu şekilde çalıştır:\n\n'
            'flutter run -d chrome --dart-define=TMDB_API_KEY=YOUR_API_KEY',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}