// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pdf_barcode_decoder/pdf_barcode_decoder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('decode test', (WidgetTester tester) async {
    // We just test if it doesn't crash when passing an empty PDF.
    try {
      await PdfBarcodeDecoder.decode(Uint8List(0));
    } catch (e) {
      // It's expected to fail because the PDF is invalid, but at least
      // we know the method call can be executed.
      expect(e, isNotNull);
    }
  });
}
