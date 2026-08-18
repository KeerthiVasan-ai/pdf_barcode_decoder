#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pdf_barcode_decoder.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pdf_barcode_decoder'
  s.version          = '0.0.2'
  s.summary          = 'A Flutter plugin to decode barcodes directly from PDF files and bytes.'
  s.description      = <<-DESC
A fast, lightweight Flutter plugin to decode barcodes (QR, PDF417, Aztec, DataMatrix, Code128, etc.) directly from PDF files and bytes using native PDFKit and Vision Framework.
                       DESC
  s.homepage         = 'https://github.com/KeerthiVasan-ai/pdf_barcode_decoder'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Keerthivasan S' => 'https://github.com/KeerthiVasan-ai' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.frameworks = 'PDFKit', 'Vision'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
