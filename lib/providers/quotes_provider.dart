import 'package:flutter/foundation.dart';
import '../models/quote.dart';
import '../services/quotes_service.dart';

class QuotesProvider extends ChangeNotifier {
  final String uid;
  final QuotesService _service = QuotesService.instance;

  List<Quote> _quotes = [];
  bool _loading = false;

  QuotesProvider(this.uid) {
    refresh();
  }

  List<Quote> get quotes => _quotes;
  bool get isLoading => _loading;

  Future<void> refresh() async {
    _setLoading(true);
    try {
      _quotes = await _service.fetchRandomQuotes(limit: 10);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> favorite(Quote quote) async {
    await _service.favoriteQuote(uid: uid, quote: quote);
  }

  Future<void> unfavorite(String quoteId) async {
    await _service.unfavoriteQuote(uid: uid, quoteId: quoteId);
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}


