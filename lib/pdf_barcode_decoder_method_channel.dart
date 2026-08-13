import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pdf_barcode_decoder_platform_interface.dart';
import 'src/models/decoder_config.dart';
import 'src/models/pdf_barcode.dart';
import 'src/exceptions/pdf_barcode_exception.dart';

/// An implementation of [PdfBarcodeDecoderPlatform] that uses method channels.
class MethodChannelPdfBarcodeDecoder extends PdfBarcodeDecoderPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pdf_barcode_decoder');

  @override
  Future<List<PdfBarcode>> decodePdf({String? filePath, Uint8List? pdfBytes, required DecoderConfig config}) async {
    try {
      final List<dynamic>? results = await methodChannel.invokeListMethod<dynamic>(
        'decodePdf',
        {
          'filePath': ?filePath,
          'pdfBytes': ?pdfBytes,
          'config': config.toMap(),
        },
      );
      
      if (results == null) return [];
      
      return results.map((e) => PdfBarcode.fromMap(e as Map<Object?, Object?>)).toList();
    } on PlatformException catch (e) {
      throw PdfBarcodeException(
        code: e.code,
        message: e.message ?? 'Unknown error',
        details: e.details,
      );
    }
  }
}
