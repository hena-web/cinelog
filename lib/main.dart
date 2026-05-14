import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/storage_constants.dart';
import 'core/env/env.dart';
import 'features/favorites/presentation/screens/favorite_movies_screen.dart';
import 'features/movies/presentation/screens/popular_movies_screen.dart';
import 'features/movies/presentation/screens/search_movies_screen.dart';
import 'widgets/app_logo.dart';
import 'features/splash/presentation/screens/animated_splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<dynamic>(StorageConstants.favoriteMoviesBox);

  runApp(const ProviderScope(child: CineLogApp()));
}

class CineLogApp extends StatelessWidget {
  const CineLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: Env.hasApiKey
          ? const AnimatedSplashScreen(nextScreen: MainNavigationScreen())
          : const MissingApiKeyScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AppLogo(size: 88),
            SizedBox(height: 20),
            Text(
              'CineLog',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
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
  bool _isPopularCompactView = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String get _appBarTitle {
    if (_selectedIndex == 1) return 'Search Movies';
    return 'Favorites';
  }

  Widget get _appBarTitleWidget {
    if (_selectedIndex == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.skewX(-0.08),
            child: const Text(
              'Popular ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const _MovieWordMark(),
        ],
      );
    }

    return Text(_appBarTitle);
  }

  List<Widget>? get _appBarActions {
    if (_selectedIndex != 0) return null;

    return [
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: IconButton(
          tooltip: _isPopularCompactView ? 'Comfort view' : 'Compact view',
          onPressed: () {
            setState(() {
              _isPopularCompactView = !_isPopularCompactView;
            });
          },
          icon: Icon(
            _isPopularCompactView ? Icons.view_comfy : Icons.grid_view,
            color: Colors.white,
          ),
        ),
      ),
    ];
  }

  Widget get _currentScreen {
    if (_selectedIndex == 0) {
      return PopularMoviesScreen(isCompactView: _isPopularCompactView);
    }

    if (_selectedIndex == 1) return const SearchMoviesScreen();

    return const FavoriteMoviesScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _appBarTitleWidget,
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        elevation: 0,
        actions: _appBarActions,
      ),
      body: _currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.shade900,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Popular'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

class _MovieWordMark extends StatelessWidget {
  const _MovieWordMark();

  static const _logoRed = Color(0xFFFF1616);

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(-0.12),
      child: const CustomPaint(
        size: Size(88, 30),
        painter: _MovieWordPainter(color: _logoRed),
      ),
    );
  }
}

class _MovieWordPainter extends CustomPainter {
  const _MovieWordPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 4.1;

    final mLeftLoop = Path()
      ..moveTo(size.width * 0.02, size.height * 0.92)
      ..cubicTo(
        size.width * 0.02,
        size.height * 0.18,
        size.width * 0.13,
        size.height * 0.02,
        size.width * 0.21,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.27,
        size.height * 0.72,
        size.width * 0.23,
        size.height * 0.92,
        size.width * 0.18,
        size.height * 0.78,
      );

    final mRightLoop = Path()
      ..moveTo(size.width * 0.38, size.height * 0.92)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.18,
        size.width * 0.27,
        size.height * 0.02,
        size.width * 0.21,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.15,
        size.height * 0.72,
        size.width * 0.20,
        size.height * 0.92,
        size.width * 0.25,
        size.height * 0.78,
      );

    final word = Path()
      ..moveTo(size.width * 0.40, size.height * 0.72)
      ..cubicTo(
        size.width * 0.44,
        size.height * 0.43,
        size.width * 0.55,
        size.height * 0.43,
        size.width * 0.55,
        size.height * 0.68,
      )
      ..cubicTo(
        size.width * 0.55,
        size.height * 0.94,
        size.width * 0.41,
        size.height * 0.94,
        size.width * 0.42,
        size.height * 0.70,
      )
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.52,
        size.width * 0.54,
        size.height * 0.58,
        size.width * 0.58,
        size.height * 0.72,
      )
      ..cubicTo(
        size.width * 0.61,
        size.height * 0.84,
        size.width * 0.62,
        size.height * 0.88,
        size.width * 0.64,
        size.height * 0.88,
      )
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.88,
        size.width * 0.69,
        size.height * 0.70,
        size.width * 0.71,
        size.height * 0.52,
      )
      ..cubicTo(
        size.width * 0.70,
        size.height * 0.80,
        size.width * 0.73,
        size.height * 0.92,
        size.width * 0.76,
        size.height * 0.76,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.66,
        size.width * 0.78,
        size.height * 0.55,
        size.width * 0.76,
        size.height * 0.48,
      )
      ..moveTo(size.width * 0.76, size.height * 0.33)
      ..lineTo(size.width * 0.76, size.height * 0.34)
      ..moveTo(size.width * 0.82, size.height * 0.72)
      ..cubicTo(
        size.width * 0.85,
        size.height * 0.45,
        size.width * 0.96,
        size.height * 0.46,
        size.width * 0.96,
        size.height * 0.66,
      )
      ..cubicTo(
        size.width * 0.96,
        size.height * 0.78,
        size.width * 0.89,
        size.height * 0.78,
        size.width * 0.84,
        size.height * 0.70,
      )
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.93,
        size.width * 0.97,
        size.height * 0.86,
        size.width * 1.00,
        size.height * 0.74,
      );

    canvas.drawPath(mLeftLoop, paint);
    canvas.drawPath(mRightLoop, paint);
    canvas.drawPath(word, paint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.26),
      1.9,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MovieWordPainter oldDelegate) {
    return oldDelegate.color != color;
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
            'TMDB API key is missing.\n\n'
            'Run the app like this:\n\n'
            'flutter run -d chrome --dart-define=TMDB_API_KEY=YOUR_API_KEY',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
