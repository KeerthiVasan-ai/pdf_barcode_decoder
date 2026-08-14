/// Exception thrown when an error occurs during PDF barcode decoding.
class PdfBarcodeException implements Exception {
  /// The error code identifying the failure reason (e.g. `INVALID_PDF`, `ENCRYPTED_PDF`, `RENDER_FAILED`, `DECODE_ERROR`).
  final String code;

  /// A descriptive message describing the failure.
  final String message;

  /// Optional platform-specific error details.
  final dynamic details;

  /// Constructs a [PdfBarcodeException].
  const PdfBarcodeException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'PdfBarcodeException($code): $message';
}
