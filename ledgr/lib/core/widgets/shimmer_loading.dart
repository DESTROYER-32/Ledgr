import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final fallbackWidth = constraints.hasBoundedWidth
                ? constraints.maxWidth.clamp(1.0, double.infinity)
                : 1.0;
            return Container(
              height: widget.height,
              width: widget.width ?? fallbackWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment(-1 + _controller.value * 2, 0),
                  end: Alignment(1 + _controller.value * 2, 0),
                  colors: [
                    theme.colorScheme.surfaceContainerHighest,
                    theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    theme.colorScheme.surfaceContainerHighest,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final int lines;

  const ShimmerCard({super.key, this.lines = 3});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            lines,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: i < lines - 1 ? 12 : 0),
              child: ShimmerLoading(
                height: 14,
                width: i == 0 ? 120 : (i == lines - 1 ? 200 : double.infinity),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
