package com.pdfbarcode.pdf_barcode_decoder.scanner

data class RawBarcode(
    val type: String,
    val value: String,
    val left: Double,
    val top: Double,
    val width: Double,
    val height: Double
)
