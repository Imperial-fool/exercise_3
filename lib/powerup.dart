import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class box extends StatelessWidget {
  const box(this.x, this.y, this.color, {Key? key}) : super(key: key);
  final x;
  final y;
  final color;
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(x, y),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          width: 20,
          height: 20,
        ));
  }
}
