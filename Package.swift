// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ImageViewer",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "ImageViewer",
            targets: ["ImageViewer"]),
    ],
    targets: [
        .target(
            name: "ImageViewer"),
        .testTarget(
            name: "ImageViewerTests",
            dependencies: ["ImageViewer"]),
    ]
)
