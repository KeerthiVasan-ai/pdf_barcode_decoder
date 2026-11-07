// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "pdf_barcode_decoder",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(
            name: "pdf-barcode-decoder",
            targets: ["pdf_barcode_decoder"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "pdf_barcode_decoder",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)

