import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/widgets/empty_state.dart';

class ScannerTemplatesScreen extends ConsumerWidget {
  const ScannerTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/scanner-templates/new'),
          ),
        ],
      ),
      body: FutureBuilder(
        future:
            ref.read(scannerTemplateRepositoryProvider).watchAll().first,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final templates = snapshot.data!;
          if (templates.isEmpty) {
            return EmptyState(
              icon: Icons.document_scanner,
              title: 'No Templates',
              subtitle:
                  'Create templates to auto-parse transaction emails.',
              actionLabel: 'Add Template',
              onAction: () =>
                  context.push('/scanner-templates/new'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final t = templates[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  leading: const Icon(Icons.document_scanner),
                  title: Text(t.name),
                  subtitle: Text(
                    'Contains: "${t.contains ?? '*'}"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      final repo = ref
                          .read(scannerTemplateRepositoryProvider);
                      if (v == 'edit') {
                        if (context.mounted) {
                          context.push(
                              '/scanner-templates/${t.id}');
                        }
                      } else if (v == 'delete') {
                        await repo.delete(t.id);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit')),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete')),
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
