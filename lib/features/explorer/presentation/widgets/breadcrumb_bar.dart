import 'dart:io';
import 'package:flutter/material.dart';

class BreadcrumbBar extends StatelessWidget {
  final List<Directory> stack;
  final void Function(int index) onTap;

  const BreadcrumbBar({
    super.key,
    required this.stack,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 40,
      color: colorScheme.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: stack.length,
        separatorBuilder: (_, __) => Icon(
          Icons.chevron_right,
          size: 16,
          color: colorScheme.onSurface.withOpacity(0.4),
        ),
        itemBuilder: (context, index) {
          final dir = stack[index];
          final name = index == 0 ? 'Inicio' : dir.path.split('/').last;
          final isLast = index == stack.length - 1;

          return GestureDetector(
            onTap: isLast ? null : () => onTap(index),
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                  color: isLast
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
