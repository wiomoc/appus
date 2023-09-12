import 'package:campus_flutter/base/helpers/icon_text.dart';
import 'package:campus_flutter/base/helpers/padded_divider.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/views/widget_frame_view.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
/*
class CampusMostSearchedView extends ConsumerWidget {
  const CampusMostSearchedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
        stream: ref.watch(navigaTumViewModel).mostSearchedResults,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return WidgetFrameView(
                title: "Most Searched Rooms",
                child: Card(
                  child: Column(
                    children: [
                      for (var entity in snapshot.data!.indexed) ...[
                        ListTile(
                          title: IconText(
                            iconData: Icons.school,
                            label: entity.$2.getFormattedName(),
                            style: Theme.of(context).textTheme.bodyMedium,
                            multipleLines: true,
                            iconSize: 15,
                            iconColor: Theme.of(context).primaryColor,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          ),
                        ),
                        if (entity.$1 < snapshot.data!.length - 1)
                          const PaddedDivider(
                            height: 0,
                          )
                      ]
                    ],
                  ),
                ));
          } else if (snapshot.hasError) {
            return const Text("Error");
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
*/