import 'package:campus_flutter/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SearchTextField extends StatefulWidget {
  final void Function(String search) onTextUpdate;
  final int index;

  const SearchTextField({super.key, required this.onTextUpdate, required this.index});

  @override
  State<StatefulWidget> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  bool showIcon = false;
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: context.padding),
        child: TextField(
          controller: textEditingController,
          autofocus: true,
          onChanged: (searchString) {
            widget.onTextUpdate(searchString);
            setState(() {
              showIcon = searchString.isNotEmpty;
            });
          },
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.search,
            suffixIcon: showIcon
                ? GestureDetector(
                    onTap: () {
                      textEditingController.clear();
                      widget.onTextUpdate("");
                      setState(() {
                        showIcon = false;
                      });
                    },
                    child: const Icon(Icons.clear),
                  )
                : null,
          ),
        ));
  }
}
