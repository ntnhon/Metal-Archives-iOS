// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var kPlatforms: [SupportedPlatform] = [
    .macOS(.v14),
    .iOS(.v17),
    .tvOS(.v17),
    .watchOS(.v10),
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
                                  ]),
                      ])
