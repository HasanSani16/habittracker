import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/quotes_provider.dart';
import '../../models/quote.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class QuotesScreen extends StatelessWidget {
  const QuotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<app_auth.AuthProvider>().firebaseUser?.uid;
    if (uid == null) return const Center(child: CircularProgressIndicator());
    return ChangeNotifierProvider(
      create: (_) => QuotesProvider(uid),
      child: const _QuotesBody(),
    );
  }
}

class _QuotesBody extends StatefulWidget {
  const _QuotesBody();

  @override
  State<_QuotesBody> createState() => _QuotesBodyState();
}

class _QuotesBodyState extends State<_QuotesBody> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuotesProvider>();
    final quotes = provider.quotes;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            if (quotes.isNotEmpty)
              CarouselSlider(
                carouselController: _controller,
                options: CarouselOptions(
                  height: 240,
                  enlargeCenterPage: true,
                  viewportFraction: 0.9,
                  autoPlay: true,
                  onPageChanged: (i, _) => setState(() => _index = i),
                ),
                items: quotes.map((q) => _QuoteCard(quote: q)).toList(),
              )
            else
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 8),
            if (quotes.isNotEmpty)
              Center(
                child: AnimatedSmoothIndicator(
                  activeIndex: _index,
                  count: quotes.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    dotColor: Colors.grey,
                    activeDotColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: provider.refresh,
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final Quote quote;
  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<QuotesProvider>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.format_quote, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"${quote.content}"',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('- ${quote.author}', style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                IconButton(
                  onPressed: () => provider.favorite(quote),
                  icon: const Icon(Icons.favorite_border),
                ),
                IconButton(
                  onPressed: () => _copy(context, quote.content),
                  icon: const Icon(Icons.copy),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }
}


