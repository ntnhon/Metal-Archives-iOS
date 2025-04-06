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
let package = Package(name: "Models",
                      platforms: kPlatforms,
                      products:
                      [
                          .library(name: "Models", targets: ["Models"]),
                      ],
                      targets:
                      [
                          .target(name: "Models"),
                      ])
