import Flutter
import UIKit

public class SwiftPdfBarcodeDecoderPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pdf_barcode_decoder", binaryMessenger: registrar.messenger())
    let instance = SwiftPdfBarcodeDecoderPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "decodePdf" {
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "INVALID_ARGS", message: "Arguments must be a dictionary", details: nil))
        return
      }

      let pdfBytes = args["pdfBytes"] as? FlutterStandardTypedData
      let filePath = args["filePath"] as? String
      let config = args["config"] as? [String: Any] ?? [:]

      guard pdfBytes != nil || filePath != nil else {
        result(FlutterError(code: "INVALID_ARGS", message: "Either pdfBytes or filePath must be provided", details: nil))
        return
      }

      DispatchQueue.global(qos: .userInitiated).async {
        let manager = PdfDecodeManager()
        do {
          let barcodes = try manager.decodePdf(pdfBytes: pdfBytes, filePath: filePath, config: config)
          DispatchQueue.main.async {
            result(barcodes)
          }
        } catch let error as NSError {
          let code: String
          if error.domain == "INVALID_ARGS" || error.domain == "INVALID_PDF" || error.domain == "ENCRYPTED_PDF" {
            code = error.domain
          } else if error.domain == "PdfDecodeManager" && error.code == 1 {
            code = "INVALID_ARGS"
          } else {
            code = "RENDER_FAILED"
          }
          DispatchQueue.main.async {
            result(FlutterError(code: code, message: error.localizedDescription, details: nil))
          }
        }
      }
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}
