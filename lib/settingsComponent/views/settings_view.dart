import 'dart:io';

import 'package:campus_flutter/base/helpers/hyperlink_text.dart';
import 'package:campus_flutter/base/helpers/padded_divider.dart';
import 'package:campus_flutter/base/networking/apis/campUSApi/campus_api.dart';
import 'package:campus_flutter/homeComponent/widgetComponent/views/widget_frame_view.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text("Settings"),
        ),
        body: ListView(children: [
          if (!kIsWeb && Platform.isIOS) _generalSettings(context, ref),
          _appearance(context, ref),
          _contact(ref),
          _authentication(context, ref),
          _versionNumber()
        ]));
  }

  Widget _generalSettings(BuildContext context, WidgetRef ref) {
    return WidgetFrameView(
        title: "General Settings",
        child: Column(children: [
          if (!kIsWeb && Platform.isIOS) _useWebView(context, ref)
        ]));
  }

  Widget _useWebView(BuildContext context, WidgetRef ref) {
    return Card(
        child: ListTile(
      dense: true,
      title:
          Text("Use Web View", style: Theme.of(context).textTheme.bodyMedium),
      trailing: Switch(
          value: ref.watch(useWebView),
          onChanged: (showWebView) {
            ref.read(useWebView.notifier).state = showWebView;
          }),
    ));
  }

  Widget _appearance(BuildContext context, WidgetRef ref) {
    return WidgetFrameView(
        title: "Appearance",
        child: Column(children: [
          _hideFailedGrades(context, ref),
        ]));
  }

  Widget _hideFailedGrades(BuildContext context, WidgetRef ref) {
    return Card(
        child: ListTile(
      dense: true,
      title: Text("Hide Failed Grades",
          style: Theme.of(context).textTheme.bodyMedium),
      trailing: Switch(
          value: ref.watch(hideFailedGrades),
          onChanged: (value) {
            ref.read(hideFailedGrades.notifier).state = value;
          }),
    ));
  }

  Widget _contact(WidgetRef ref) {
    return WidgetFrameView(
        title: "Contact Us",
        child: Card(
            child: Column(
          children: [
            const ListTile(
              dense: true,
              title: HyperLinkText(
                  link: "https://testflight.apple.com/join/4Ddi6f2f",
                  label: "Become a Beta Tester"),
            ),
            const PaddedDivider(height: 0),
            const ListTile(
              dense: true,
              title: HyperLinkText(
                  link: "https://github.com/TUM-Dev",
                  label: "TUM Dev on GitHub"),
            ),
            const PaddedDivider(height: 0),
            const ListTile(
              dense: true,
              title: HyperLinkText(
                  link: "https://app.tum.de", label: "TUM Dev Website"),
            ),
            const PaddedDivider(height: 0),
            ListTile(
              dense: true,
              title: HyperLinkText(uri: _feedbackEmail(), label: "Feedback"),
            ),
          ],
        )));
  }

  Uri _feedbackEmail() {
    final operatingSystem = kIsWeb ? "Web App" : Platform.operatingSystem;
    String email = Uri.encodeComponent("app@tum.de");
    String subject = Uri.encodeComponent("[$operatingSystem - Feedback]");
    return Uri.parse("mailto:$email?subject=$subject");
  }

  Widget _authentication(BuildContext context, WidgetRef ref) {
    final campusApi = getIt<CampusApi>();
    final isAuthenticated = campusApi.isAuthenticated.value == true;
    return WidgetFrameView(
        child: GestureDetector(
            onTap: () {
              if (isAuthenticated) {
                campusApi.logout();
              }
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Card(
                child: ListTile(
              dense: true,
              title: !isAuthenticated
                  ? Text("Login",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center)
                  : Text("Logout",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center),
            ))));
  }

  Widget _versionNumber() {
    return Center(
        child: FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text("Version ${snapshot.data!.version}");
              } else {
                return const Text("Version -.-.-");
              }
            }));
  }
}
