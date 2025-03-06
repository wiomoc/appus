import 'dart:io';
import 'dart:typed_data';

import 'package:campus_flutter/base/l10n/generated/app_localizations.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

abstract interface class StudentIdNfcListener {
  void onAvailabilityChanged(bool available);

  void onCardDiscovered();

  void onBalanceRead(double balance);

  void onError(String Function(AppLocalizations localizations) errorSupplier);
}

class StudentIdNfcService {
  final StudentIdNfcListener _listener;
  bool _nfcSessionStarted = false;

  StudentIdNfcService(this._listener);

  Future<void> start() async {
    bool isNfcAvailable;
    try {
      isNfcAvailable = await NfcManager.instance.isAvailable();
    } catch (e) {
      isNfcAvailable = false;
    }
    if (isNfcAvailable) {
      try {
        await NfcManager.instance
            .startSession(pollingOptions: {NfcPollingOption.iso14443}, onDiscovered: _onDiscovered);
        _nfcSessionStarted = true;
      } catch (e) {
        isNfcAvailable = false;
      }
    }
    _listener.onAvailabilityChanged(isNfcAvailable);
  }

  Future<void> _onDiscovered(NfcTag tag) async {
    _listener.onCardDiscovered();
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
      _listener.onError((localizations) => localizations.studentIdBalanceCardIsNotAID);
      return;
    }
    // Select Application
    final selectResponse = await mifareDesfireTagTransceive(Uint8List.fromList([0x5A, 0x5F, 0x84, 0x15]));
    if (selectResponse.length != 1 || selectResponse[0] != 0) {
      _listener.onError((localizations) => "Could not select app: $selectResponse");
      return;
    }
    // Get Value
    final valueResponse = await mifareDesfireTagTransceive(Uint8List.fromList([0x6C, 0x01]));
    if (valueResponse.length < 5 || valueResponse[0] != 0) {
      _listener.onError((localizations) => "Could not get value: $valueResponse");
      return;
    }

    final balance = ((valueResponse[1] & 0xFF) |
            ((valueResponse[2] & 0xFF) << 8) |
            ((valueResponse[3] & 0xFF) << 16) |
            ((valueResponse[4] & 0xFF << 24))) /
        1000.0;
    _listener.onBalanceRead(balance);
  }

  void dispose() {
    if (_nfcSessionStarted) {
      NfcManager.instance.stopSession();
    }
  }
}
