import 'package:campus_flutter/base/helpers/icon_text.dart';
import 'package:campus_flutter/examsComponent/exams_view.dart';
import 'package:campus_flutter/base/helpers/url_launcher.dart';
import 'package:campus_flutter/studentIdBalanceComponent/student_id_balance_page.dart';
import 'package:campus_flutter/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LinkView extends ConsumerWidget {
  const LinkView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
            child: SizedBox(
                height: 60,
                child: Card(
                    margin: EdgeInsets.only(right: 5.0, top: 5.0, bottom: 5.0, left: context.halfPadding),
                    child: InkWell(
                        onTap: () async {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ExamsScreen()));
                        },
                        borderRadius: BorderRadius.circular(10.0),
                        child: const Center(
                            child: IconText(
                          iconData: Icons.school_outlined,
                          label: "Prüfungen",
                          iconSize: 24,
                        )))))),
        Expanded(
            child: SizedBox(
                height: 60,
                child: Card(
                    margin: const EdgeInsets.all(5.0),
                    child: InkWell(
                        onTap: () async {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) => const StudentIdBalancePage()));
                        },
                        borderRadius: BorderRadius.circular(10.0),
                        child: const Center(
                            child: IconText(
                          iconData: Icons.credit_card_outlined,
                          label: "Balance",
                          iconSize: 24,
                        )))))),
        Expanded(
            child: SizedBox(
                height: 60,
                child: Card(
                    margin: EdgeInsets.only(right: context.halfPadding, top: 5.0, bottom: 5.0, left: 5.0),
                    child: InkWell(
                        onTap: () async {
                          UrlLauncher.urlString("https://campus.tum.de", ref);
                        },
                        borderRadius: BorderRadius.circular(10.0),
                        child: const Center(
                            child: IconText(
                          iconData: Icons.language_outlined,
                          label: "C@mpus",
                          iconSize: 24,
                        ))))))
      ],
    );
  }
}
