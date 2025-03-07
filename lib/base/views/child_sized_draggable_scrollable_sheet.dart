import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ChildSizedDraggableScrollableSheet extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  final double hiddenHeight;
  final double bottomPadding;

  const ChildSizedDraggableScrollableSheet(
      {super.key, required this.builder, this.hiddenHeight = 0, this.bottomPadding = 15});

  @override
  State<StatefulWidget> createState() => _ChildSizedDraggableScrollableSheetState();
}

class _ChildSizedDraggableScrollableSheetState extends State<ChildSizedDraggableScrollableSheet> {
  double _maxSize = 1;
  double _initialSize = 1;
  final double minSize = 0.2;

  DraggableScrollableController draggableScrollController = DraggableScrollableController();

  void _setMaxChildSize(Size size) {
    setState(() {
      final mediaQuery = MediaQuery.of(context);
      double boxHeight = size.height + mediaQuery.padding.bottom + widget.bottomPadding;
      double screenHeight = mediaQuery.size.height - mediaQuery.padding.top;
      double initialRatio = (boxHeight - widget.hiddenHeight) / screenHeight;
      double maxRatio = boxHeight / screenHeight;
      _maxSize = min(max(maxRatio, minSize), 1);
      _initialSize = min(max(initialRatio, minSize), 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: draggableScrollController,
      initialChildSize: _initialSize,
      minChildSize: minSize,
      maxChildSize: _maxSize,
      expand: false,
      builder: (_, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: MeasureSize(
          onChange: _setMaxChildSize,
          child: widget.builder(context),
        ),
      ),
    );
  }

  @override
  void dispose() {
    draggableScrollController.dispose();
    super.dispose();
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(BuildContext context, covariant MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}
