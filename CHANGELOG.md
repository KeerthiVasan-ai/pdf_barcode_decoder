# Changelog

## 0.0.1

* Initial release of `pdf_barcode_decoder`.
* Decode 1D and 2D barcodes directly from PDF files (`File`), in-memory bytes (`Uint8List`), and Flutter app assets (`rootBundle`).
* Native PDF rendering using Android `PdfRenderer` and iOS `PDFKit`.
* Native barcode scanning using ZXing Core on Android and Apple Vision Framework on iOS.
* Zero Google Play Services / ML Kit dependencies.
* Multi-barcode detection per page with IoU-based deduplication.
* Configurable rendering resolution (DPI), page limits (`maxPages`, `firstPageOnly`), early stopping (`stopAfterFirst`), and format filters (`BarcodeFormat`).
* Comprehensive test suite and example application.
