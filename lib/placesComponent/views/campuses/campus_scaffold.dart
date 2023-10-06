import 'package:campus_flutter/base/enums/campus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CampusScaffold extends ConsumerStatefulWidget {
  const CampusScaffold({super.key, required this.campus});

  final Campus campus;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CampusScaffoldState();
}

class _CampusScaffoldState extends ConsumerState<CampusScaffold> {
  final _height = 200.0;
  final _fraction = 3 / 4;

  @override
  Widget build(BuildContext context) {
    final fractionalHeight = _height * _fraction;
    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(widget.campus.name),
          titleSpacing: 0,
        ),
        body: CustomScrollView(slivers: [
          SliverLayoutBuilder(builder: (context, constraints) {
            final progress = constraints.scrollOffset > fractionalHeight
                ? (constraints.scrollOffset - fractionalHeight) /
                    (_height - 0 - fractionalHeight)
                : 0.0;
            return SliverAppBar(
              expandedHeight: _height,
              toolbarHeight: 0,
              collapsedHeight: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Opacity(
                    opacity: progress <= 1 ? 1 - progress : 0,
                    child: Image.asset(
                      widget.campus.image ?? "",
                      fit: BoxFit.cover,
                    )),
                centerTitle: true,
                expandedTitleScale: 1,
              ),
            );
          }),
          //CampusView(campus: widget.campus)
        ]));
  }
}
