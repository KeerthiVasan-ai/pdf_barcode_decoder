<div align="center">

# PDF Barcode Decoder

**A fast, lightweight, and offline Flutter plugin to scan and decode 1D & 2D barcodes directly from PDF files and raw bytes.**

<p align="center">
  <a href="https://pub.dev/packages/pdf_barcode_decoder"><img src="https://img.shields.io/pub/v/pdf_barcode_decoder.svg?logo=dart&color=0175C2" alt="Pub Version" /></a>
  <a href="https://pub.dev/packages/pdf_barcode_decoder/score"><img src="https://img.shields.io/pub/points/pdf_barcode_decoder?color=2E8B57" alt="Pub Points" /></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.3+-02569B?logo=flutter&logoColor=white" alt="Flutter" /></a>
  <a href="https://developer.android.com"><img src="https://img.shields.io/badge/Android-API%2021+-3DDC84?logo=android&logoColor=white" alt="Android" /></a>
  <a href="https://developer.apple.com/ios/"><img src="https://img.shields.io/badge/iOS-13.0+-000000?logo=apple&logoColor=white" alt="iOS" /></a>
  <a href="https://github.com/KeerthiVasan-ai/pdf_barcode_decoder/pulls"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome" /></a>
  <a href="https://opensource.org/licenses/BSD-3-Clause"><img src="https://img.shields.io/badge/License-BSD--3--Clause-blue.svg" alt="License" /></a>
</p>

</div>

---

Under the hood, `pdf_barcode_decoder` renders PDF pages natively using **Android `PdfRenderer`** and **Apple iOS `PDFKit`**, then extracts barcodes using native, high-performance engines (**ZXing Core** on Android and **Apple Vision Framework** on iOS).

---

## 🚀 Key Features

- ⚡ **Zero External Cloud/Network Dependencies** — 100% offline, private, and on-device.
- 🪶 **Lightweight & Clean** — Zero Google Play Services, ML Kit, or Firebase dependencies.
- 📄 **Multiple Input Sources** — Decode directly from `File`, in-memory `Uint8List`, or bundled asset paths.
- 🎯 **Multi-Barcode Detection** — Detects multiple barcodes on the same page with IoU-based deduplication.
- 📐 **Precise Bounding Boxes** — Returns exact pixel coordinates (`Rect`) for bounding overlays and region cropping.
- ⚙️ **Configurable Pipeline** — Control rendering resolution (DPI), page ranges (`maxPages`, `firstPageOnly`), early stopping (`stopAfterFirst`), and barcode format filters.
- 🔒 **Android 15 (16KB Page Size) Ready** — Pure Java/Kotlin implementation without problematic C/C++ native binaries.

---

## 📱 Platform Support

| Platform | Minimum OS Version | PDF Renderer | Barcode Engine | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Android** | Android 5.0 (API 21+) | `android.graphics.pdf.PdfRenderer` | ZXing `core:3.5.4` | No Google Play Services required |
| **iOS** | iOS 13.0+ | `PDFKit` (`PDFDocument`) | `Vision.framework` (`VNDetectBarcodesRequest`) | System framework, zero CocoaPods dependencies |

---

## 📦 Supported Barcode Formats

| Format Enum | Symbology / Barcode Type | Android (ZXing) | iOS (Vision) |
| :--- | :--- | :---: | :---: |
| `BarcodeFormat.qr` | QR Code | ✅ | ✅ |
| `BarcodeFormat.pdf417` | PDF417 | ✅ | ✅ |
| `BarcodeFormat.aztec` | Aztec Code | ✅ | ✅ |
| `BarcodeFormat.dataMatrix` | DataMatrix | ✅ | ✅ |
| `BarcodeFormat.code128` | Code 128 | ✅ | ✅ |
| `BarcodeFormat.ean13` | EAN-13 | ✅ | ✅ |
| `BarcodeFormat.ean8` | EAN-8 | ✅ | ✅ |
| `BarcodeFormat.upc` | UPC-A & UPC-E | ✅ | ✅ |
| `BarcodeFormat.itf` | Interleaved 2 of 5 (ITF) | ✅ | ✅ |
| `BarcodeFormat.codabar` | Codabar | ✅ | ✅ |
| `BarcodeFormat.all` | All supported formats | ✅ | ✅ |

---

## 🏗️ Architecture & How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Application                      │
│   PdfBarcodeDecoder.decode() / decodeFile() / decodeAsset()  │
└──────────────────────────────┬──────────────────────────────┘
                               │
                      Method Channel (decodePdf)
                               │
            ┌──────────────────┴──────────────────┐
            ▼                                     ▼
┌───────────────────────┐             ┌───────────────────────┐
│     Android Host      │             │       iOS Host        │
│  (PdfDecodeManager)   │             │  (PdfDecodeManager)   │
├───────────────────────┤             ├───────────────────────┤
│ 1. PdfRenderer        │             │ 1. PDFKit             │
│    (Render at DPI)    │             │    (Render at DPI)    │
│ 2. ZXing Core         │             │ 2. Vision Framework   │
│    (MultiFormatReader)│             │    (DetectBarcodes)   │
│ 3. IoU Deduplication  │             │ 3. Coordinate Scaling │
└───────────┬───────────┘             └───────────┬───────────┘
            │                                     │
            └──────────────────┬──────────────────┘
                               ▼
              List<PdfBarcode> (with Page & Rect)
```

---

## 📥 Getting Started

Add `pdf_barcode_decoder` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  pdf_barcode_decoder: ^0.0.1
```

Or run:

```bash
flutter pub add pdf_barcode_decoder
```

---

