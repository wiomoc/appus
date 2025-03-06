import 'dart:io';

import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';
import 'package:campus_flutter/studentIdBalanceComponent/student_id_nfc_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import '../base/helpers/card_with_padding.dart';
import '../base/helpers/icon_text.dart';

class StudentIdBalancePage extends StatefulWidget {
  const StudentIdBalancePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StudentIdBalancePageState();
  }
}

class _StudentIdBalancePageState extends State<StudentIdBalancePage> implements StudentIdNfcListener {
  late final StudentIdNfcService _service;

  bool? _isNfcAvailable;
  double? _balance;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = StudentIdNfcService(this);
    _service.start();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isNfcAvailable == null) {
      body = Center(
          child: Text("Initializing", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge));
    } else if (_isNfcAvailable == false) {
      body =
          Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
        const Icon(Icons.wifi_off, size: 100),
        const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
        Text(AppLocalizations.of(context)!.studentIdNFCUnavailable,
            textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge)
      ]);
    } else {
      if (_balance == null) {
        body = Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.contactless_outlined, size: 100),
              const Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
              Text(
                AppLocalizations.of(context)!.studentIdNFCTapToAction,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_error != null)
                Text(_error!, style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.red)),
            ]);
      } else {
        body = CardWithPadding(
            color: _balanceColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconText(
                    iconData: Icons.credit_card_outlined,
                    iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                    label: AppLocalizations.of(context)!.studentIdBalanceBalance,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                // Implicit min width of 140 px
                const Padding(padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 70)),
                Text("${_balance!.toStringAsFixed(2).replaceFirst(".", ",")}€",
                    style: TextStyle(fontSize: 40, color: Theme.of(context).colorScheme.onPrimaryContainer))
              ],
            ));
      }
    }
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(AppLocalizations.of(context)!.studentIdBalance)),
      body: Center(child: body),
    );
  }

  Color get _balanceColor {
    final balance = _balance!;
    if (balance > 14) {
      return const Color.fromRGBO(87, 159, 43, 1.0);
    } else if (balance >= 12) {
      return const Color.fromRGBO(119, 195, 68, 1.0);
    } else if (balance >= 10) {
      return const Color.fromRGBO(149, 210, 107, 1.0);
    } else if (balance >= 7) {
      return const Color.fromRGBO(220, 230, 117, 1.0);
    } else if (balance >= 5) {
      return const Color.fromRGBO(255, 223, 0, 1.0);
    } else if (balance >= 4) {
      return const Color.fromRGBO(247, 199, 88, 1.0);
    } else if (balance >= 3) {
      return const Color.fromRGBO(245, 180, 51, 1.0);
    } else if (balance >= 2) {
      return const Color.fromRGBO(243, 175, 34, 1.0);
    } else if (balance >= 1.5) {
      return const Color.fromRGBO(248, 137, 0, 1.0);
    } else {
      return const Color.fromRGBO(236, 60, 26, 1.0);
    }
  }

  @override
  void onAvailabilityChanged(bool available) {
    setState(() {
      _isNfcAvailable = available;
    });
  }

  @override
  void onBalanceRead(double balance) {
    setState(() {
      _error = null;
      _balance = balance;
    });
  }

  @override
  void onCardDiscovered() {
    setState(() {
      _error = null;
      _balance = null;
    });
  }

  @override
  void onError(String Function(AppLocalizations localizations) errorSupplier) {
    setState(() {
      _error = errorSupplier(AppLocalizations.of(context)!);
      _balance = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _service.dispose();
  }
}
