import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/progress_providers.dart';

// Full-width, short labels ("7 d", "3 m"…) so all five ranges fit on a phone
// — the long labels in a horizontal scroll cut "6 meses" off at the edge.
class RangeSelector extends ConsumerWidget {
  const RangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(progressRangeProvider);

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ProgressRange>(
        showSelectedIcon: false,
        segments: [
          for (final range in ProgressRange.values)
            ButtonSegment(value: range, label: Text(range.shortLabel), tooltip: range.label),
        ],
        selected: {selected},
        onSelectionChanged: (s) => ref.read(progressRangeProvider.notifier).state = s.first,
      ),
    );
  }
}
