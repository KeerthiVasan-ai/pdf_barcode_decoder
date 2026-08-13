import 'dart:ui';
import '../enums/barcode_format.dart';

class PdfBarcode {
  final BarcodeFormat type;
  final String value;
  final int page;
  final Rect boundingBox;

  const PdfBarcode({
    required this.type,
    required this.value,
    required this.page,
    required this.boundingBox,
  });

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
