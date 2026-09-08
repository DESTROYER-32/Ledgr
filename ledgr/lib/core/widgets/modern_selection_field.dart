import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ModernSelectionItem<T> {
  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? badge;

  const ModernSelectionItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
    this.badge,
  });
}

class ModernSelectionField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<ModernSelectionItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? placeholder;
  final String? Function(T?)? validator;
  final IconData? leadingIcon;
  final bool allowClear;
  final bool enabled;
  final bool searchEnabled;

  const ModernSelectionField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.placeholder,
    this.validator,
    this.leadingIcon,
    this.allowClear = false,
    this.enabled = true,
    this.searchEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final selected = _selectedItem;
    final theme = Theme.of(context);

    return FormField<T>(
      key: ValueKey<Object?>(value),
      initialValue: value,
      validator: validator,
      builder: (state) {
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: enabled
              ? () async {
                  final result =
                      await showModalBottomSheet<_SelectionResult<T>>(
                    context: context,
                    useSafeArea: true,
                    showDragHandle: true,
                    enableDrag: false,
                    isScrollControlled: true,
                    builder: (_) => _ModernSelectionSheet<T>(
                      title: label,
                      value: value,
                      items: items,
                      allowClear: allowClear,
                      searchEnabled: searchEnabled,
                    ),
                  );
                  if (result != null) {
                    state.didChange(result.value);
                    onChanged(result.value);
                  }
                }
              : null,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              errorText: state.errorText,
              prefixIcon: leadingIcon == null ? null : Icon(leadingIcon),
              suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: selected == null
                ? Text(
                    placeholder ?? 'Select $label',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  )
                : _SelectedPreview(item: selected),
          ),
        );
      },
    );
  }

  ModernSelectionItem<T>? get _selectedItem {
    for (final item in items) {
      if (item.value == value) return item;
    }
    return null;
  }
}

class _SelectedPreview<T> extends StatelessWidget {
  final ModernSelectionItem<T> item;
  const _SelectedPreview({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (item.icon != null) ...[
          Icon(item.icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (item.subtitle != null)
                Text(
                  item.subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (item.badge != null) _Badge(text: item.badge!),
      ],
    );
  }
}

class _ModernSelectionSheet<T> extends StatefulWidget {
  final String title;
  final T? value;
  final List<ModernSelectionItem<T>> items;
  final bool allowClear;
  final bool searchEnabled;

  const _ModernSelectionSheet({
    required this.title,
    required this.value,
    required this.items,
    required this.allowClear,
    required this.searchEnabled,
  });

  @override
  State<_ModernSelectionSheet<T>> createState() =>
      _ModernSelectionSheetState<T>();
}

class _ModernSelectionSheetState<T> extends State<_ModernSelectionSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = widget.items.where((item) {
      final q = _query.toLowerCase();
      return item.title.toLowerCase().contains(q) ||
          (item.subtitle ?? '').toLowerCase().contains(q) ||
          (item.badge ?? '').toLowerCase().contains(q);
    }).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.68,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (context, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: theme.textTheme.titleLarge),
                ),
                if (widget.allowClear)
                  TextButton(
                    onPressed: () => Navigator.pop(
                      context,
                      const _SelectionResult<Never>(null),
                    ),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            if (widget.searchEnabled) ...[
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search ${widget.title.toLowerCase()}',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                controller: controller,
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final selected = item.value == widget.value;
                  return _ModernSelectionTile<T>(
                    item: item,
                    selected: selected,
                    onTap: () =>
                        Navigator.pop(context, _SelectionResult<T>(item.value)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernSelectionTile<T> extends StatelessWidget {
  final ModernSelectionItem<T> item;
  final bool selected;
  final VoidCallback onTap;

  const _ModernSelectionTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: selected
          ? cs.primaryContainer
          : cs.surfaceContainerHighest.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: selected ? cs.primary : cs.surface,
                foregroundColor: selected ? cs.onPrimary : cs.primary,
                child: Icon(item.icon ?? Icons.check_circle_outline_rounded),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.badge != null) ...[
                const SizedBox(width: 8),
                _Badge(text: item.badge!),
              ],
              const SizedBox(width: 8),
              AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: Icon(Icons.check_circle_rounded, color: cs.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onSecondaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: AppTextSizes.small,
        ),
      ),
    );
  }
}

class _SelectionResult<T> {
  final T? value;
  const _SelectionResult(this.value);
}
