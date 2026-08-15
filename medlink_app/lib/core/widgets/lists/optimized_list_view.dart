import 'package:flutter/material.dart';

/// Optimized ListView with automatic disposal and memory management
class OptimizedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? separator;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separator,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    if (separator != null) {
      return ListView.separated(
        padding: padding,
        physics: physics,
        shrinkWrap: shrinkWrap,
        itemCount: items.length,
        separatorBuilder: (_, __) => separator!,
        itemBuilder: (context, index) {
          return itemBuilder(context, items[index], index);
        },
      );
    }

    return ListView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index], index);
      },
    );
  }
}