## 💡 Usage Examples

### 1. Decode from a File (e.g. from `file_picker` or camera capture)

```dart
import 'dart:io';
import 'package:pdf_barcode_decoder/pdf_barcode_decoder.dart';

Future<void> scanPdfFile(String filePath) async {
  final file = File(filePath);

  final List<PdfBarcode> barcodes = await PdfBarcodeDecoder.decodeFile(file);

  for (final barcode in barcodes) {
    print('Found ${barcode.type.name} on Page ${barcode.page + 1}: ${barcode.value}');
    print('Bounding box: ${barcode.boundingBox}');
  }
}
```

### 2. Decode from In-Memory Bytes (e.g. downloaded over HTTP)

```dart
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf_barcode_decoder/pdf_barcode_decoder.dart';

Future<void> scanPdfFromUrl(String url) async {
  final response = await http.get(Uri.parse(url));
  final Uint8List pdfBytes = response.bodyBytes;

  final List<PdfBarcode> barcodes = await PdfBarcodeDecoder.decode(pdfBytes);
  print('Found ${barcodes.length} barcode(s) in downloaded PDF.');
}
```

### 3. Decode from Bundled App Asset

```dart
import 'package:pdf_barcode_decoder/pdf_barcode_decoder.dart';

Future<void> scanBundledPdf() async {
  final List<PdfBarcode> barcodes = await PdfBarcodeDecoder.decodeAsset(
    'assets/invoices/sample_invoice.pdf',
  );

  for (final b in barcodes) {
    print('Barcode value: ${b.value}');
  }
}
```

### 4. Advanced Configuration

Fine-tune rendering quality, filter specific formats, scan only specific pages, or exit early:

```dart
import 'dart:io';
import 'package:pdf_barcode_decoder/pdf_barcode_decoder.dart';

final barcodes = await PdfBarcodeDecoder.decodeFile(
  File('/path/to/shipping_label.pdf'),
  config: const DecoderConfig(
    // Rendering resolution (higher DPI = better recognition of small/dense barcodes)
    dpi: 300,

    // Scan only the first page
    firstPageOnly: false,

    // Exit immediately after finding the first barcode
    stopAfterFirst: true,

    // Scan up to the first 3 pages
    maxPages: 3,

    // Target specific barcode formats
    formats: [
      BarcodeFormat.qr,
      BarcodeFormat.pdf417,
      BarcodeFormat.code128,
    ],
  ),
);
```

### 5. Error Handling

All platform and rendering errors are wrapped in a typed `PdfBarcodeException`:

```dart
import 'dart:io';
import 'package:pdf_barcode_decoder/pdf_barcode_decoder.dart';

try {
  final barcodes = await PdfBarcodeDecoder.decodeFile(File('protected.pdf'));
} on PdfBarcodeException catch (e) {
  switch (e.code) {
    case 'ENCRYPTED_PDF':
      print('Password-protected PDFs cannot be scanned.');
      break;
    case 'INVALID_PDF':
      print('The provided file is corrupted or not a valid PDF.');
      break;
    case 'RENDER_FAILED':
      print('Failed to render PDF pages: ${e.message}');
      break;
    default:
      print('Decoding error [${e.code}]: ${e.message}');
  }
}
```

---

## 📖 API Reference

### `DecoderConfig`

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `dpi` | `int` | `300` | Resolution (DPI) at which PDF pages are rendered. Higher values improve detection on high-density 2D barcodes at the expense of memory. |
| `firstPageOnly` | `bool` | `false` | If `true`, only the first page (index `0`) of the PDF is scanned. |
| `stopAfterFirst` | `bool` | `false` | If `true`, scanning halts immediately as soon as at least one barcode is detected. |
| `maxPages` | `int?` | `null` | Maximum number of pages to scan from the start of the document. If `null`, all pages are scanned. |
| `formats` | `List<BarcodeFormat>` | `[BarcodeFormat.all]` | Restricts detection to specified symbologies. |

### `PdfBarcode`

| Property | Type | Description |
| :--- | :--- | :--- |
| `type` | `BarcodeFormat` | The detected barcode symbology (e.g. `BarcodeFormat.qr`, `BarcodeFormat.pdf417`). |
| `value` | `String` | The raw decoded string value of the barcode. |
| `page` | `int` | The 0-indexed page number where the barcode was found. |
| `boundingBox` | `Rect` | The bounding box coordinates (in pixel space at the configured render DPI) locating the barcode on the page. |

---

## ⚡ Performance & Best Practices

1. **Choosing the Optimal DPI**:
   - `150 DPI` — Fast; suitable for large standard QR codes and shipping label barcodes.
   - `300 DPI` (Default) — Recommended balance for crisp renders, PDF417 boarding passes, and multi-code documents.
   - `400+ DPI` — Use when barcodes are physically tiny or high-density DataMatrix codes.
2. **Page Limits**: For long documents (e.g., 50+ page invoices), always supply `maxPages` or `stopAfterFirst: true` if you only need the header barcode.
3. **Memory Management**: Both native Android and iOS engines recycle page bitmaps and autorelease pools after each page scan to ensure low memory footprints.

---

## 📱 Example App

Check the [`example/`](https://github.com/KeerthiVasan-ai/pdf_barcode_decoder/tree/main/example) folder for a complete sample Flutter app demonstrating PDF picking, asset scanning, and real-time result listing.

To run the example app:

```bash
cd example
flutter run
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/KeerthiVasan-ai/pdf_barcode_decoder/issues).

---

## 📄 License

This project is licensed under the **BSD 3-Clause License** - see the [LICENSE](LICENSE) file for details.
