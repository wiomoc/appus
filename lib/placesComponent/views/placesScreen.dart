import 'package:campus_flutter/placesComponent/views/placesView.dart';
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
