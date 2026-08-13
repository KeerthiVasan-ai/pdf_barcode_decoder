class PdfBarcodeException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  const PdfBarcodeException({
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'PdfBarcodeException($code): $message';
}
