/// The supported barcode formats.
enum BarcodeFormat {
  qr,
  pdf417,
  aztec,
  dataMatrix,
  code128,
  ean13,
  ean8,
  upc,
  itf,
  codabar,
  all,
}

extension BarcodeFormatExtension on BarcodeFormat {
  /// Converts the enum to a string that the native platforms expect.
  String toNativeString() {
    return name;
  }
}
