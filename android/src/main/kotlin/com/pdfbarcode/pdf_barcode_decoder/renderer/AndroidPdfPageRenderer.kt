package com.pdfbarcode.pdf_barcode_decoder.renderer

import android.graphics.Bitmap
import android.graphics.Color
import android.graphics.pdf.PdfRenderer

class AndroidPdfPageRenderer : PdfPageRenderer {
    override fun renderPage(page: PdfRenderer.Page, dpi: Int): Bitmap {
        // PDF point is 1/72 of an inch
        val scale = dpi / 72f
        val width = (page.width * scale).toInt()
        val height = (page.height * scale).toInt()

        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        
        // PdfRenderer renders transparent background by default.
        // Barcodes typically need a white background to be read correctly.
        bitmap.eraseColor(Color.WHITE)
        
        page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
        
        return bitmap
    }
}
