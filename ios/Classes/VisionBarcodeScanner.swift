import Foundation
import Vision
import UIKit

protocol BarcodeScanner {
    func scan(image: UIImage, formats: [String]) -> [[String: Any]]
}

class AppleVisionBarcodeScanner: BarcodeScanner {
    func scan(image: UIImage, formats: [String]) -> [[String: Any]] {
        guard let cgImage = image.cgImage else { return [] }
        
        var results = [[String: Any]]()
        let request = VNDetectBarcodesRequest { (request, error) in
            guard let observations = request.results as? [VNBarcodeObservation] else { return }
            
            for observation in observations {
                let boundingBox = observation.boundingBox
                // boundingBox is in normalized coordinates, lower-left origin
                let width = boundingBox.width * image.size.width
                let height = boundingBox.height * image.size.height
                let left = boundingBox.minX * image.size.width
                let top = (1.0 - boundingBox.maxY) * image.size.height // convert to upper-left origin
                
                let result: [String: Any] = [
                    "type": self.mapResultFormat(observation.symbology),
                    "value": observation.payloadStringValue ?? "",
                    "left": left,
                    "top": top,
                    "width": width,
                    "height": height
                ]
                results.append(result)
            }
        }
        
        let visionFormats = mapFormats(formats)
        if !visionFormats.isEmpty {
            request.symbologies = visionFormats
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Vision barcode scanning failed: \(error)")
        }
        
        return results
    }
    
    private func mapFormats(_ formats: [String]) -> [VNBarcodeSymbology] {
        if formats.contains("all") {
            return []
        }
        
        var result = [VNBarcodeSymbology]()
        for format in formats {
            switch format {
            case "qr": result.append(.qr)
            case "pdf417": result.append(.pdf417)
            case "aztec": result.append(.aztec)
            case "dataMatrix": result.append(.dataMatrix)
            case "code128": result.append(.code128)
            case "ean13": result.append(.ean13)
            case "ean8": result.append(.ean8)
            case "upc": result.append(.upce)
            case "itf": result.append(.itf14)
            default: break
            }
        }
        return result
    }
    
    private func mapResultFormat(_ format: VNBarcodeSymbology) -> String {
        switch format {
        case .qr: return "qr"
        case .pdf417: return "pdf417"
        case .aztec: return "aztec"
        case .dataMatrix: return "dataMatrix"
        case .code128: return "code128"
        case .ean13: return "ean13"
        case .ean8: return "ean8"
        case .upce: return "upc"
        case .itf14: return "itf"
        default: return "unknown"
        }
    }
}
