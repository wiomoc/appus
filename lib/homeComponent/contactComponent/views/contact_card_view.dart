import 'package:campus_flutter/base/helpers/api_backed_state.dart';
import 'package:campus_flutter/base/helpers/api_operation.dart';
import 'package:campus_flutter/base/helpers/delayed_loading_indicator.dart';
import 'package:campus_flutter/homeComponent/contactComponent/api/my_name.dart';
import 'package:campus_flutter/homeComponent/contactComponent/api/my_studies.dart';
import 'package:campus_flutter/homeComponent/contactComponent/model/study.dart';
import 'package:flutter/material.dart';

class ContactCardView extends StatefulWidget {
  const ContactCardView({super.key});

  @override
  State<ContactCardView> createState() => _ContactCardViewState();
}

class _ContactCardViewState extends ApiBackedState<(String?, List<Study>?), ContactCardView> {
  @override
  void initState() {
    load(MergedApiOperation(MyNameApiOperation(), MyStudiesApiOperation()), Duration(days: 1));
    super.initState();
  }

  @override
  build(BuildContext context) {
    return body();
  }

  @override
  Widget? buildBody((String?, List<Study>?) data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data.$1 ?? "", style: Theme.of(context).textTheme.headlineSmall),
        Text(data.$2
                ?.map((study) => "${study.localizedDegree.replaceFirst("studium", "")} ${study.localizedName}")
                .join(", ") ??
            "")
      ],
    );
  }

  @override
  String get resourceName => "Personal Information";
}
