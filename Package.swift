// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "ExcellemedBinarySPM",
  platforms: [.iOS(.v17)],
  products: [
    .library(name: "Algorithm", targets: ["Algorithm", "AlgorithmShim"]),
    .library(name: "RustXcframework", targets: ["RustXcframework", "RustXcframeworkShim"]),
    .library(name: "ToolKit", targets: ["ToolKit", "ToolKitShim"]),
    .library(name: "BLEKit", targets: ["BLEKit", "BLEKitShim"]),
    .library(name: "ChartKit", targets: ["ChartKit", "ChartKitShim"]),
    .library(name: "ExRefresh", targets: ["ExRefresh", "ExRefreshShim"]),
    .library(name: "HttpKit", targets: ["HttpKit", "HttpKitShim"]),
    .library(name: "WebSocket", targets: ["WebSocket", "WebSocketShim"]),
    .library(name: "CombineCocoa", targets: ["CombineCocoa"]),
    .library(name: "Lottie", targets: ["Lottie", "LottieShim"]),
    .library(name: "ComponentKit", targets: ["ComponentKit"]),
    .library(name: "ExcellemedKit", targets: ["ExcellemedKit"]),
  ],
  targets: [
    .binaryTarget(
      name: "Algorithm",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.1/Algorithm.xcframework.zip",
      checksum: "c634a9612f11c7cb565bd191cc3c9746aef137fa3ab14effbdcad521556a418d"
    ),
    .binaryTarget(
      name: "RustXcframework",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.1/RustXcframework.xcframework.zip",
      checksum: "5ca2d7257a5cc290e1dd636a1d2cc4fcb9d3d6af1abeee3a06ee17e395ae2aff"
    ),
    .target(
      name: "Runtime",
      path: "SourcePackages/CombineCocoa/Sources/Runtime",
      publicHeadersPath: "include"
    ),
    .target(
      name: "COpenCombineHelpers",
      path: "SourcePackages/CombineCocoa/Sources/COpenCombineHelpers",
      publicHeadersPath: "include"
    ),
    .binaryTarget(
      name: "ToolKit",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.1/ToolKit.xcframework.zip",
      checksum: "40fcef426844065caed535bb15575e476a4cf19081f07f3e2188dad609e486f0"
    ),
    .binaryTarget(
      name: "BLEKit",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.1/BLEKit.xcframework.zip",
      checksum: "89bfa090bfffa6e478839f1e8483323881637be4a8b7cc5bcffa221c797d5300"
    ),
    .binaryTarget(
      name: "ChartKit",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.1/ChartKit.xcframework.zip",
      checksum: "8ad650a9d5128c55b062ae2a29f91538f79787a8bc22f1876c0fd5f5da08799f"
    ),
    .binaryTarget(
      name: "ExRefresh",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.1/ExRefresh.xcframework.zip",
      checksum: "ea94412c47a86b4e394073169c6111009c84f057209e58c177636e6f52b81e4e"
    ),
    .binaryTarget(
      name: "HttpKit",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.1/HttpKit.xcframework.zip",
      checksum: "25c3eacc7fb9f40d2ca91e029c261126f196c2de3b55901c5e1b1dd3a0cd079a"
    ),
    .binaryTarget(
      name: "WebSocket",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.1/WebSocket.xcframework.zip",
      checksum: "dcf7573da68bd90c25ee0a4a9ca1c5d54493567b26cbe0cf5a9204a4a0c197ee"
    ),
    .target(
      name: "CombineCocoa",
      dependencies: ["Runtime", "COpenCombineHelpers"],
      path: "SourcePackages/CombineCocoa/Sources/CombineCocoa"
    ),
    .binaryTarget(
      name: "Lottie",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.1/Lottie.xcframework.zip",
      checksum: "ca33b8d77e22f8343c05b1a4dc082c7b206021d91e6ac45293cd756667212041"
    ),
    .target(
      name: "ComponentKit",
      dependencies: ["ToolKit", "Lottie", "CombineCocoa"],
      path: "SourcePackages/ComponentKit/Sources/ComponentKit",
      resources: [
        .process("Resources"),
      ]
    ),
    .target(
      name: "ExcellemedKit",
      dependencies: ["ToolKit", "BLEKit", "ChartKit", "ComponentKit", "ExRefresh", "HttpKit", "WebSocket"],
      path: "SourcePackages/ExcellemedKit/Sources/ExcellemedKit"
    ),

    .target(name: "AlgorithmShim", dependencies: ["Algorithm", "RustXcframeworkShim"]),
    .target(name: "RustXcframeworkShim", dependencies: ["RustXcframework"]),
    .target(name: "LottieShim", dependencies: ["Lottie"]),
    .target(name: "ToolKitShim", dependencies: ["ToolKit", "AlgorithmShim"]),
    .target(name: "BLEKitShim", dependencies: ["BLEKit", "ToolKitShim"]),
    .target(name: "ChartKitShim", dependencies: ["ChartKit", "ToolKitShim"]),
    .target(name: "ExRefreshShim", dependencies: ["ExRefresh", "ToolKitShim"]),
    .target(name: "HttpKitShim", dependencies: ["HttpKit", "ToolKitShim"]),
    .target(name: "WebSocketShim", dependencies: ["WebSocket"]),
  ],
  swiftLanguageModes: [.v5]
)
