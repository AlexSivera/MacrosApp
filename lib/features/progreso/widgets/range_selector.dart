import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/progress_providers.dart';

class RangeSelector extends ConsumerWidget {
  const RangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(progressRangeProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<ProgressRange>(
        segments: [
          for (final range in ProgressRange.values)
            ButtonSegment(value: range, label: Text(range.label)),
        ],
        selected: {selected},
        onSelectionChanged: (s) => ref.read(progressRangeProvider.notifier).state = s.first,
      ),
    );
  }
}
