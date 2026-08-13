# `pdf_barcode_decoder` — Final Implementation Plan

## All Design Decisions Locked ✅

| Decision | Choice | Reason |
|---|---|---|
| Android minSdk | **21** | PdfRenderer + ZXing both work from API 21 |
| iOS min version | **13** | Vision + PDFKit, covers ~99% of active devices |
| Android barcode engine | **ZXing `core` only** | Pure Java → 16KB compliant, no Play Services, sufficient for clean PDF renders |
| iOS barcode engine | **Vision Framework** | Native, no pods, available since iOS 11 |
| Multi-barcode strategy | **Multi from day 1** | `List<PdfBarcode>` API handles 1 or N barcodes identically, no breaking change later |
| `stopAfterFirst` | **Included in `DecoderConfig`** | Covers "find first and stop" use case without API change |
| Asset loading | **Dart-side `rootBundle`** | Simplifies native code, only `decodeFile` reaches platform channel |
| Bounding box space | **Page pixels at render DPI** | Directly usable for overlay drawing on rendered page |
| Deduplication | **IoU > 50% = duplicate** | Removes ZXing recursive scan duplicates, preserves genuinely close barcodes |

---

## Overview

A Flutter plugin package that decodes barcodes (QR, PDF417, Aztec, DataMatrix, Code128, EAN, UPC, etc.) directly from PDF files. The package renders PDF pages natively (Android `PdfRenderer` / iOS `PDFKit`) and scans each rendered bitmap with a barcode engine (ZXing on Android, Vision Framework on iOS) using `GenericMultipleBarcodeReader` for reliable multi-barcode detection per page.

---

## Architecture

```
Flutter (Public API)
      │
      ▼
 MethodChannel  ◄──── DecoderConfig (serialized as Map)
      │
      ▼
Native Platform
  ┌───────────────────────────────────────────────┐
  │  PdfPageRenderer  (interface/protocol)        │
  │    └─ AndroidPdfPageRenderer  (PdfRenderer)   │
  │    └─ IosPdfPageRenderer      (PDFKit)         │
  │                                               │
  │  BarcodeScanner   (interface/protocol)        │
  │    └─ ZXingBarcodeScanner     (Android)        │
  │    └─ VisionBarcodeScanner    (iOS)            │
  │                                               │
  │  PdfDecodeManager (orchestrator)              │
  │    1. Write bytes → temp file                 │
  │    2. Open PDF                                │
  │    3. Loop pages (respecting config)          │
  │    4. Render page → Bitmap/UIImage            │
  │    5. Scan → raw results                      │
  │    6. IoU deduplication                       │
  │    7. Dispose bitmap                          │
  │    8. Cleanup temp file                       │
  │    9. Return List<Map>                        │
  └───────────────────────────────────────────────┘
```

---

## Public API

```dart
// Primary — file from file_picker or native share sheet
final barcodes = await PdfBarcodeDecoder.decodeFile(File(path));

// From raw bytes
final barcodes = await PdfBarcodeDecoder.decode(pdfBytes);

// From bundled app asset (loaded in Dart via rootBundle)
final barcodes = await PdfBarcodeDecoder.decodeAsset('assets/sample.pdf');

// With config
final barcodes = await PdfBarcodeDecoder.decodeFile(
  File(path),
  config: DecoderConfig(
    dpi: 300,
    firstPageOnly: false,
    stopAfterFirst: false,
    maxPages: 5,
    formats: [BarcodeFormat.qr, BarcodeFormat.pdf417],
  ),
);
```

---

## Proposed Changes

### 1. Package Scaffold

#### [NEW] `pubspec.yaml`
- Package name: `pdf_barcode_decoder`
- Flutter plugin with `android` + `ios` platform entries
- Dart dependency: `plugin_platform_interface`
- No Android/iOS pod dependencies (ZXing via Gradle, Vision/PDFKit are system frameworks)

#### [NEW] `analysis_options.yaml`
- `package:flutter_lints` strict ruleset

---

### 2. Flutter Layer (`lib/`)

#### [NEW] `lib/pdf_barcode_decoder.dart`
```dart
class PdfBarcodeDecoder {
  static Future<List<PdfBarcode>> decode(Uint8List pdfBytes, {DecoderConfig? config})
  static Future<List<PdfBarcode>> decodeFile(File file, {DecoderConfig? config})
  static Future<List<PdfBarcode>> decodeAsset(String assetPath, {DecoderConfig? config})
  // decodeAsset → rootBundle.load() → calls decode()
}
```

#### [NEW] `lib/src/enums/barcode_format.dart`
```dart
enum BarcodeFormat {
  qr, pdf417, aztec, dataMatrix,
  code128, ean13, ean8, upc, itf, codabar, all
}
// + toNativeString() extension
```

