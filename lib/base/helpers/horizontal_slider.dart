import 'package:campus_flutter/theme.dart';
import 'package:flutter/material.dart';

class HorizontalSlider<E> extends StatelessWidget {
  const HorizontalSlider(
      {super.key,
      required this.data,
      required this.height,
      required this.child,
      this.scrollController,
      this.leadingTrailingPadding = true});

  final List<E> data;
  final Widget Function(E data) child;
  final double height;
  final bool leadingTrailingPadding;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);
    return SizedBox(
        height: height,
        child: Padding(
            padding: EdgeInsets.only(right: orientation == Orientation.landscape ? context.padding : 0),
            child: ListView(scrollDirection: Axis.horizontal, controller: scrollController, children: [
              for (var indexAndValue in data.indexed) ...[
                if (indexAndValue.$1 == 0) ...[
                  if (leadingTrailingPadding) const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                  child(indexAndValue.$2)
                ],
                if (indexAndValue.$1 != 0 && indexAndValue.$1 == data.length - 1) ...[
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                  child(indexAndValue.$2),
                  if (orientation != Orientation.landscape && leadingTrailingPadding)
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 3))
                ],
                if (indexAndValue.$1 != 0 && indexAndValue.$1 != data.length - 1) ...[
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 3)),
                  child(indexAndValue.$2)
                ]
              ]
            ])));
  }
}
