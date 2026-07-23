// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "jumio_mobile_sdk_flutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(
            name: "jumio-mobile-sdk-flutter",
            targets: ["jumio_mobile_sdk_flutter"]
        )
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/Jumio/mobile-sdk-ios.git",
            from: "4.18.0"
        )
    ],
    targets: [
        .target(
            name: "JumioMobileSdkObjC",
            path: "Sources/JumioMobileSdkObjC",
            publicHeadersPath: "."
        ),
        .target(
            name: "jumio_mobile_sdk_flutter",
            dependencies: [
                "JumioMobileSdkObjC",
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Jumio", package: "mobile-sdk-ios"),
                .product(name: "JumioDefaultUI", package: "mobile-sdk-ios"),
                .product(name: "JumioLiveness", package: "mobile-sdk-ios"),
                .product(name: "JumioNFC", package: "mobile-sdk-ios"),
                .product(name: "JumioLocalization", package: "mobile-sdk-ios")
            ]
         )
    ]
)
