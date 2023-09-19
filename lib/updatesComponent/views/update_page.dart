import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:flutter/material.dart';
import '../api/organisations_api.dart';
import '../model/organisation.dart';
import 'organisation_view.dart';



class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() {
    return _UpdatesPageState();
  }
}


class _UpdatesPageState extends ApiBackedState<List<Organisation>, UpdatesPage> with ApiPullRefresh {
  @override
  void initState() {
    super.initState();
    load(OrganisationsApiOperation(), const Duration(minutes: 5));
  }

  @override
  Widget build(BuildContext context) => body();

  @override
  Widget buildBody(List<Organisation> organisations) {
    return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 3),
        itemBuilder: (context, index) => OrganisationView(
              organisations[index],
              key: ValueKey(organisations[index].id),
            ),
        itemCount: organisations.length);
  }

  @override
  // TODO: implement resourceName
  String get resourceName => "Updates";
}
