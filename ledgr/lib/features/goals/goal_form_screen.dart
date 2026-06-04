import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/database/app_database.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_theme.dart';

class GoalFormScreen extends ConsumerStatefulWidget {
  final int? goalId;
  const GoalFormScreen({super.key, this.goalId});

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _deadline;
  int _color = AppColors.categoryColors[0].toARGB32();
  bool _isLoading = false;

  bool get _isEditing => widget.goalId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(goalRepositoryProvider);
    final goal = await repo.getById(widget.goalId!);
    if (goal != null && mounted) {
      setState(() {
        _nameController.text = goal.name;
        _amountController.text = (goal.targetAmountMinor / 100).toStringAsFixed(2);
        _deadline = goal.deadline;
        _color = goal.color ?? AppColors.categoryColors[0].toARGB32();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final repo = ref.read(goalRepositoryProvider);
    final targetAmount = ((double.tryParse(_amountController.text) ?? 0) * 100).round();
    final currencyCode = ref.read(currencyCodeProvider).valueOrNull ?? 'USD';

    final companion = GoalsCompanion(
      name: Value(_nameController.text.trim()),
      targetAmountMinor: Value(targetAmount),
      currencyCode: Value(currencyCode),
      deadline: Value(_deadline),
      color: Value(_color),
    );

    if (_isEditing) {
      await repo.update(widget.goalId!, companion);
    } else {
      await repo.insert(GoalsCompanion.insert(
        name: _nameController.text.trim(),
        targetAmountMinor: targetAmount,
        currencyCode: currencyCode,
        deadline: Value(_deadline),
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
      appBar: AppBar(title: Text(_isEditing ? 'Edit Goal' : 'New Goal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Goal name',
                hintText: 'e.g. Emergency Fund',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              autofocus: true,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Target amount',
                hintText: '0.00',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(_deadline != null
                  ? 'Deadline: ${_deadline!.toLocal().toString().split(' ')[0]}'
                  : 'No deadline'),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _deadline ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2050),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
              trailing: _deadline != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _deadline = null),
                    )
                  : null,
            ),
            const SizedBox(height: 20),
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
                      border: selected ? Border.all(color: cs.onSurface, width: 2.5) : null,
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
              onPressed: _isLoading ? null : _save,
              child: Text(_isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
