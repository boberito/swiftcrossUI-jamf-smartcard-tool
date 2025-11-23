// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SCEU",
    platforms: [
              .macOS(.v15)   // Minimum macOS 10.15 Catalina
          ],

    dependencies: [
            .package(url: "https://github.com/stackotter/swift-cross-ui", branch: "main"),
            // .package(
            //     url: "https://github.com/stackotter/swift-bundler",
            //     revision: "d42d7ffda684cfed9edcfd3581b8127f1dc55c2e"
            // ),
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "SCEU",
            dependencies: [
                           .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
                           .product(name: "DefaultBackend", package: "swift-cross-ui"),
                           .product(name: "GtkBackend", package: "swift-cross-ui", condition: .when(platforms: [.linux])),

                        //    .product(
                        //            name: "SwiftBundlerRuntime",
                        //            package: "swift-bundler",
                        //            condition: .when(platforms: [.macOS, .linux])
                        //        ),
                       ],
            resources: [.copy("logo.png")]
        ),
    ]
)
