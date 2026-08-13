package com.pdfbarcode.pdf_barcode_decoder.scanner

import kotlin.math.max
import kotlin.math.min

object IouDeduplicator {
    fun deduplicate(results: List<RawBarcode>): List<RawBarcode> {
        val keep = mutableListOf<RawBarcode>()
        for (barcode in results) {
            var isDuplicate = false
            for (existing in keep) {
                if (barcode.type == existing.type && barcode.value == existing.value) {
                    val iou = calculateIoU(barcode, existing)
                    if (iou > 0.5) {
                        isDuplicate = true
                        break
                    }
                }
            }
            if (!isDuplicate) {
                keep.add(barcode)
            }
        }
        return keep
    }

    private fun calculateIoU(a: RawBarcode, b: RawBarcode): Double {
        val xA = max(a.left, b.left)
        val yA = max(a.top, b.top)
        val xB = min(a.left + a.width, b.left + b.width)
        val yB = min(a.top + a.height, b.top + b.height)

        val interArea = max(0.0, xB - xA) * max(0.0, yB - yA)
        val boxAArea = a.width * a.height
        val boxBArea = b.width * b.height

        val unionArea = boxAArea + boxBArea - interArea
        if (unionArea <= 0.0) return 0.0
        return interArea / unionArea
    }
}
