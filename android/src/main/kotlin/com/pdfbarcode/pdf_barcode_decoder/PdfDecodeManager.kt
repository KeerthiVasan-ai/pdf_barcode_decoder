package com.pdfbarcode.pdf_barcode_decoder

import android.content.Context
import android.graphics.pdf.PdfRenderer
import android.os.ParcelFileDescriptor
import com.pdfbarcode.pdf_barcode_decoder.renderer.AndroidPdfPageRenderer
import com.pdfbarcode.pdf_barcode_decoder.scanner.IouDeduplicator
import com.pdfbarcode.pdf_barcode_decoder.scanner.ZXingBarcodeScanner
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

class PdfDecodeManager(private val context: Context) {

    fun decodePdf(
        pdfBytes: ByteArray?,
        filePath: String?,
        config: Map<String, Any?>
    ): List<Map<String, Any>> {
        val file = if (pdfBytes != null) {
            val tempFile = File(context.cacheDir, "pdf_bc_${UUID.randomUUID()}.pdf")
            FileOutputStream(tempFile).use { it.write(pdfBytes) }
            tempFile
        } else if (filePath != null) {
            File(filePath)
        } else {
            throw IllegalArgumentException("Either pdfBytes or filePath must be provided")
        }

        val renderer = AndroidPdfPageRenderer()
        val scanner = ZXingBarcodeScanner()
        val resultList = mutableListOf<Map<String, Any>>()

        try {
            val pfd = try {
                ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
            } catch (e: Exception) {
                throw Exception("INVALID_PDF: Could not open file")
            }
            
            val pdfRenderer = try {
                PdfRenderer(pfd)
            } catch (e: SecurityException) {
                throw Exception("ENCRYPTED_PDF: PDF is password protected")
            } catch (e: Exception) {
                throw Exception("INVALID_PDF: Invalid PDF format")
            }
            
            val pageCount = pdfRenderer.pageCount

            val dpi = (config["dpi"] as? Int) ?: 300
            val firstPageOnly = (config["firstPageOnly"] as? Boolean) ?: false
            val stopAfterFirst = (config["stopAfterFirst"] as? Boolean) ?: false
            val maxPages = (config["maxPages"] as? Int) ?: pageCount
            @Suppress("UNCHECKED_CAST")
            val formats = (config["formats"] as? List<String>) ?: listOf("all")

            val pagesToScan = if (firstPageOnly) 1 else minOf(pageCount, maxPages)

            for (i in 0 until pagesToScan) {
                val page = pdfRenderer.openPage(i)
                try {
                    val bitmap = renderer.renderPage(page, dpi)
                    val rawResults = scanner.scan(bitmap, formats)
                    bitmap.recycle()

                    val cleanResults = IouDeduplicator.deduplicate(rawResults)
                    for (barcode in cleanResults) {
                        resultList.add(
                            mapOf(
                                "type" to barcode.type,
                                "value" to barcode.value,
                                "page" to i,
                                "left" to barcode.left,
                                "top" to barcode.top,
                                "width" to barcode.width,
                                "height" to barcode.height
                            )
                        )
                    }

                    if (stopAfterFirst && resultList.isNotEmpty()) {
                        break
                    }
                } finally {
                    page.close()
                }
            }

            pdfRenderer.close()
            pfd.close()
        } finally {
            if (pdfBytes != null && file.exists()) {
                file.delete()
            }
        }

        return resultList
    }
}