#### [NEW] `lib/src/models/pdf_barcode.dart`
```dart
class PdfBarcode {
  final BarcodeFormat type;
  final String value;
  final int page;           // 0-indexed
  final Rect boundingBox;   // pixels at render DPI
  // fromMap() factory
}
```

#### [NEW] `lib/src/models/decoder_config.dart`
```dart
class DecoderConfig {
  final int dpi;                       // default: 300
  final bool firstPageOnly;            // default: false
  final bool stopAfterFirst;           // default: false
  final int? maxPages;                 // default: null (all pages)
  final List<BarcodeFormat> formats;   // default: [BarcodeFormat.all]
  // toMap() serializer
}
```

#### [NEW] `lib/src/exceptions/pdf_barcode_exception.dart`
```dart
class PdfBarcodeException implements Exception {
  final String code;     // 'INVALID_PDF' | 'ENCRYPTED_PDF' | 'RENDER_FAILED' | 'PLATFORM_UNAVAILABLE'
  final String message;
}
```

#### [NEW] `lib/src/platform/pdf_barcode_decoder_platform.dart`
Abstract platform interface using `plugin_platform_interface`.

#### [NEW] `lib/src/platform/method_channel.dart`
`PdfBarcodeDecoderMethodChannel` — handles `PlatformException` → typed `PdfBarcodeException`.

---

### 3. Android Implementation (`android/`)

#### [NEW] `android/build.gradle`
```groovy
dependencies {
  implementation 'com.google.zxing:core:3.5.4'
  // No ML Kit. No other native deps.
}
```

#### [NEW] `PdfBarcodeDecoderPlugin.kt`
Registers plugin, receives `MethodCall("decodePdf")`, dispatches to `PdfDecodeManager` on a background coroutine.

#### [NEW] `PdfDecodeManager.kt`
Orchestrator:
1. Write `bytes` → `cacheDir/pdf_bc_<uuid>.pdf`
2. `PdfRenderer(ParcelFileDescriptor)` to open PDF
3. Loop pages (respecting `maxPages`, `firstPageOnly`)
4. `AndroidPdfPageRenderer.renderPage()` → `Bitmap`
5. `ZXingBarcodeScanner.scan(bitmap, formats)` → raw results
6. IoU deduplication on raw results
7. If `stopAfterFirst` and results non-empty → break loop
8. `bitmap.recycle()` after each page
9. Close `PdfRenderer`, delete temp file
10. Return `List<Map<String, Any>>`

#### [NEW] `renderer/PdfPageRenderer.kt` (interface)
```kotlin
interface PdfPageRenderer {
  fun renderPage(page: PdfRenderer.Page, dpi: Int): Bitmap
}
```

#### [NEW] `renderer/AndroidPdfPageRenderer.kt`
- Calculates pixel dimensions: `page.width * (dpi / 72f)`
- Renders with `RENDER_MODE_FOR_DISPLAY`
- Returns `Bitmap.Config.ARGB_8888`

#### [NEW] `scanner/BarcodeScanner.kt` (interface)
```kotlin
interface BarcodeScanner {
  fun scan(bitmap: Bitmap, formats: List<String>): List<RawBarcode>
}
```

#### [NEW] `scanner/ZXingBarcodeScanner.kt`
- `RGBLuminanceSource` from Bitmap pixels
- `BinaryBitmap(HybridBinarizer(source))`
- `GenericMultipleBarcodeReader(MultiFormatReader())` with `TRY_HARDER` hint
- `decodeMultiple(binaryBitmap, hints)` → `Array<Result>`
- Map `ResultPoint[]` → bounding box (min/max of corner points)
- Return `List<RawBarcode>(value, format, left, top, width, height)`

#### [NEW] `scanner/IouDeduplicator.kt`
```kotlin
// IoU > 0.5 → same barcode, keep first occurrence
fun deduplicate(results: List<RawBarcode>): List<RawBarcode>
```

---

### 4. iOS Implementation (`ios/`)

#### [NEW] `ios/pdf_barcode_decoder.podspec`
- `s.ios.deployment_target = '13.0'`
- `s.frameworks = 'PDFKit', 'Vision'`
- No external pod dependencies

#### [NEW] `PdfBarcodeDecoderPlugin.swift`
Registers plugin, receives `FlutterMethodCall("decodePdf")`, dispatches to `PdfDecodeManager` on `DispatchQueue.global()`.

