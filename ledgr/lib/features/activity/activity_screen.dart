import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/money_utils.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(deleteLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Activity Log?'),
                  content: const Text(
                      'This will permanently remove all activity entries.'),
                  actions: [
                    TextButton(
                        onPressed: () =>
                            Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () =>
                            Navigator.pop(ctx, true),
                        child: const Text('Clear')),
                  ],
                ),
              );
              if (confirm == true) {
                await ref
                    .read(deleteLogRepositoryProvider)
                    .clearAll();
              }
            },
          ),
        ],
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              title: 'No Activity',
              subtitle:
                  'Deleted transactions will appear here so you can restore them.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final data = jsonDecode(log.jsonData) as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 4),
                child: ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: Colors.red),
                  title: Text(
                      '${data['title'] ?? 'Untitled'}'),
                  subtitle: Text(
                    '${data['type'] ?? ''} ${data['specialType'] != null && data['specialType'] != 'none' ? '(${data['specialType']})' : ''} \u2022 ${MoneyUtils.formatDateShort(log.deletedAt)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore,
                        color: Colors.green),
                    tooltip: 'Restore',
                    onPressed: () async {
                      await ref
                          .read(deleteLogRepositoryProvider)
                          .restoreTransaction(log.id);
                    },
                  ),
                ),
              );
            },
          );
        },
        error: (e, _) => Center(child: Text('$e')),
        loading: () =>
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
