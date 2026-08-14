import '../enums/barcode_format.dart';

/// Configuration options for PDF barcode scanning.
class DecoderConfig {
  /// The resolution (dots per inch) at which each PDF page is rendered before scanning.
  ///
  /// Higher DPI improves recognition for small or dense barcodes (e.g. PDF417 or small DataMatrix),
  /// but uses more memory and processing time.
  ///
  /// Defaults to `300`.
  final int dpi;

  /// Whether to only scan the first page of the PDF document.
  ///
  /// If `true`, subsequent pages are skipped.
  /// Defaults to `false`.
  final bool firstPageOnly;

  /// Whether to terminate scanning immediately once the first barcode is detected.
  ///
  /// Defaults to `false`.
  final bool stopAfterFirst;

  /// The maximum number of pages to scan from the beginning of the PDF.
  ///
  /// If `null`, all pages are scanned.
  final int? maxPages;

  /// The list of [BarcodeFormat] formats to detect.
  ///
  /// Defaults to `[BarcodeFormat.all]`.
  final List<BarcodeFormat> formats;

  /// Constructs a [DecoderConfig].
  const DecoderConfig({
    this.dpi = 300,
    this.firstPageOnly = false,
    this.stopAfterFirst = false,
    this.maxPages,
    this.formats = const [BarcodeFormat.all],
  });

  /// Serializes the configuration into a map for method channel communication.
  Map<String, dynamic> toMap() {
    return {
      'dpi': dpi,
      'firstPageOnly': firstPageOnly,
      'stopAfterFirst': stopAfterFirst,
      'maxPages': maxPages,
      'formats': formats.map((e) => e.toNativeString()).toList(),
    };
  }
}
