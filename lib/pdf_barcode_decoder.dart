import 'dart:async';

import 'package:flutter/services.dart';

class PdfBarcodeDecoder {
  static const MethodChannel _channel =
      const MethodChannel('pdf_barcode_decoder');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
