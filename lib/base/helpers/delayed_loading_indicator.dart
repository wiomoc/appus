import 'package:flutter/material.dart';
import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';

class DelayedLoadingIndicator extends StatelessWidget {
  const DelayedLoadingIndicator({
    super.key,
    this.name,
    this.alternativeLoadingIndicator, this.delayWidget = const SizedBox.shrink()
  });

  final String? name;
  final Widget? alternativeLoadingIndicator;
  final Widget delayWidget;

  @override
  Widget build(BuildContext context) {
    final loadingText = AppLocalizations.of(context)!.loading;
    return FutureBuilder(
        future: Future.delayed(const Duration(milliseconds: 150)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (alternativeLoadingIndicator == null) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator.adaptive(),
                        Text(name != null ? "$loadingText $name" : loadingText)
                      ]
                  )
              );
            } else {
              return alternativeLoadingIndicator!;
            }
          } else {
            return delayWidget;
          }
        }
    );
  }
}