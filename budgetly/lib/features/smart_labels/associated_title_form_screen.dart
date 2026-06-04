import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';

class AssociatedTitleFormScreen extends ConsumerStatefulWidget {
  final int? titleId;
  const AssociatedTitleFormScreen({super.key, this.titleId});

  @override
  ConsumerState<AssociatedTitleFormScreen> createState() =>
      _AssociatedTitleFormScreenState();
}

class _AssociatedTitleFormScreenState
    extends ConsumerState<AssociatedTitleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keywordController = TextEditingController();
  int? _categoryId;
  bool _exactMatch = false;

  @override
  void initState() {
    super.initState();
    if (widget.titleId != null) _load();
  }

  Future<void> _load() async {
    final repo = ref.read(associatedTitleRepositoryProvider);
    final t = await repo.getById(widget.titleId!);
    if (t != null && mounted) {
      _keywordController.text = t.title;
      _categoryId = t.categoryId;
      _exactMatch = t.exactMatch;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(activeCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.titleId != null
              ? 'Edit Smart Label'
              : 'New Smart Label')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: 'Keyword',
                hintText: 'e.g. "Uber"',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            categoriesAsync.when(
              data: (categories) => DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Row(
                          children: [
                            Icon(Icons.folder,
                                size: 18,
                                color: c.color != null
                                    ? Color(c.color!)
                                    : null),
                            const SizedBox(width: 8),
                            Text(c.name),
                          ],
                        )))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _categoryId = v),
                validator: (v) =>
                    v == null ? 'Select a category' : null,
              ),
              error: (e, _) => Text('$e'),
              loading: () =>
                  const CircularProgressIndicator(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Exact Match'),
              subtitle: const Text(
                  'Only match if the transaction title equals this keyword exactly'),
              value: _exactMatch,
              onChanged: (v) =>
                  setState(() => _exactMatch = v),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(widget.titleId != null
                  ? 'Update'
                  : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(associatedTitleRepositoryProvider);
    final entry = AssociatedTitlesCompanion.insert(
      title: _keywordController.text,
      categoryId: _categoryId!,
      exactMatch: Value(_exactMatch),
    );
    if (widget.titleId != null) {
      await repo.update(widget.titleId!, entry);
    } else {
      await repo.insert(entry);
    }
    if (mounted) context.pop();
  }
}
