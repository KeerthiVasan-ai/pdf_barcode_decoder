import 'dart:io';
import 'package:flutter/services.dart';

import 'pdf_barcode_decoder_platform_interface.dart';
import 'src/models/decoder_config.dart';
import 'src/models/pdf_barcode.dart';

export 'src/enums/barcode_format.dart';
export 'src/exceptions/pdf_barcode_exception.dart';
export 'src/models/decoder_config.dart';
export 'src/models/pdf_barcode.dart';

class PdfBarcodeDecoder {
  /// Decodes barcodes from PDF bytes in memory.
  static Future<List<PdfBarcode>> decode(
    Uint8List pdfBytes, {
    DecoderConfig? config,
  }) {
    return PdfBarcodeDecoderPlatform.instance.decodePdf(
      pdfBytes: pdfBytes,
      config: config ?? const DecoderConfig(),
    );
  }

  /// Decodes barcodes from a PDF file on the filesystem.
  static Future<List<PdfBarcode>> decodeFile(
    File file, {
    DecoderConfig? config,
  }) {
    return PdfBarcodeDecoderPlatform.instance.decodePdf(
      filePath: file.absolute.path,
      config: config ?? const DecoderConfig(),
    );
  }

  /// Decodes barcodes from an asset bundled with the app.
  static Future<List<PdfBarcode>> decodeAsset(
    String assetPath, {
    DecoderConfig? config,
  }) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    return decode(bytes, config: config);
  }
}
