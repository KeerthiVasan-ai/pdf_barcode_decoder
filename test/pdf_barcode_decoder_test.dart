import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_barcode_decoder/pdf_barcode_decoder.dart';
import 'package:pdf_barcode_decoder/pdf_barcode_decoder_platform_interface.dart';
import 'package:pdf_barcode_decoder/pdf_barcode_decoder_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPdfBarcodeDecoderPlatform
    with MockPlatformInterfaceMixin
    implements PdfBarcodeDecoderPlatform {
  @override
  Future<List<PdfBarcode>> decodePdf({
    String? filePath,
    Uint8List? pdfBytes,
    required DecoderConfig config,
  }) async {
    return [
      PdfBarcode(
        type: BarcodeFormat.qr,
        value: '42',
        page: 0,
        boundingBox: const Rect.fromLTWH(0, 0, 10, 10),
      ),
    ];
  }
}

void main() {
  final PdfBarcodeDecoderPlatform initialPlatform =
      PdfBarcodeDecoderPlatform.instance;

  test('$MethodChannelPdfBarcodeDecoder is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPdfBarcodeDecoder>());
  });

  test('decode', () async {
    MockPdfBarcodeDecoderPlatform fakePlatform =
        MockPdfBarcodeDecoderPlatform();
    PdfBarcodeDecoderPlatform.instance = fakePlatform;

    final result = await PdfBarcodeDecoder.decode(Uint8List(0));
    expect(result.first.value, '42');
  });
}
