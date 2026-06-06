import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/widgets/amount_field.dart';

class ObjectiveFormScreen extends ConsumerStatefulWidget {
  final int? objectiveId;
  const ObjectiveFormScreen({super.key, this.objectiveId});

  @override
  ConsumerState<ObjectiveFormScreen> createState() =>
      _ObjectiveFormScreenState();
}

class _ObjectiveFormScreenState extends ConsumerState<ObjectiveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'goal';
  DateTime? _deadline;
  int _color = 0xFF43A047;

  @override
  void initState() {
    super.initState();
    if (widget.objectiveId != null) _load();
  }

  Future<void> _load() async {
    final repo = ref.read(objectiveRepositoryProvider);
    final obj = await repo.getById(widget.objectiveId!);
    if (obj != null && mounted) {
      _nameController.text = obj.name;
      _amountController.text = (obj.amountMinor / 100).toStringAsFixed(2);
      _type = obj.type;
      _deadline = obj.deadline;
      _color = obj.color ?? 0xFF43A047;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.objectiveId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Objective' : 'New Objective')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'goal', label: Text('Savings Goal')),
                ButtonSegment(value: 'loan', label: Text('Loan / Debt')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            AmountField(
              controller: _amountController,
              label: _type == 'loan' ? 'Total Amount' : 'Target Amount',
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _deadline != null
                    ? 'Deadline: ${_deadline!.toLocal().toString().split(' ')[0]}'
                    : 'Set Deadline (optional)',
              ),
              trailing: _deadline != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _deadline = null),
                    )
                  : null,
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _deadline = d);
              },
            ),
            const SizedBox(height: 16),
            Text('Color', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  [
                        0xFF43A047,
                        0xFFE53935,
                        0xFF1E88E5,
                        0xFFFF8F00,
                        0xFF8E24AA,
                        0xFF00ACC1,
                        0xFFD81B60,
                        0xFF546E7A,
                      ]
                      .map(
                        (c) => GestureDetector(
                          onTap: () => setState(() => _color = c),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: _color == c
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(objectiveRepositoryProvider);
    final amount =
        (_amountController.text.isEmpty
                ? 0.0
                : double.parse(_amountController.text) * 100)
            .round();
    final entry = ObjectivesCompanion.insert(
      name: _nameController.text,
      type: _type,
      amountMinor: amount,
      currencyCode: 'USD',
      deadline: _deadline != null ? Value(_deadline!) : const Value(null),
      color: Value(_color),
    );
    if (widget.objectiveId != null) {
      await repo.update(widget.objectiveId!, entry);
    } else {
      await repo.insert(entry);
    }
    if (mounted) context.pop();
  }
}
