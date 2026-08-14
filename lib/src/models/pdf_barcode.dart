import 'dart:ui';
import '../enums/barcode_format.dart';

/// Represents a barcode detected within a PDF document.
class PdfBarcode {
  /// The format/symbology of the detected barcode.
  final BarcodeFormat type;

  /// The raw decoded string value of the barcode.
  final String value;

  /// The 0-indexed page number of the PDF document where this barcode was detected.
  final int page;

  /// The bounding box rectangle of the detected barcode in pixel coordinates
  /// corresponding to the page rendered at the configured DPI.
  final Rect boundingBox;

  /// Constructs a [PdfBarcode].
  const PdfBarcode({
    required this.type,
    required this.value,
    required this.page,
    required this.boundingBox,
  });

  /// Deserializes a [PdfBarcode] from a map received from the platform channel.
  factory PdfBarcode.fromMap(Map<Object?, Object?> map) {
    return PdfBarcode(
      type: BarcodeFormat.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => BarcodeFormat.all,
      ),
      value: map['value'] as String? ?? '',
      page: map['page'] as int? ?? 0,
      boundingBox: Rect.fromLTWH(
        (map['left'] as num?)?.toDouble() ?? 0.0,
        (map['top'] as num?)?.toDouble() ?? 0.0,
        (map['width'] as num?)?.toDouble() ?? 0.0,
        (map['height'] as num?)?.toDouble() ?? 0.0,
      ),
    );
  }

  /// Serializes the [PdfBarcode] into a map.
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'value': value,
      'page': page,
      'left': boundingBox.left,
      'top': boundingBox.top,
      'width': boundingBox.width,
      'height': boundingBox.height,
    };
  }
}
