package com.pdfbarcode.pdf_barcode_decoder.renderer

import android.graphics.Bitmap
import android.graphics.pdf.PdfRenderer

interface PdfPageRenderer {
    fun renderPage(page: PdfRenderer.Page, dpi: Int): Bitmap
}
