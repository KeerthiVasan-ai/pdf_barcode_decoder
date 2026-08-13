# pdf_barcode_decoder

A Flutter plugin package that decodes barcodes (QR, PDF417, Aztec, DataMatrix, Code128, EAN, UPC, etc.) directly from PDF files. The package renders PDF pages natively (Android `PdfRenderer` / iOS `PDFKit`) and scans each rendered bitmap with a barcode engine (ZXing on Android, Vision Framework on iOS).

## Features

- Scans barcodes directly from PDF files (`File`), raw bytes (`Uint8List`), or bundled assets (`rootBundle`).
- Supports scanning multiple barcodes on a single page.
- Configurable DPI, page limits, and early termination (`stopAfterFirst`).
- Uses native, lightweight barcode engines (ZXing Core on Android, Vision Framework on iOS). No ML Kit dependency. No Google Play Services required.

## Installation

```yaml
dependencies:
  pdf_barcode_decoder: ^0.0.1
```

## Usage

```dart
import 'package:pdf_barcode_decoder/pdf_barcode_decoder.dart';

// From a file
final barcodes = await PdfBarcodeDecoder.decodeFile(File(path));

// From raw bytes
final barcodes = await PdfBarcodeDecoder.decode(pdfBytes);

// With configuration
final barcodes = await PdfBarcodeDecoder.decodeAsset(
  'assets/sample.pdf',
  config: DecoderConfig(
    dpi: 300,
    firstPageOnly: false,
    stopAfterFirst: true,
    maxPages: 5,
    formats: [BarcodeFormat.qr, BarcodeFormat.pdf417],
  ),
);

for (final barcode in barcodes) {
  print('Type: ${barcode.type.name}');
  print('Value: ${barcode.value}');
  print('Page: ${barcode.page}');
  print('Bounding Box: ${barcode.boundingBox}');
}
```

## Configuration

| Parameter | Type | Default | Description |
|---|---|---|---|
| `dpi` | `int` | `300` | The resolution at which the PDF page is rendered before scanning. Higher DPI increases accuracy but uses more memory and time. |
| `firstPageOnly` | `bool` | `false` | If true, only scans the first page of the PDF. |
| `stopAfterFirst` | `bool` | `false` | If true, stops scanning immediately after finding the first barcode (on any page). |
| `maxPages` | `int?` | `null` | Maximum number of pages to scan. If null, scans all pages. |
| `formats` | `List<BarcodeFormat>`| `[BarcodeFormat.all]` | Restrict scanning to specific barcode formats. |
