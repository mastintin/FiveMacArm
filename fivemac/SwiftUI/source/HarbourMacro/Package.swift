// swift-tools-version: 5.9
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "HarbourMacro",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "HarbourMacro", targets: ["HarbourMacro"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        // La implementación que genera el plugin binario
        .macro(
            name: "HarbourMacroImpl",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            path: "Implementation"
        ),
        // La biblioteca pública para usar @HarbourBridge
        .target(
            name: "HarbourMacro",
            dependencies: ["HarbourMacroImpl"],
            path: "Definition"
        ),
    ]
)
