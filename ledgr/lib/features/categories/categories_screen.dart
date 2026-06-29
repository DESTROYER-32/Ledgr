import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/category_icon_utils.dart';
import '../../core/widgets/empty_state.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentsAsync = ref.watch(parentCategoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/categories/new'),
          ),
        ],
      ),
      body: parentsAsync.when(
        data: (parents) {
          if (parents.isEmpty) {
            return EmptyState(
              icon: Icons.category,
              title: 'No Categories',
              subtitle: 'Create categories to organize your transactions.',
              actionLabel: 'Add Category',
              onAction: () => context.push('/categories/new'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: parents.map((cat) {
              return FutureBuilder<List<Category>>(
                future: ref
                    .read(categoryRepositoryProvider)
                    .watchSubcategories(cat.id)
                    .first,
                builder: (context, snapshot) {
                  final subs = snapshot.data ?? [];
                  return Column(
                    children: [
                      _buildTile(context, ref, cat, theme),
                      ...subs.map(
                        (sub) => Padding(
                          padding: const EdgeInsets.only(left: 32),
                          child: _buildTile(
                            context,
                            ref,
                            sub,
                            theme,
                            isSub: true,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }).toList(),
          );
        },
        error: (e, _) => Center(child: Text('$e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    WidgetRef ref,
    Category category,
    ThemeData theme, {
    bool isSub = false,
  }) {
    final color = AppColors.fromStored(
      category.color,
      theme.colorScheme.primary,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(
            materialCategoryIcon(category.icon),
            color: color,
            size: 20,
          ),
        ),
        title: Text(category.name),
        subtitle: Text('${category.kind}${isSub ? ' \u2022 Subcategory' : ''}'),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            final repo = ref.read(categoryRepositoryProvider);
            if (v == 'archive') {
              await repo.archive(category.id);
            } else if (v == 'edit') {
              if (context.mounted) {
                context.push('/categories/edit/${category.id}');
              }
            } else if (v == 'add_sub') {
              if (context.mounted) {
                // Pass parent as extra
                context.push(
                  '/categories/new',
                  extra: {'parentId': category.id},
                );
              }
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(
              value: 'add_sub',
              child: Text('Add Subcategory'),
            ),
            const PopupMenuItem(value: 'archive', child: Text('Archive')),
          ],
        ),
        onTap: () => context.push('/categories/${category.id}/transactions'),
      ),
    );
  }
}
