package com.pdfbarcode.pdf_barcode_decoder.scanner

import android.graphics.Bitmap

interface BarcodeScanner {
    fun scan(bitmap: Bitmap, formats: List<String>): List<RawBarcode>
}
