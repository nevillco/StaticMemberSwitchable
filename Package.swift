// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "StaticMemberSwitchable",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(
            name: "StaticMemberSwitchable",
            targets: ["StaticMemberSwitchable"]
        ),
        .executable(
            name: "StaticMemberSwitchableExample",
            targets: ["StaticMemberSwitchableExample"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "510.0.2"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-macro-testing",
            from: "0.2.1"
        )
    ],
    targets: [
        // Actual macro implementation that performs the compile-time codegen.
        .macro(
            name: "StaticMemberSwitchableMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        // Library that exposes a macro as part of its API, 
        // which can be used by external clients.
        .target(
            name: "StaticMemberSwitchable",
            dependencies: ["StaticMemberSwitchableMacro"]
        ),
        // An example client to demonstrate usage.
        .executableTarget(
            name: "StaticMemberSwitchableExample",
            dependencies: ["StaticMemberSwitchable"]
        ),
        // A test target used to develop the macro implementation.
        .testTarget(
            name: "StaticMemberSwitchableMacroTests",
            dependencies: [
                "StaticMemberSwitchableMacro",
                .product(
                    name: "SwiftSyntaxMacrosTestSupport",
                    package: "swift-syntax"
                ),
                .product(
                    name: "MacroTesting",
                    package: "swift-macro-testing"
                )
            ]
        ),
    ]
)
