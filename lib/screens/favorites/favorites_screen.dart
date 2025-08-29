import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Center(child: CircularProgressIndicator());
    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc('quotes')
        .collection('items')
        .snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Quotes')),
      body: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = (snapshot.data as QuerySnapshot).docs;
          if (docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_border, size: 48),
                        const SizedBox(height: 8),
                        Text('No favorites yet', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        const Text('Save quotes you love to find them here.'),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.format_quote),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('"${data['content']}"', style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 6),
                            Text('- ${data['author']}', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('favorites')
                              .doc('quotes')
                              .collection('items')
                              .doc(docs[i].id)
                              .delete();
                        },
                        icon: const Icon(Icons.favorite),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


