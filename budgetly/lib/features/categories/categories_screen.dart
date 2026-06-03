import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/empty_state.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(activeCategoriesProvider);
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
      body: catsAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
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
            children: categories
                .map((c) => _buildTile(context, ref, c, theme))
                .toList(),
          );
        },
        error: (e, _) => Center(child: Text('$e')),
        loading: () =>
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildTile(BuildContext context, WidgetRef ref,
      Category category, ThemeData theme) {
    final color = category.color != null
        ? Color(category.color!)
        : theme.colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(_materialIcon(category.icon),
              color: color, size: 20),
        ),
        title: Text(category.name),
        subtitle: Text(category.kind),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            final repo = ref.read(categoryRepositoryProvider);
            if (v == 'archive') {
              await repo.archive(category.id);
            } else if (v == 'edit') {
              if (context.mounted) {
                context.push('/categories/edit/${category.id}');
              }
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
                value: 'edit', child: Text('Edit')),
            const PopupMenuItem(
                value: 'archive', child: Text('Archive')),
          ],
        ),
        onTap: () =>
            context.push('/categories/edit/${category.id}'),
      ),
    );
  }

  IconData _materialIcon(String? iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'code':
        return Icons.code;
      case 'trending_up':
        return Icons.trending_up;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'home':
        return Icons.home;
      case 'bolt':
        return Icons.bolt;
      case 'directions_car':
        return Icons.directions_car;
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'subscriptions':
        return Icons.subscriptions;
      case 'security':
        return Icons.security;
      case 'school':
        return Icons.school;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'attach_money':
        return Icons.attach_money;
      case 'money_off':
        return Icons.money_off;
      default:
        return Icons.category;
    }
  }
}
