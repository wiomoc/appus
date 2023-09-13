import 'package:campus_flutter/base/enums/campus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CampusView extends ConsumerStatefulWidget {
  const CampusView({super.key, required this.campus});

  final Campus campus;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CampusViewState();
}

class _CampusViewState extends ConsumerState<CampusView> {

  @override
  void initState() {
   // ref
    //    .read(navigaTumViewModel)
     //   .mostSearched(widget.campus.searchStringRooms, false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
        child: Column(
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
       // const CampusMostSearchedView()
      ],
    ));
  }
}
