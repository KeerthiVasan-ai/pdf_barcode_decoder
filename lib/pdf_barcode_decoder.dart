import 'dart:io';
import 'package:flutter/services.dart';

import 'pdf_barcode_decoder_platform_interface.dart';
import 'src/models/decoder_config.dart';
import 'src/models/pdf_barcode.dart';

export 'src/enums/barcode_format.dart';
export 'src/exceptions/pdf_barcode_exception.dart';
export 'src/models/decoder_config.dart';
export 'src/models/pdf_barcode.dart';

/// Top-level interface for decoding barcodes from PDF documents.
///
/// Provides static methods to decode barcodes from in-memory bytes ([decode]),
/// filesystem files ([decodeFile]), or bundled Flutter assets ([decodeAsset]).
class PdfBarcodeDecoder {
  const PdfBarcodeDecoder._();

  /// Decodes barcodes from raw PDF bytes in memory.
  ///
  /// [pdfBytes] is the raw byte buffer of the PDF file.
  /// An optional [config] can be supplied to configure rendering DPI,
  /// barcode formats, page limits, and early termination.
  ///
  /// Returns a list of [PdfBarcode] instances discovered across scanned pages.
  static Future<List<PdfBarcode>> decode(
    Uint8List pdfBytes, {
    DecoderConfig? config,
  }) {
    return PdfBarcodeDecoderPlatform.instance.decodePdf(
      pdfBytes: pdfBytes,
      config: config ?? const DecoderConfig(),
    );
  }

  /// Decodes barcodes from a PDF [file] on the filesystem.
  ///
  /// An optional [config] can be supplied to configure rendering DPI,
  /// barcode formats, page limits, and early termination.
  ///
  /// Returns a list of [PdfBarcode] instances discovered across scanned pages.
  static Future<List<PdfBarcode>> decodeFile(
    File file, {
    DecoderConfig? config,
  }) {
    return PdfBarcodeDecoderPlatform.instance.decodePdf(
      filePath: file.absolute.path,
      config: config ?? const DecoderConfig(),
    );
  }

  /// Decodes barcodes from an asset bundled with the Flutter application.
  ///
  /// [assetPath] is the relative path to the asset as specified in `pubspec.yaml`
  /// (e.g. `'assets/sample.pdf'`).
  /// An optional [config] can be supplied to configure rendering DPI,
  /// barcode formats, page limits, and early termination.
  ///
  /// Returns a list of [PdfBarcode] instances discovered across scanned pages.
  static Future<List<PdfBarcode>> decodeAsset(
    String assetPath, {
    DecoderConfig? config,
  }) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    return decode(bytes, config: config);
  }
}
