import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/quote.dart';

class QuotesService {
  QuotesService._();
  static final QuotesService instance = QuotesService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch random quotes with multiple fallbacks for web CORS robustness
  Future<List<Quote>> fetchRandomQuotes({int limit = 10}) async {
    try {
      // Primary: Quotable random endpoint (returns List)
      final randomUri = Uri.parse('https://api.quotable.io/quotes/random?limit=$limit');
      final res1 = await http.get(randomUri);
      if (res1.statusCode == 200) {
        final decoded = json.decode(res1.body);
        if (decoded is List) {
          final list = decoded.map((e) => Quote.fromJson(e as Map<String, dynamic>)).toList();
          if (list.isNotEmpty) return list;
        }
      }

      // Secondary: Quotable paged endpoint (returns Map with results)
      final listUri = Uri.parse('https://api.quotable.io/quotes?limit=$limit&sortBy=dateAdded&order=desc');
      final res2 = await http.get(listUri);
      if (res2.statusCode == 200) {
        final decoded = json.decode(res2.body);
        if (decoded is Map<String, dynamic> && decoded['results'] is List) {
          final results = (decoded['results'] as List).cast<dynamic>();
          final list = results.map((e) => Quote.fromJson(e as Map<String, dynamic>)).toList();
          if (list.isNotEmpty) return list;
        }
      }

      // Tertiary: ZenQuotes (returns List of maps with keys q,a)
      final zenUri = Uri.parse('https://zenquotes.io/api/quotes');
      final res3 = await http.get(zenUri);
      if (res3.statusCode == 200) {
        final decoded = json.decode(res3.body);
        if (decoded is List) {
          final list = decoded.map((e) => Quote.fromJson((e as Map).cast<String, dynamic>())).toList();
          if (list.isNotEmpty) return list.take(limit).toList();
        }
      }
    } catch (_) {}
    // fallback
    return const [
      Quote(id: 'fallback1', content: 'Keep going. Everything you need will come to you at the perfect time.', author: 'Unknown'),
      Quote(id: 'fallback2', content: 'Success is the sum of small efforts repeated day in and day out.', author: 'Robert Collier'),
      Quote(id: 'fallback3', content: 'The secret of your future is hidden in your daily routine.', author: 'Mike Murdock'),
    ];
  }

  Future<void> favoriteQuote({required String uid, required Quote quote}) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc('quotes')
        .collection('items')
        .doc(quote.id)
        .set(quote.toMap());
  }

  Future<void> unfavoriteQuote({required String uid, required String quoteId}) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc('quotes')
        .collection('items')
        .doc(quoteId)
        .delete();
  }

  Stream<List<Quote>> watchFavoriteQuotes(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc('quotes')
        .collection('items')
        .snapshots()
        .map((s) => s.docs.map((d) => Quote.fromJson(d.data())).toList());
  }
}


