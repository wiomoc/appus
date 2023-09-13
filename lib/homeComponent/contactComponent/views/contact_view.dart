import 'package:campus_flutter/base/helpers/card_with_padding.dart';
import 'package:campus_flutter/homeComponent/contactComponent/views/contact_card_view.dart';
import 'package:campus_flutter/homeComponent/contactComponent/views/link_view.dart';
import 'package:campus_flutter/homeComponent/contactComponent/views/tuition_view.dart';
import 'package:campus_flutter/homeComponent/contactComponent/views/unauthorized_view.dart';
import 'package:campus_flutter/providers_get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.15),
          child: const CardWithPadding(child: Center(child: ContactCardView()))),
      const TuitionView(),
      const LinkView()
    ]);
  }
}
