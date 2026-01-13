import 'package:shared_preferences/shared_preferences.dart';

class QuoteService {
  static final List<String> _quotes = [
    "The only way to do great work is to love what you do. - Steve Jobs",
    "Believe you can and you're halfway there. - Theodore Roosevelt",
    "The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt",
    "You miss 100% of the shots you don't take. - Wayne Gretzky",
    "The best way to predict the future is to create it. - Peter Drucker",
    "Don't watch the clock; do what it does. Keep going. - Sam Levenson",
    "The only limit to our realization of tomorrow will be our doubts of today. - Franklin D. Roosevelt",
    "Keep your face always toward the sunshine—and shadows will fall behind you. - Walt Whitman",
    "The way to get started is to quit talking and begin doing. - Walt Disney",
    "Your time is limited, so don't waste it living someone else's life. - Steve Jobs",
    "The secret of getting ahead is getting started. - Mark Twain",
    "Your limitation—it's only your imagination. - Unknown",
    "Push yourself, because no one else is going to do it for you. - Unknown",
    "Great things never come from comfort zones. - Unknown",
    "Dream it. Wish it. Do it. - Unknown",
    "Success doesn't just find you. You have to go out and get it. - Unknown",
    "The harder you work for something, the greater you'll feel when you achieve it. - Unknown",
    "Dream bigger. Do bigger. - Unknown",
    "Don't stop when you're tired. Stop when you're done. - Unknown",
    "Wake up with determination. Go to bed with satisfaction. - Unknown",
    "Do something today that your future self will thank you for. - Unknown",
    "Little things make big days. - Unknown",
    "It's going to be hard, but hard does not mean impossible. - Unknown",
    "Don't wait for opportunity. Create it. - Unknown",
    "Sometimes we're tested not to show our weaknesses, but to discover our strengths. - Unknown",
    "The key to success is to focus on goals, not obstacles. - Unknown",
    "Believe in yourself and all that you are. Know that there is something inside you that is greater than any obstacle. - Christian D. Larson",
    "The way to develop self-confidence is to do the thing you fear and get a record of successful experiences behind you. - William Jennings Bryan",
    "Don't let yesterday take up too much of today. - Will Rogers",
    "You learn more from failure than from success. Don't let it stop you. Failure builds character. - Unknown",
    "It's not whether you get knocked down, it's whether you get up. - Vince Lombardi",
  ];

  static Future<String> getDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    final lastDate = prefs.getString('last_quote_date');

    if (lastDate == todayString) {
      // Return the same quote for today
      final savedQuote = prefs.getString('daily_quote');
      if (savedQuote != null) {
        return savedQuote;
      }
    }

    // Generate new quote for today
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final quoteIndex = dayOfYear % _quotes.length;
    final newQuote = _quotes[quoteIndex];

    // Save for today
    await prefs.setString('last_quote_date', todayString);
    await prefs.setString('daily_quote', newQuote);

    return newQuote;
  }

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favorites') ?? [];
  }

  static Future<void> addToFavorites(String quote) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(quote)) {
      favorites.add(quote);
      await prefs.setStringList('favorites', favorites);
    }
  }

  static Future<void> removeFromFavorites(String quote) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.remove(quote);
    await prefs.setStringList('favorites', favorites);
  }

  static Future<bool> isFavorite(String quote) async {
    final favorites = await getFavorites();
    return favorites.contains(quote);
  }
}
