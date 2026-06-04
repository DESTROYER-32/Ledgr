import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/widgets/empty_state.dart';

class AssociatedTitlesScreen extends ConsumerWidget {
  const AssociatedTitlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Labels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/smart-labels/new'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([
          ref.read(associatedTitleRepositoryProvider).watchAll().first,
          ref.read(categoryRepositoryProvider).watchActive().first,
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final titles = snapshot.data![0] as List;
          final categories = snapshot.data![1] as List;

          if (titles.isEmpty) {
            return EmptyState(
              icon: Icons.auto_awesome,
              title: 'No Smart Labels',
              subtitle:
                  'Auto-categorize transactions by keywords.',
              actionLabel: 'Add Label',
              onAction: () => context.push('/smart-labels/new'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: titles.length,
              itemBuilder: (context, index) {
                final t = titles[index] as dynamic;
                final cat = categories.where(
                    (c) => (c as dynamic).id == t.categoryId).firstOrNull;
                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    leading: Icon(
                      t.exactMatch
                          ? Icons.text_fields
                          : Icons.search,
                      color: cat != null && (cat as dynamic).color != null
                          ? Color((cat as dynamic).color!)
                          : null,
                    ),
                    title: Text('"${t.title}"'),
                    subtitle: Text(
                        '${t.exactMatch ? 'Exact match' : 'Contains'} \u2192 ${cat != null ? (cat as dynamic).name : 'Deleted'}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        final repo =
                            ref.read(associatedTitleRepositoryProvider);
                        if (v == 'edit') {
                          if (context.mounted) {
                            context.push('/smart-labels/${t.id}');
                          }
                        } else if (v == 'delete') {
                          await repo.delete(t.id);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                            value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
