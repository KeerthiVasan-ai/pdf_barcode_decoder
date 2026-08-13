#import "PdfBarcodeDecoderPlugin.h"
#if __has_include(<pdf_barcode_decoder/pdf_barcode_decoder-Swift.h>)
#import <pdf_barcode_decoder/pdf_barcode_decoder-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "pdf_barcode_decoder-Swift.h"
#endif

@implementation PdfBarcodeDecoderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPdfBarcodeDecoderPlugin registerWithRegistrar:registrar];
}
@end