#### [NEW] `PdfDecodeManager.swift`
Mirrors Android orchestrator — writes temp file, opens `PDFDocument`, loops `PDFPage`s, renders, scans, deduplicates (Vision doesn't duplicate, so minimal dedup needed), cleans up.

#### [NEW] `PdfKitPageRenderer.swift`
```swift
protocol PdfPageRenderer {
  func renderPage(_ page: PDFPage, dpi: Int) -> UIImage?
}
// Implementation: PDFPage.thumbnail(of: pixelSize, for: .mediaBox)
```

#### [NEW] `VisionBarcodeScanner.swift`
```swift
protocol BarcodeScanner {
  func scan(image: UIImage, formats: [String]) -> [[String: Any]]
}
// VNDetectBarcodesRequest with VNBarcodeSymbology filter
// VNBarcodeObservation.boundingBox (normalized) → scale to pixel space
// → {type, value, left, top, width, height}
```

---

### 5. Multi-Barcode Flow (both platforms)

```
Page Bitmap
    │
    ▼
GenericMultipleBarcodeReader / VNDetectBarcodesRequest
    │
    ▼
Raw results: [A, B, A(dup), C]    ← ZXing may duplicate
    │
    ▼
IoU deduplication (>50% overlap = same)
    │
    ▼
[A, B, C]  ← clean list, each with own value + boundingBox
    │
    ▼  (if stopAfterFirst == true → take first, break page loop)
    ▼
Append to page results with page index
```

---

### 6. Example App (`example/`)

#### [NEW] `example/lib/main.dart`
- **Pick PDF** → `file_picker` → `decodeFile()`
- **Loading spinner** during decode
- **Results list**: `Page N | TYPE | value`
- Tapping a result shows bounding box overlay on a rendered page thumbnail
- **Error snackbar** for `PdfBarcodeException`

#### [NEW] `example/assets/`
- `sample_qr.pdf` — single QR
- `sample_multi_qr.pdf` — 3 QR codes on one page
- `sample_pdf417.pdf` — PDF417 barcode
- `sample_multipage.pdf` — barcodes on pages 1, 3, 5

---

### 7. Tests

#### [NEW] `test/models/pdf_barcode_test.dart`
- `PdfBarcode.fromMap` / `toMap` round-trip
- `DecoderConfig.toMap` round-trip
- `PdfBarcodeException` code mapping

#### [NEW] `test/enums/barcode_format_test.dart`
- `toNativeString()` for all enum values

#### [NEW] `test/platform/method_channel_test.dart`
- Mock channel → assert correct argument serialization
- Assert response deserialization → correct `PdfBarcode` list

#### [NEW] `integration_test/decode_test.dart`
| Scenario | Expected |
|---|---|
| Single QR PDF | 1 result, correct value |
| 3 QR on one page | 3 results, distinct bounding boxes |
| PDF417 PDF | 1 result, correct format enum |
| Multi-page PDF | `page` field correct per barcode |
| `firstPageOnly: true` | Only page 0 results |
| `stopAfterFirst: true` | Exactly 1 result |
| `maxPages: 2` | No results from page 3+ |
| Empty PDF (no barcodes) | Empty list, no exception |
| Encrypted PDF | `PdfBarcodeException(code: 'ENCRYPTED_PDF')` |
| Invalid file bytes | `PdfBarcodeException(code: 'INVALID_PDF')` |

---

### 8. Documentation

#### [NEW] `README.md`
Installation, usage, config table, error codes, platform support matrix.

#### [NEW] `CHANGELOG.md`
`## 0.1.0` — initial release.

#### [NEW] `LICENSE` — MIT

---

## Implementation Order

| Step | Task | Duration |
|------|------|----------|
| 1 | Package scaffold + pubspec + analysis_options | 0.5d |
| 2 | Dart enums, models, exceptions | 0.5d |
| 3 | Platform interface + method channel | 0.5d |
| 4 | Public API (`PdfBarcodeDecoder`) | 0.5d |
| 5 | Android: `PdfPageRenderer` + `AndroidPdfPageRenderer` | 0.5d |
| 6 | Android: `ZXingBarcodeScanner` + `IouDeduplicator` | 1d |
| 7 | Android: `PdfDecodeManager` + plugin wiring | 0.5d |
| 8 | iOS: `PdfKitPageRenderer` + `VisionBarcodeScanner` | 1.5d |
| 9 | iOS: `PdfDecodeManager` + plugin wiring + podspec | 0.5d |
| 10 | Example app + sample PDFs | 1d |
| 11 | Unit + integration tests | 2d |
| 12 | README + CHANGELOG + `dart pub publish --dry-run` | 0.5d |
| **Total** | | **~9.5d** |

---

## Verification Plan

### Automated
```bash
flutter analyze
flutter test
flutter test integration_test/ -d <android-device>
flutter test integration_test/ -d <ios-device>
dart pub publish --dry-run
```

### Manual
- File picker → real-world QR PDF → verify decode on physical Android + iPhone
- PDF with 3 QR codes → verify all 3 returned with correct bounding boxes
- Password-encrypted PDF → verify `PdfBarcodeException` shown in example app UI
- 50-page PDF → memory profiler → confirm no bitmap leaks
- Android 15 device/emulator → confirm no 16KB page size crash (ZXing = pure Java, zero risk)
