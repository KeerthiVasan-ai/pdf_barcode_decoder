import '../enums/barcode_format.dart';

class DecoderConfig {
  final int dpi;
  final bool firstPageOnly;
  final bool stopAfterFirst;
  final int? maxPages;
  final List<BarcodeFormat> formats;

  const DecoderConfig({
    this.dpi = 300,
    this.firstPageOnly = false,
    this.stopAfterFirst = false,
    this.maxPages,
    this.formats = const [BarcodeFormat.all],
  });

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
