import Flutter
import UIKit

public class SwiftPdfBarcodeDecoderPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "pdf_barcode_decoder", binaryMessenger: registrar.messenger())
    let instance = SwiftPdfBarcodeDecoderPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
