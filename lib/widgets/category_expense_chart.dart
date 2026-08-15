import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../utils/formatters.dart';

class CategoryExpenseChart extends StatelessWidget {
  const CategoryExpenseChart({
    super.key,
    required this.data,
    required this.categories,
    required this.currency,
  });

  final Map<String, double> data;
  final List<CategoryModel> categories;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No expenses this month yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    final total = data.values.fold(0.0, (a, b) => a + b);
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final slices = <_Slice>[];
    for (final e in entries) {
      CategoryModel? cat;
      for (final c in categories) {
        if (c.id == e.key) {
          cat = c;
          break;
        }
      }
      slices.add(
        _Slice(
          label: cat?.name ?? 'Unknown',
          value: e.value,
          color: Color(cat?.colorValue ?? 0xFF64748B),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: CustomPaint(
            painter: _PiePainter(slices: slices, total: total),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    Formatters.compactCurrency(total, currency),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...slices.map((s) {
          final pct = total == 0 ? 0.0 : (s.value / total * 100);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: s.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(s.label)),
                Text(
                  '${pct.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: 12),
                Text(
                  Formatters.currency(s.value, currency),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Slice {
  const _Slice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _PiePainter extends CustomPainter {
  _PiePainter({required this.slices, required this.total});

  final List<_Slice> slices;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var start = -math.pi / 2;

    for (final slice in slices) {
      final sweep = total == 0 ? 0.0 : (slice.value / total) * 2 * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.butt
        ..color = slice.color;
      canvas.drawArc(rect.deflate(14), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) =>
      oldDelegate.slices != slices || oldDelegate.total != total;
}
