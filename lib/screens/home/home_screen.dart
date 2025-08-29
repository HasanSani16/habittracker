import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../habits/habits_screen.dart';
import '../quotes/quotes_screen.dart';
import '../profile/profile_screen.dart';
import '../insights/analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final screens = const [HabitsScreen(), QuotesScreen(), AnalyticsScreen(), ProfileScreen()];
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white70)),
                      Text(auth.firebaseUser?.displayName ?? 'Habit Tracker',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
                if (_index == 1)
                  IconButton(
                    tooltip: 'Favorites',
                    onPressed: () => Navigator.of(context).pushNamed('/favorites'),
                    icon: const Icon(Icons.favorite, color: Colors.white),
                  ),
                IconButton(
                  tooltip: 'Sign out',
                  onPressed: () => auth.logout(),
                  icon: const Icon(Icons.logout, color: Colors.white),
                )
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: screens[_index],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.check_circle_outline), label: 'Habits'),
              NavigationDestination(icon: Icon(Icons.format_quote), label: 'Quotes'),
              NavigationDestination(icon: Icon(Icons.insights), label: 'Analytics'),
              NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}


