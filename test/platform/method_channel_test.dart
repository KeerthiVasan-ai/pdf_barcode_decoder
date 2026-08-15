import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_barcode_decoder/pdf_barcode_decoder_method_channel.dart';
import 'package:pdf_barcode_decoder/src/models/decoder_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final channel = MethodChannelPdfBarcodeDecoder();
  final log = <MethodCall>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel.methodChannel, (
          MethodCall methodCall,
        ) async {
          log.add(methodCall);
          if (methodCall.method == 'decodePdf') {
            return [
              {
                'type': 'qr',
                'value': '123',
                'page': 0,
                'left': 0.0,
                'top': 0.0,
                'width': 10.0,
                'height': 10.0,
              },
            ];
          }
          return null;
        });
  });

  tearDown(() {
    log.clear();
  });

  test('decodePdf sends correct arguments and parses result', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final barcodes = await channel.decodePdf(
      pdfBytes: bytes,
      config: const DecoderConfig(dpi: 200),
    );

    expect(log.length, 1);
    expect(log.first.method, 'decodePdf');
    final args = log.first.arguments as Map<Object?, Object?>;
    expect(args['pdfBytes'], bytes);

    final configMap = args['config'] as Map;
    expect(configMap['dpi'], 200);

    expect(barcodes.length, 1);
    expect(barcodes.first.value, '123');
  });
}
