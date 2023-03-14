// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let targets = ["Redux", "ReduxDSL", "ReduxThunk", "ReduxComponent", "ReduxShim"]

let package = Package(
  name: "swift-redux",
  platforms: [.macOS(.v12), .iOS(.v13), .watchOS(.v7), .tvOS(.v13)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "Redux",
      targets: targets),
    
    .library(
      name: "ReduxDynamic",
      type: .dynamic,
      targets: targets),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    .package(
      url: "https://github.com/apple/swift-atomics.git",
      .upToNextMajor(from: "1.1.0") // or `.upToNextMinor`
    )
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "ReduxShim",
      dependencies: ["Redux"]),
    
    .target(
      name: "ReduxDSL",
      dependencies: ["Redux"]),
  
    .target(
      name: "ReduxComponent",
      dependencies: ["Redux"]),
  
    .target(
      name: "ReduxThunk",
      dependencies: ["Redux"]),
  
    .target(
      name: "Redux",
      dependencies: [
        .product(name: "Atomics", package: "swift-atomics")
      ]),
  
    .testTarget(
      name: "ReduxTests",
      dependencies: ["Redux"]),
  ]
)
