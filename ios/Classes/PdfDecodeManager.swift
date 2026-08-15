import Foundation
import PDFKit

class PdfDecodeManager {
    func decodePdf(pdfBytes: FlutterStandardTypedData?, filePath: String?, config: [String: Any]) throws -> [[String: Any]] {
        let url: URL
        var isTemp = false
        
        if let pdfBytes = pdfBytes {
            let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent("pdf_bc_\(UUID().uuidString).pdf")
            try pdfBytes.data.write(to: tempUrl)
            url = tempUrl
            isTemp = true
        } else if let filePath = filePath {
            url = URL(fileURLWithPath: filePath)
        } else {
            throw NSError(domain: "PdfDecodeManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Either pdfBytes or filePath must be provided"])
        }
        
        defer {
            if isTemp {
                try? FileManager.default.removeItem(at: url)
            }
        }
        
        guard let document = PDFDocument(url: url) else {
            throw NSError(domain: "INVALID_PDF", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not open PDF file"])
        }
        
        if document.isEncrypted {
            throw NSError(domain: "ENCRYPTED_PDF", code: 3, userInfo: [NSLocalizedDescriptionKey: "PDF is password protected"])
        }
        
        let renderer = DefaultPdfPageRenderer()
        let scanner = AppleVisionBarcodeScanner()
        var resultList = [[String: Any]]()
        
        let dpi = config["dpi"] as? Int ?? 300
        let firstPageOnly = config["firstPageOnly"] as? Bool ?? false
        let stopAfterFirst = config["stopAfterFirst"] as? Bool ?? false
        let maxPages = config["maxPages"] as? Int ?? document.pageCount
        let formats = config["formats"] as? [String] ?? ["all"]
        
        let pagesToScan = firstPageOnly ? 1 : min(document.pageCount, maxPages)
        
        for i in 0..<pagesToScan {
            guard let page = document.page(at: i) else { continue }
            
            if let image = renderer.renderPage(page, dpi: dpi) {
                let rawResults = scanner.scan(image: image, formats: formats)
                for var barcode in rawResults {
                    barcode["page"] = i
                    resultList.append(barcode)
                }
                
                if stopAfterFirst && !resultList.isEmpty {
                    break
                }
            }
        }
        
        return resultList
    }
}
