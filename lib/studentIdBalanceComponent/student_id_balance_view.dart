import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import '../base/helpers/card_with_padding.dart';
import '../base/helpers/icon_text.dart';

class StudentIdBalanceView extends StatefulWidget {
  const StudentIdBalanceView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StudentIdBalanceViewState();
  }
}

class _StudentIdBalanceViewState extends State<StudentIdBalanceView> {
  bool? _isNfcAvailable;
  double? _balance = 999.99;
  String? _error;

  Future<void> _onDiscovered(NfcTag tag) async {
    setState(() {
      _balance = null;
      _error = null;
    });
    Future<Uint8List> Function(Uint8List)? mifareDesfireTagTransceive;
    if (Platform.isAndroid) {
      final mifareDesfireTag = IsoDep.from(tag);
      if (mifareDesfireTag != null) {
        mifareDesfireTagTransceive = (data) => mifareDesfireTag.transceive(data: data);
      }
    } else if (Platform.isIOS) {
      final mifareDesfireTag = MiFare.from(tag);
      mifareDesfireTagTransceive = mifareDesfireTag?.sendMiFareCommand;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
    if (mifareDesfireTagTransceive == null) {
      setState(() {
        _balance = null;
        _error = "Card is not a correct Student ID";
      });
      return;
    }
    // Select Application
    final selectResponse = await mifareDesfireTagTransceive(Uint8List.fromList([0x5A, 0x5F, 0x84, 0x15]));
    if (selectResponse.length != 1 || selectResponse[0] != 0) {
      setState(() {
        _balance = null;
        _error = "Could not select app: $selectResponse";
      });
      return;
    }
    // Get Value
    final valueResponse = await mifareDesfireTagTransceive(Uint8List.fromList([0x6C, 0x01]));
    if (valueResponse.length < 5 || valueResponse[0] != 0) {
      setState(() {
        _balance = null;
        _error = "Could not get value: $valueResponse";
      });
      return;
    }

    final balance = ((valueResponse[1] & 0xFF) |
            ((valueResponse[2] & 0xFF) << 8) |
            ((valueResponse[3] & 0xFF) << 16) |
            ((valueResponse[4] & 0xFF << 24))) /
        1000.0;
    setState(() {
      _balance = balance;
    });
  }

  @override
  void initState() {
    super.initState();
    NfcManager.instance.isAvailable().then((isNfcAvailable) {
      setState(() => _isNfcAvailable = true);
      if (isNfcAvailable) {
        NfcManager.instance.startSession(pollingOptions: {NfcPollingOption.iso14443}, onDiscovered: _onDiscovered);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isNfcAvailable == null) {
      body = const Text("Initializing");
    } else if (_isNfcAvailable == false) {
      body =
          Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
        const Icon(Icons.wifi_off, size: 100),
        Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
        Text("NFC not available", style: Theme.of(context).textTheme.titleLarge)
      ]);
    } else {
      if (_balance == null) {
        body = Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.tap_and_play_outlined, size: 100),
              Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
              Text(
                "Tap Student ID to check balance",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_error != null)
                Text(_error!, style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.red)),
            ]);
      } else {
        body = CardWithPadding(
            color: _balanceColor,
            child: SizedBox(
                height: 95,
                width: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IconText(
                        iconData: Icons.credit_card_outlined,
                        iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        label: "Balance",
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
                    Text("${_balance!.toStringAsFixed(2).replaceFirst(".", ",")}€",
                        style: TextStyle(fontSize: 40, color: Theme.of(context).colorScheme.onPrimaryContainer))
                  ],
                )));
      }
    }
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Student ID Balance"),
      ),
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
    } else  {
      return const Color.fromRGBO(236, 60, 26, 1.0);
    }
  }
}