import 'package:campus_flutter/base/helpers/icon_text.dart';
import 'package:campus_flutter/examsComponent/exams_view.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:campus_flutter/base/helpers/url_launcher.dart';
import 'package:campus_flutter/studentIdBalanceComponent/student_id_balance_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LinkView extends ConsumerWidget {
  const LinkView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
            child: AspectRatio(
                aspectRatio: 3,
                child: GestureDetector(
                    onTap: () async {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ExamsView()));
                    },
                    child: const Card(
                        margin: EdgeInsets.only(
                            right: 5.0, top: 5.0, bottom: 5.0, left: 15.0),
                        child: Center(
                            child: IconText(
                              iconData: Icons.school_outlined,
                              label: "Exams & Grades",
                              iconSize: 24,
                            )))))),
        Expanded(
            child: AspectRatio(
                aspectRatio: 3,
                child: GestureDetector(
                    onTap: () async {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const StudentIdBalanceView()));
                    },
                    child: const Card(
                        margin: EdgeInsets.only(
                            right: 5.0, top: 5.0, bottom: 5.0, left: 15.0),
                        child: Center(
                            child: IconText(
                              iconData: Icons.credit_card_outlined,
                              label: "Student ID Balance",
                              iconSize: 24,
                            )))))),
        Expanded(
            child: AspectRatio(
                aspectRatio: 3,
                child: GestureDetector(
                    onTap: () async {
                      if (MediaQuery.orientationOf(context) ==
                          Orientation.portrait) {
                        UrlLauncher.urlString("https://campus.tum.de", ref);
                      } else {
                        final controller = WebViewController()
                          ..setJavaScriptMode(JavaScriptMode.unrestricted)
                          ..setBackgroundColor(const Color(0x00000000))
                          ..setNavigationDelegate(NavigationDelegate(
                              onNavigationRequest: (request) =>
                              NavigationDecision.navigate))
                          ..loadRequest(Uri.parse("https://campus.tum.de"));
                        ref
                            .read(homeSplitViewModel)
                            .selectedWidget
                            .add(WebViewWidget(controller: controller));
                      }
                    },
                    child: const Card(
                        margin: EdgeInsets.only(
                            right: 15.0, top: 5.0, bottom: 5.0, left: 5.0),
                        child: Center(
                            child: IconText(
                              iconData: Icons.language_outlined,
                              label: "TUMOnline",
                              iconSize: 24,
                            ))))))
      ],
    );
  }
}
