import Foundation
import PDFKit
import UIKit

protocol PdfPageRenderer {
    func renderPage(_ page: PDFPage, dpi: Int) -> UIImage?
}

class DefaultPdfPageRenderer: PdfPageRenderer {
    func renderPage(_ page: PDFPage, dpi: Int) -> UIImage? {
        let rect = page.bounds(for: .mediaBox)
        let scale = CGFloat(dpi) / 72.0
        let size = CGSize(width: rect.width * scale, height: rect.height * scale)

        guard size.width > 0, size.height > 0 else {
            print("[PdfRenderer] ERROR: Invalid page size: \(size)")
            return nil
        }

        print("[PdfRenderer] Page mediaBox: \(rect), rendering at \(Int(size.width))x\(Int(size.height)) px (DPI=\(dpi), scale=\(scale))")

        // Use UIGraphicsImageRenderer with scale=1.0 since we already computed pixel dimensions
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { context in
            let cgContext = context.cgContext

            // White background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // UIGraphicsImageRenderer uses UIKit coords (top-left origin).
            // PDFPage.draw() uses PDF coords (bottom-left origin).
            // We must flip the Y axis for correct rendering.
            cgContext.translateBy(x: 0, y: size.height)
            cgContext.scaleBy(x: 1.0, y: -1.0)

            // Apply DPI scaling
            cgContext.scaleBy(x: scale, y: scale)

            // Handle pages whose mediaBox origin is not (0,0)
            if rect.origin != .zero {
                cgContext.translateBy(x: -rect.origin.x, y: -rect.origin.y)
            }

            page.draw(with: .mediaBox, to: cgContext)
        }

        print("[PdfRenderer] Rendered image: \(image.size) scale=\(image.scale), cgImage=\(image.cgImage != nil ? "\(image.cgImage!.width)x\(image.cgImage!.height)" : "nil")")

        // Debug: save to tmp so we can verify rendering
        #if DEBUG
        if let data = image.pngData() {
            let debugPath = FileManager.default.temporaryDirectory.appendingPathComponent("pdf_render_debug.png")
            try? data.write(to: debugPath)
            print("[PdfRenderer] Debug image saved to: \(debugPath.path)")
        }
        #endif

        return image
    }
}
