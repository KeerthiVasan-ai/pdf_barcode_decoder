import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_barcode_decoder/src/enums/barcode_format.dart';
import 'package:pdf_barcode_decoder/src/models/pdf_barcode.dart';
import 'package:pdf_barcode_decoder/src/models/decoder_config.dart';

void main() {
  test('PdfBarcode fromMap and toMap', () {
    final map = {
      'type': 'qr',
      'value': 'hello',
      'page': 1,
      'left': 10.0,
      'top': 20.0,
      'width': 30.0,
      'height': 40.0,
    };

    final barcode = PdfBarcode.fromMap(map);
    expect(barcode.type, BarcodeFormat.qr);
    expect(barcode.value, 'hello');
    expect(barcode.page, 1);
    expect(barcode.boundingBox, const Rect.fromLTWH(10, 20, 30, 40));

    final map2 = barcode.toMap();
    expect(map2['type'], 'qr');
    expect(map2['value'], 'hello');
    expect(map2['page'], 1);
    expect(map2['left'], 10.0);
  });

  test('DecoderConfig toMap', () {
    const config = DecoderConfig(
      dpi: 150,
      firstPageOnly: true,
      stopAfterFirst: true,
      maxPages: 2,
      formats: [BarcodeFormat.qr, BarcodeFormat.pdf417],
    );

    final map = config.toMap();
    expect(map['dpi'], 150);
    expect(map['firstPageOnly'], true);
    expect(map['stopAfterFirst'], true);
    expect(map['maxPages'], 2);
    expect(map['formats'], ['qr', 'pdf417']);
  });
}
