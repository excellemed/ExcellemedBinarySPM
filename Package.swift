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
    .library(name: "CombineCocoaSource", type: .dynamic, targets: ["CombineCocoa"]),
    .library(name: "Lottie", targets: ["Lottie", "LottieShim"]),
    .library(name: "ComponentKitSource", type: .dynamic, targets: ["ComponentKit"]),
    .library(name: "ExcellemedKit", targets: ["ExcellemedKit"]),
  ],
  targets: [
    .binaryTarget(
      name: "Algorithm",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.0/Algorithm.zip",
      checksum: "d8eca1bdd6bba9c264c66522559a3895b0d00eaa8dc97036160f21648c313018"
    ),
    .binaryTarget(
      name: "RustXcframework",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.0/RustXcframework.zip",
      checksum: "b1b68d6faefe8e308392a90fdd493492a280c52153d6ea504255461b1df47fe0"
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
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.0/ToolKit.zip",
      checksum: "9f88cdb77df052189df1483efe8451235836d0f6f5f292210818e8e0c27c5391"
    ),
    .binaryTarget(
      name: "BLEKit",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.0/BLEKit.zip",
      checksum: "64b6fb629bb30dd4ac8501b46ff3aaade855fa8d000bf1b06d11f93c6d2e5495"
    ),
    .binaryTarget(
      name: "ChartKit",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.0/ChartKit.zip",
      checksum: "86d1ab7df5632f1807887270773bdec18150212a47a530795c15913587e1ff16"
    ),
    .binaryTarget(
      name: "ExRefresh",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.0/ExRefresh.zip",
      checksum: "34c4030ec267b4e9daaf8fd506860c00b9870dc8a63746e3e977ab6ff86641ba"
    ),
    .binaryTarget(
      name: "HttpKit",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.0/HttpKit.zip",
      checksum: "60ef5761c345583a6c4f692a83870b735bcdec1d5fa23b2bbb98a648fc7a69af"
    ),
    .binaryTarget(
      name: "WebSocket",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.0/WebSocket.zip",
      checksum: "56fe4fb59969bef5fc607b1d3ec835b7587701759106b05d62107076db1c900b"
    ),
    .target(
      name: "CombineCocoa",
      dependencies: ["Runtime", "COpenCombineHelpers"],
      path: "SourcePackages/CombineCocoa/Sources/CombineCocoa"
    ),
    .binaryTarget(
      name: "Lottie",
      url: "https://github.com/excellemed/ExcellemedKitXcframework/releases/download/v1.0.0/Lottie.zip",
      checksum: "dcebca8f7fd8ef8010b633c3231f4ea1020c0f74808829a33e9d552c93237d46"
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
