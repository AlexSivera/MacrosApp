import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

// An integer that counts from its previous value to the new one instead of
// jumping — used for the Diario's kcal figures so they move in step with
// the calorie ring. The first build shows the value straight away (no
// count-up from 0 every time a screen opens).
class AnimatedNumber extends StatefulWidget {
  const AnimatedNumber({super.key, required this.value, this.style, this.textAlign});

  final int value;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber> {
  late int _from = widget.value;

  @override
  void didUpdateWidget(AnimatedNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _from = oldWidget.value;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // A fresh key per target restarts the tween from the old value.
      key: ValueKey(widget.value),
      tween: Tween(begin: _from.toDouble(), end: widget.value.toDouble()),
      duration: AppMotion.of(context, AppMotion.counter),
      curve: AppMotion.curve,
      builder: (context, v, _) => Text(
        v.round().toString(),
        style: widget.style,
        textAlign: widget.textAlign,
        maxLines: 1,
      ),
    );
  }
}
