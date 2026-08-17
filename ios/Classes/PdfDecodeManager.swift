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
            print("[PdfDecodeManager] Using file path: \(filePath)")
            print("[PdfDecodeManager] File exists: \(FileManager.default.fileExists(atPath: filePath))")
        } else {
            throw NSError(domain: "PdfDecodeManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Either pdfBytes or filePath must be provided"])
        }
        
        defer {
            if isTemp {
                try? FileManager.default.removeItem(at: url)
            }
        }
        
        print("[PdfDecodeManager] Opening PDF at: \(url.path)")
        guard let document = PDFDocument(url: url) else {
            print("[PdfDecodeManager] ERROR: PDFDocument returned nil for \(url.path)")
            throw NSError(domain: "INVALID_PDF", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not open PDF file"])
        }
        print("[PdfDecodeManager] PDF opened: \(document.pageCount) page(s), encrypted=\(document.isEncrypted)")
        
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
        
        print("[PdfDecodeManager] Config: dpi=\(dpi), firstPageOnly=\(firstPageOnly), stopAfterFirst=\(stopAfterFirst), maxPages=\(maxPages), formats=\(formats)")
        print("[PdfDecodeManager] Raw config map: \(config)")
        
        let pagesToScan = firstPageOnly ? 1 : min(document.pageCount, maxPages)
        print("[PdfDecodeManager] Will scan \(pagesToScan) page(s)")
        
        for i in 0..<pagesToScan {
            guard let page = document.page(at: i) else {
                print("[PdfDecodeManager] WARNING: Could not get page at index \(i)")
                continue
            }
            
            print("[PdfDecodeManager] --- Processing page \(i) ---")
            if let image = renderer.renderPage(page, dpi: dpi) {
                let rawResults = scanner.scan(image: image, formats: formats)
                print("[PdfDecodeManager] Page \(i): found \(rawResults.count) barcode(s)")
                for var barcode in rawResults {
                    barcode["page"] = i
                    resultList.append(barcode)
                }
                
                if stopAfterFirst && !resultList.isEmpty {
                    break
                }
            } else {
                print("[PdfDecodeManager] WARNING: renderPage returned nil for page \(i)")
            }
        }
        
        print("[PdfDecodeManager] Total barcodes found: \(resultList.count)")
        return resultList
    }
}
