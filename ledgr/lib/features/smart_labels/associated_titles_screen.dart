import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
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
      body: FutureBuilder<
          ({List<AssociatedTitle> titles, List<Category> categories})>(
        future: _load(ref),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final titles = snapshot.data!.titles;
          final categories = snapshot.data!.categories;

          if (titles.isEmpty) {
            return EmptyState(
              icon: Icons.auto_awesome,
              title: 'No Smart Labels',
              subtitle: 'Auto-categorize transactions by keywords.',
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
                final title = titles[index];
                final category = categories
                    .where((c) => c.id == title.categoryId)
                    .firstOrNull;
                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    leading: Icon(
                      title.exactMatch ? Icons.text_fields : Icons.search,
                      color: category == null
                          ? null
                          : AppColors.fromStored(
                              category.color,
                              Theme.of(context).colorScheme.primary,
                            ),
                    ),
                    title: Text('"${title.title}"'),
                    subtitle: Text(
                      '${title.exactMatch ? 'Exact match' : 'Contains'} → ${category?.name ?? 'Deleted'}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        final repo = ref.read(
                          associatedTitleRepositoryProvider,
                        );
                        if (value == 'edit') {
                          if (context.mounted) {
                            context.push('/smart-labels/${title.id}');
                          }
                        } else if (value == 'delete') {
                          await repo.delete(title.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
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

  Future<({List<AssociatedTitle> titles, List<Category> categories})> _load(
    WidgetRef ref,
  ) async {
    final results = await Future.wait([
      ref.read(associatedTitleRepositoryProvider).watchAll().first,
      ref.read(categoryRepositoryProvider).watchActive().first,
    ]);
    return (
      titles: results[0] as List<AssociatedTitle>,
      categories: results[1] as List<Category>,
    );
  }
}
