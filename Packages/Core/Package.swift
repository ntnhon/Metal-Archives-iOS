// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var kPlatforms: [SupportedPlatform] = [
    .macOS(.v12),
    .iOS(.v15),
    .tvOS(.v16),
    .watchOS(.v8),
]

let kSwiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ImplicitOpenExistentials"),
    .enableUpcomingFeature("StrictConcurrency"),
    .unsafeFlags([
        "-warn-concurrency",
        "-enable-actor-data-race-checks",
        "-driver-time-compilation",
        "-Xfrontend",
        "-debug-time-function-bodies",
        "-Xfrontend",
        "-debug-time-expression-type-checking",
        "-Xfrontend",
        "-warn-long-function-bodies=100",
        "-Xfrontend",
        "-warn-long-expression-type-checking=100",
    ]),
]

// swiftlint:disable:next prefixed_toplevel_constant
let package = Package(name: "Core",
                      platforms: kPlatforms,
                      products:
                      [
                          .library(name: "Core", targets: ["Core"]),
                      ],
                      dependencies: [
                          .package(name: "Models", path: "../Models"),
                      ],
                      targets:
                      [
                          .target(name: "Core",
                                  dependencies:
                                  [
                                      .product(name: "Models", package: "Models"),
                                  ],
                                  swiftSettings: kSwiftSettings),
                      ])
