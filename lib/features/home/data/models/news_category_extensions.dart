import 'news_model/news_model.dart';

extension NewsCategoryExtension on NewsModel {
  String get inferredCategory {
    final text = '${title ?? ''} ${description ?? ''} ${content ?? ''}'.toLowerCase();

    if (_containsAny(text, [
      'technology', 'tech', 'ai', 'artificial intelligence', 'software',
      'hardware', 'gadget', 'app', 'startup', 'robot', 'machine learning',
      'cloud', 'programming', 'coding', 'apple', 'google', 'microsoft'
    ])) {
      return 'Technology';
    } else if (_containsAny(text, [
      'football', 'soccer', 'fifa', 'nba', 'basketball', 'tennis',
      'cricket', 'golf', 'olympics', 'world cup', 'uefa', 'champions league',
      'nfl', 'mlb', 'la liga', 'premier league', 'messi', 'ronaldo'
    ])) {
      return 'Sports';
    } else if (_containsAny(text, [
      'finance', 'stock', 'market', 'forex', 'trading', 'bitcoin',
      'crypto', 'cryptocurrency', 'nasdaq', 'wall street', 'invest',
      'investment', 'economy', 'economic', 'business', 'startup',
      'inflation', 'interest rate'
    ])) {
      return 'Business';
    } else if (_containsAny(text, [
      'covid', 'vaccine', 'mental health', 'doctor', 'hospital',
      'medicine', 'medical', 'fitness', 'healthcare', 'diet', 'virus',
      'pandemic', 'wellness', 'clinic', 'cardio', 'diabetes', 'surgery'
    ])) {
      return 'Health';
    } else if (_containsAny(text, [
      'movie', 'film', 'tv', 'television', 'actor', 'actress', 'celebrity',
      'netflix', 'hbo', 'disney', 'drama', 'series', 'music', 'album',
      'hollywood', 'award', 'concert', 'box office', 'trailer'
    ])) {
      return 'Entertainment';
    } else if (_containsAny(text, [
      'election', 'government', 'senate', 'congress', 'president',
      'democracy', 'law', 'bill', 'policy', 'minister', 'parliament',
      'politics', 'republican', 'democrat', 'biden', 'trump', 'diplomacy',
      'protest', 'conflict'
    ])) {
      return 'Politics';
    }

    return 'General';
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((word) => text.contains(word));
  }
}
