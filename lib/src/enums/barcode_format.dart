/// The supported barcode formats for PDF scanning.
enum BarcodeFormat {
  /// QR Code 2D barcode format.
  qr,

  /// PDF417 2D stacked barcode format.
  pdf417,

  /// Aztec 2D barcode format.
  aztec,

  /// DataMatrix 2D barcode format.
  dataMatrix,

  /// Code 128 1D linear barcode format.
  code128,

  /// EAN-13 1D linear barcode format.
  ean13,

  /// EAN-8 1D linear barcode format.
  ean8,

  /// UPC (UPC-A and UPC-E) 1D linear barcode format.
  upc,

  /// Interleaved 2 of 5 (ITF) 1D linear barcode format.
  itf,

  /// Codabar 1D linear barcode format.
  codabar,

  /// All supported 1D and 2D barcode formats.
  all,
}

/// Extension methods for [BarcodeFormat].
extension BarcodeFormatExtension on BarcodeFormat {
  /// Converts the enum to a string that the native platforms expect.
  String toNativeString() {
    return name;
  }
}
