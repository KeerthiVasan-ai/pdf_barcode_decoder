package com.pdfbarcode.pdf_barcode_decoder.scanner

import android.graphics.Bitmap
import com.google.zxing.*
import com.google.zxing.common.HybridBinarizer
import com.google.zxing.multi.GenericMultipleBarcodeReader
import java.util.*
import kotlin.math.max

class ZXingBarcodeScanner : BarcodeScanner {
    override fun scan(bitmap: Bitmap, formats: List<String>): List<RawBarcode> {
        val width = bitmap.width
        val height = bitmap.height
        val pixels = IntArray(width * height)
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height)

        val source = RGBLuminanceSource(width, height, pixels)
        val binaryBitmap = BinaryBitmap(HybridBinarizer(source))

        val zxingFormats = mapFormats(formats)
        val hints = EnumMap<DecodeHintType, Any>(DecodeHintType::class.java)
        hints[DecodeHintType.TRY_HARDER] = true
        if (zxingFormats.isNotEmpty()) {
            hints[DecodeHintType.POSSIBLE_FORMATS] = zxingFormats
        }

        val reader = GenericMultipleBarcodeReader(MultiFormatReader())
        val rawResults = try {
            reader.decodeMultiple(binaryBitmap, hints)
        } catch (e: NotFoundException) {
            emptyArray<Result>()
        } catch (e: Exception) {
            emptyArray<Result>()
        }

        return rawResults?.map { result ->
            val points = result.resultPoints
            var left = width.toDouble()
            var top = height.toDouble()
            var right = 0.0
            var bottom = 0.0

            if (points != null && points.isNotEmpty()) {
                for (p in points) {
                    if (p.x < left) left = p.x.toDouble()
                    if (p.y < top) top = p.y.toDouble()
                    if (p.x > right) right = p.x.toDouble()
                    if (p.y > bottom) bottom = p.y.toDouble()
                }
            } else {
                left = 0.0
                top = 0.0
                right = 0.0
                bottom = 0.0
            }
            
            val w = max(right - left, 1.0)
            val h = max(bottom - top, 1.0)

            RawBarcode(
                type = mapResultFormat(result.barcodeFormat),
                value = result.text ?: "",
                left = left,
                top = top,
                width = w,
                height = h
            )
        } ?: emptyList()
    }

    private fun mapFormats(formats: List<String>): List<BarcodeFormat> {
        if (formats.contains("all")) {
            return emptyList()
        }
        val result = mutableListOf<BarcodeFormat>()
        for (f in formats) {
            when (f) {
                "qr" -> result.add(BarcodeFormat.QR_CODE)
                "pdf417" -> result.add(BarcodeFormat.PDF_417)
                "aztec" -> result.add(BarcodeFormat.AZTEC)
                "dataMatrix" -> result.add(BarcodeFormat.DATA_MATRIX)
                "code128" -> result.add(BarcodeFormat.CODE_128)
                "ean13" -> result.add(BarcodeFormat.EAN_13)
                "ean8" -> result.add(BarcodeFormat.EAN_8)
                "upc" -> result.add(BarcodeFormat.UPC_A)
                "itf" -> result.add(BarcodeFormat.ITF)
                "codabar" -> result.add(BarcodeFormat.CODABAR)
            }
        }
        return result
    }

    private fun mapResultFormat(format: BarcodeFormat): String {
        return when (format) {
            BarcodeFormat.QR_CODE -> "qr"
            BarcodeFormat.PDF_417 -> "pdf417"
            BarcodeFormat.AZTEC -> "aztec"
            BarcodeFormat.DATA_MATRIX -> "dataMatrix"
            BarcodeFormat.CODE_128 -> "code128"
            BarcodeFormat.EAN_13 -> "ean13"
            BarcodeFormat.EAN_8 -> "ean8"
            BarcodeFormat.UPC_A -> "upc"
            BarcodeFormat.ITF -> "itf"
            BarcodeFormat.CODABAR -> "codabar"
            else -> "unknown"
        }
    }
}
