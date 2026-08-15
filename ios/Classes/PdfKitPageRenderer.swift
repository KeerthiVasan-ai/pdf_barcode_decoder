import Foundation
import PDFKit

protocol PdfPageRenderer {
    func renderPage(_ page: PDFPage, dpi: Int) -> UIImage?
}

class DefaultPdfPageRenderer: PdfPageRenderer {
    func renderPage(_ page: PDFPage, dpi: Int) -> UIImage? {
        let rect = page.bounds(for: .mediaBox)
        let scale = CGFloat(dpi) / 72.0
        let size = CGSize(width: rect.width * scale, height: rect.height * scale)
        return page.thumbnail(of: size, for: .mediaBox)
    }
}
