import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';

class ScannerTemplateFormScreen extends ConsumerStatefulWidget {
  final int? templateId;
  const ScannerTemplateFormScreen({super.key, this.templateId});

  @override
  ConsumerState<ScannerTemplateFormScreen> createState() =>
      _ScannerTemplateFormScreenState();
}

class _ScannerTemplateFormScreenState
    extends ConsumerState<ScannerTemplateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _containsCtrl = TextEditingController();
  final _titleBeforeCtrl = TextEditingController();
  final _titleAfterCtrl = TextEditingController();
  final _amountBeforeCtrl = TextEditingController();
  final _amountAfterCtrl = TextEditingController();
  int? _categoryId;
  int? _walletId;

  @override
  void initState() {
    super.initState();
    if (widget.templateId != null) _load();
  }

  Future<void> _load() async {
    final repo =
        ref.read(scannerTemplateRepositoryProvider);
    final t = await repo.getById(widget.templateId!);
    if (t != null && mounted) {
      _nameCtrl.text = t.name;
      _containsCtrl.text = t.contains ?? '';
      _titleBeforeCtrl.text = t.titleBefore ?? '';
      _titleAfterCtrl.text = t.titleAfter ?? '';
      _amountBeforeCtrl.text = t.amountBefore ?? '';
      _amountAfterCtrl.text = t.amountAfter ?? '';
      _categoryId = t.defaultCategoryId;
      _walletId = t.walletId;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _containsCtrl.dispose();
    _titleBeforeCtrl.dispose();
    _titleAfterCtrl.dispose();
    _amountBeforeCtrl.dispose();
    _amountAfterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.templateId != null
              ? 'Edit Template'
              : 'New Template')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _containsCtrl,
              decoration: const InputDecoration(
                labelText: 'Contains Text',
                hintText: 'Keyword the email must contain',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Text('Title Extraction',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _titleBeforeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Text Before Title',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _titleAfterCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Text After Title',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Amount Extraction',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountBeforeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Text Before Amount',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _amountAfterCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Text After Amount',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(widget.templateId != null
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
    final repo =
        ref.read(scannerTemplateRepositoryProvider);
    final entry = ScannerTemplatesCompanion.insert(
      name: _nameCtrl.text,
      contains: _containsCtrl.text.isNotEmpty
          ? Value(_containsCtrl.text)
          : const Value(null),
      titleBefore: _titleBeforeCtrl.text.isNotEmpty
          ? Value(_titleBeforeCtrl.text)
          : const Value(null),
      titleAfter: _titleAfterCtrl.text.isNotEmpty
          ? Value(_titleAfterCtrl.text)
          : const Value(null),
      amountBefore: _amountBeforeCtrl.text.isNotEmpty
          ? Value(_amountBeforeCtrl.text)
          : const Value(null),
      amountAfter: _amountAfterCtrl.text.isNotEmpty
          ? Value(_amountAfterCtrl.text)
          : const Value(null),
      defaultCategoryId: _categoryId != null
          ? Value(_categoryId!)
          : const Value(null),
      walletId: _walletId != null
          ? Value(_walletId!)
          : const Value(null),
    );
    if (widget.templateId != null) {
      await repo.update(widget.templateId!, entry);
    } else {
      await repo.insert(entry);
    }
    if (mounted) context.pop();
  }
}
