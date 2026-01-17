# SwiftUI Sample

This folder contains a sample application demonstrating how to embed a SwiftUI view into a FiveMac application.

## Structure
- `SwiftFiles.swift`: Defines the SwiftUI view and a `SwiftLoader` class to expose it to Objective-C.
- `SwiftGlue.m`: Objective-C code that bridges Harbour and Swift. It uses `NSHostingView`.
- `TestSwift.prg`: The Harbour main application.
- `build.sh`: A custom build script to compile and link all components.

## Building
Run `./build.sh` to build the application.

> [!NOTE]
> This sample requires a Swift compiler and a compatible macOS SDK.
> During creation, we observed an issue where `swiftc` (Swift 6.2.3) was incompatible with the installed SDKs (built with Swift 6.2/6.1).
> If you encounter "failed to build module" errors, you may need to update your Command Line Tools or point `xcode-select` to a compatible Xcode installation.
