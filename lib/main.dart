import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'quote_service.dart';

void main() {
  runApp(const DailyQuoteApp());
}

class DailyQuoteApp extends StatelessWidget {
  const DailyQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Quote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _currentQuote = '';
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyQuote();
  }

  Future<void> _loadDailyQuote() async {
    setState(() => _isLoading = true);
    final quote = await QuoteService.getDailyQuote();
    final isFav = await QuoteService.isFavorite(quote);
    setState(() {
      _currentQuote = quote;
      _isFavorite = isFav;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await QuoteService.removeFromFavorites(_currentQuote);
    } else {
      await QuoteService.addToFavorites(_currentQuote);
    }
    setState(() => _isFavorite = !_isFavorite);
  }

  Future<void> _shareQuote() async {
    await Share.share(_currentQuote);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quote'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.format_quote,
                    size: 60,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Quote of the Day',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        _currentQuote,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: 'favorite_fab',
                        onPressed: _toggleFavorite,
                        backgroundColor: _isFavorite ? Colors.red : Colors.grey,
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        heroTag: 'share_fab',
                        onPressed: _shareQuote,
                        backgroundColor: Colors.blue,
                        child: const Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'New quote tomorrow!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await QuoteService.getFavorites();
    setState(() => _favorites = favorites);
  }

  Future<void> _removeFavorite(String quote) async {
    await QuoteService.removeFromFavorites(quote);
    _loadFavorites();
  }

  Future<void> _shareQuote(String quote) async {
    await Share.share(quote);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Quotes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No favorite quotes yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tap the heart icon to save quotes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final quote = _favorites[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () => _shareQuote(quote),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeFavorite(quote),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
