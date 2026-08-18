import Foundation
import Vision
import UIKit

protocol BarcodeScanner {
    func scan(image: UIImage, formats: [String]) -> [[String: Any]]
}

class AppleVisionBarcodeScanner: BarcodeScanner {
    func scan(image: UIImage, formats: [String]) -> [[String: Any]] {
        guard let cgImage = image.cgImage else {
            print("[VisionScanner] ERROR: Failed to get CGImage from UIImage (size=\(image.size))")
            return []
        }
        
        print("[VisionScanner] Scanning image: \(cgImage.width)x\(cgImage.height) px, formats=\(formats)")
        
        var results = [[String: Any]]()
        var detectionError: Error? = nil
        
        let request = VNDetectBarcodesRequest { (request, error) in
            if let error = error {
                detectionError = error
                print("[VisionScanner] ERROR in detection callback: \(error.localizedDescription)")
                return
            }
            
            guard let observations = request.results as? [VNBarcodeObservation] else {
                print("[VisionScanner] WARNING: results is nil or wrong type. results=\(String(describing: request.results))")
                return
            }
            
            print("[VisionScanner] Found \(observations.count) barcode observation(s)")
            
            for observation in observations {
                let boundingBox = observation.boundingBox
                // boundingBox is in normalized coordinates, lower-left origin
                let imgWidth = CGFloat(cgImage.width)
                let imgHeight = CGFloat(cgImage.height)
                let width = boundingBox.width * imgWidth
                let height = boundingBox.height * imgHeight
                let left = boundingBox.minX * imgWidth
                let top = (1.0 - boundingBox.maxY) * imgHeight // convert to upper-left origin
                
                let value = observation.payloadStringValue ?? ""
                print("[VisionScanner]   -> type=\(observation.symbology.rawValue), length=\(value.count), box=(\(left),\(top),\(width),\(height))")
                
                let result: [String: Any] = [
                    "type": self.mapResultFormat(observation.symbology),
                    "value": value,
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
            print("[VisionScanner] Using symbologies filter: \(visionFormats.map { $0.rawValue })")
        } else {
            print("[VisionScanner] Using ALL symbologies (no filter)")
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("[VisionScanner] ERROR: handler.perform failed: \(error.localizedDescription)")
        }
        
        if let err = detectionError {
            print("[VisionScanner] Detection completed with error: \(err.localizedDescription)")
        }
        
        print("[VisionScanner] Returning \(results.count) result(s)")
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
            default:
                print("[VisionScanner] WARNING: Unknown format '\(format)', skipping")
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
