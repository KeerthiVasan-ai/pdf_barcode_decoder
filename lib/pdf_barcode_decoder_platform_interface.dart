import 'dart:typed_data';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'pdf_barcode_decoder_method_channel.dart';
import 'src/models/decoder_config.dart';
import 'src/models/pdf_barcode.dart';

/// The interface that platform-specific implementations of `pdf_barcode_decoder` must extend.
abstract class PdfBarcodeDecoderPlatform extends PlatformInterface {
  /// Constructs a PdfBarcodeDecoderPlatform.
  PdfBarcodeDecoderPlatform() : super(token: _token);

  static final Object _token = Object();

  static PdfBarcodeDecoderPlatform _instance = MethodChannelPdfBarcodeDecoder();

  /// The default instance of [PdfBarcodeDecoderPlatform] to use.
  ///
  /// Defaults to [MethodChannelPdfBarcodeDecoder].
  static PdfBarcodeDecoderPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PdfBarcodeDecoderPlatform] when
  /// they register themselves.
  static set instance(PdfBarcodeDecoderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Platform interface method to decode barcodes from either [filePath] or [pdfBytes].
  Future<List<PdfBarcode>> decodePdf({
    String? filePath,
    Uint8List? pdfBytes,
    required DecoderConfig config,
  }) {
    throw UnimplementedError('decodePdf() has not been implemented.');
  }
}
