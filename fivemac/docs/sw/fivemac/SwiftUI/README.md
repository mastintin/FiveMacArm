# Swift System Utilities & Harbour Macros Documentation

This document describes the new native macOS system utilities implemented in Swift and the automated Harbour bridging system using Swift Macros.

## 1. Native System Utilities (`SwiftSystem.swift`)

A new set of native macOS utilities has been implemented in Swift, replacing or augmenting existing Objective-C implementations. These are organized within the `SystemUtils` struct for internal Swift use and exposed via bridges for Harbour.

### Available Functions

| Function (Harbour) | Description | Parameters |
| :--- | :--- | :--- |
| `CSWGETFILE()` | Open File Dialog | `title`, `types` (comma-sep), `prompt` |
| `CSWGETIMAGEFILE()`| Open Image Picker | `title`, `prompt` (Filtered for native image types) |
| `CSWGETDIR()` | Open Directory Dialog | `title`, `prompt` |
| `SW_MSGINFO()` | Information Alert | `msg`, `title` (optional) |
| `SW_MSGYESNO()` | Confirmation Dialog | `msg`, `title` (optional). Returns Boolean. |
| `CSWGETCOLOR()` | Native Color Picker | Returns RGB integer. |
| `CSWPATH()` | App Bundle Parent Path| Returns current executable folder path. |
| `CSWAPPPATH()` | App Bundle Path | Returns full `.app` path. |
| `CSWRESPATH()` | Resources Path | Returns the `Resources` folder path. |

## 2. Harbour Macro System (`@HarbourBridge`)

To eliminate boilerplate code when bridging Swift to Harbour, a new macro system has been introduced.

### How it works
Decorating a global Swift function with `@HarbourBridge` automatically generates a C-compatible bridge function (`@_cdecl`) that handles string pointer conversion and optionality checks.

### Example Usage
In Swift:
```swift
@HarbourBridge
public func swift_get_path() -> String {
    return SystemUtils.path
}
```

The macro automatically generates:
```swift
@_cdecl("swift_get_path")
public func _bridge_swift_get_path() -> UnsafePointer<Int8>? {
    let result = swift_get_path()
    return (result as NSString).utf8String
}
```

### Supported Patterns
- **No parameters**: Functions returning `String` or `String?`.
- **String parameters**: Functions taking one or more `String` or `String?` arguments.
- **Return types**: Supports `String`, `String?`, and `Void`.

## 3. Build System Integration

The macro system is integrated into the native `Makefile` and `build_lib.sh`.

### Directory Structure
- `source/HarbourMacro/Definition/`: The `@HarbourBridge` attribute declaration.
- `source/HarbourMacro/Implementation/`: The compiler plugin logic (uses `swift-syntax`).
- `source/HarbourMacro/bin/`: **Stable Binaries**. Contains the compiled plugin and module files.
- `source/HarbourMacro/install_macro.sh`: Script to refresh the `bin/` directory from the hidden `.build/` folder.

### Compiling with Macros
The `swiftc` compiler now uses the following flags:
- `-I source/HarbourMacro/bin`: To find the macro module.
- `-load-plugin-executable source/HarbourMacro/bin/HarbourMacroPlugin#HarbourMacroImpl`: To load the transformation logic.

## 4. Maintenance
If the macro logic is modified:
1. Navigate to `source/HarbourMacro/`.
2. Run `swift build -c release`.
3. Run `source/HarbourMacro/install_macro.sh` (from the `SwiftUI` root) to update the visible binaries.

> [!IMPORTANT]
> The `.build` folder contains over 100MB of dependencies and temporary data. It is excluded via `.gitignore`. The `bin/` folder contains the necessary finalized artifacts (approx. 20MB) for distribution.
