import 'package:campus_flutter/base/helpers/card_with_padding.dart';
import 'package:campus_flutter/homeComponent/contactComponent/views/contact_card_view.dart';
import 'package:campus_flutter/homeComponent/contactComponent/views/link_view.dart';
import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.15),
          child: const CardWithPadding(child: Center(child: ContactCardView()))),
      const LinkView()
    ]);
  }
}
