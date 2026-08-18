# Changelog

## 0.0.2

* **iOS Fixes**:
  * Fixed iOS native PDF rendering by replacing `PDFPage.thumbnail()` with `UIGraphicsImageRenderer` / CoreGraphics rasterization for full-fidelity decoding at target DPI.
  * Corrected Y-axis coordinate system transformation and handled non-zero `mediaBox` origin offsets during rendering.
  * Fixed MethodChannel `decodePdf` method handling in `SwiftPdfBarcodeDecoderPlugin` to resolve runtime casting exceptions.
  * Fixed Vision barcode scanner bounding box coordinate calculations against actual pixel dimensions.
  * Removed redundant plugin class implementation.
* **Example Application**:
  * Configured iOS Podfile and project settings for the example runner.

## 0.0.1

* Initial release of `pdf_barcode_decoder`.
* Decode 1D and 2D barcodes directly from PDF files (`File`), in-memory bytes (`Uint8List`), and Flutter app assets (`rootBundle`).
* Native PDF rendering using Android `PdfRenderer` and iOS `PDFKit`.
* Native barcode scanning using ZXing Core on Android and Apple Vision Framework on iOS.
* Zero Google Play Services / ML Kit dependencies.
* Multi-barcode detection per page with IoU-based deduplication.
* Configurable rendering resolution (DPI), page limits (`maxPages`, `firstPageOnly`), early stopping (`stopAfterFirst`), and format filters (`BarcodeFormat`).
* Comprehensive test suite and example application.
