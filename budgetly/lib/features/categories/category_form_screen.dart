import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  final int? categoryId;
  const CategoryFormScreen({super.key, this.categoryId});

  @override
  ConsumerState<CategoryFormScreen> createState() =>
      _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _kind = 'expense';
  String _icon = 'category';
  int _color = AppColors.categoryColors[0].toARGB32();

  final _icons = [
    ('work', Icons.work),
    ('code', Icons.code),
    ('trending_up', Icons.trending_up),
    ('shopping_cart', Icons.shopping_cart),
    ('home', Icons.home),
    ('bolt', Icons.bolt),
    ('directions_car', Icons.directions_car),
    ('restaurant', Icons.restaurant),
    ('shopping_bag', Icons.shopping_bag),
    ('movie', Icons.movie),
    ('local_hospital', Icons.local_hospital),
    ('subscriptions', Icons.subscriptions),
    ('security', Icons.security),
    ('school', Icons.school),
    ('card_giftcard', Icons.card_giftcard),
    ('attach_money', Icons.attach_money),
    ('money_off', Icons.money_off),
    ('category', Icons.category),
  ];

  bool get _isEditing => widget.categoryId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _load();
  }

  Future<void> _load() async {
    final c = await ref
        .read(categoryRepositoryProvider)
        .getById(widget.categoryId!);
    if (c != null && mounted) {
      setState(() {
        _nameController.text = c.name;
        _kind = c.kind;
        _icon = c.icon ?? 'category';
        _color = c.color ?? AppColors.categoryColors[0].toARGB32();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(categoryRepositoryProvider);
    final companion = CategoriesCompanion(
      name: Value(_nameController.text.trim()),
      kind: Value(_kind),
      icon: Value(_icon),
      color: Value(_color),
    );

    if (_isEditing) {
      await repo.update(widget.categoryId!, companion);
    } else {
      await repo.insert(CategoriesCompanion.insert(
        name: _nameController.text.trim(),
        kind: _kind,
        icon: Value(_icon),
        color: Value(_color),
      ));
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Category' : 'New Category'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category name',
                hintText: 'e.g. Groceries',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Text('Type', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                    value: 'expense',
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_upward)),
                ButtonSegment(
                    value: 'income',
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_downward)),
                ButtonSegment(
                    value: 'both',
                    label: Text('Both'),
                    icon: Icon(Icons.unfold_more)),
              ],
              selected: {_kind},
              onSelectionChanged: (v) => setState(() => _kind = v.first),
            ),
            const SizedBox(height: 24),
            Text('Icon', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons.map((entry) {
                final selected = _icon == entry.$1;
                return Material(
                  color: selected
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _icon = entry.$1),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(entry.$2,
                          size: 22,
                          color: selected
                              ? cs.onPrimaryContainer
                              : cs.onSurfaceVariant),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Color', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppColors.categoryColors.map((c) {
                final selected = _color == c.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _color = c.toARGB32()),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(10),
                      border: selected
                          ? Border.all(
                              color: cs.onSurface, width: 2.5)
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
