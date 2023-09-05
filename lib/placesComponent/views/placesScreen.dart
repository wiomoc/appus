import 'package:campus_flutter/base/helpers/delayed_loading_indicator.dart';
import 'package:campus_flutter/base/views/error_handling_view.dart';
import 'package:campus_flutter/placesComponent/views/placesView.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  @override
  void initState() {
    //ref.read(placesViewModel).fetch(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  const PlacesView();
    /*
    return StreamBuilder(
        stream: ref.watch(placesViewModel).status,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const PlacesView();
          } else if (snapshot.hasError) {
            return ErrorHandlingView(
              error: snapshot.error!,
              errorHandlingViewType: ErrorHandlingViewType.fullScreen,
              retry: ref.read(placesViewModel).fetch,
            );
          } else {
            return const DelayedLoadingIndicator(
                name: "Cafeterias & Study Rooms");
          }
        });
        */
  }
}
