# FiveMac

FiveMac is a powerful GUI library for **Harbour** that allows you to create native macOS applications using the Cocoa framework.

## Overview

FiveMac bridges the gap between xBase/Harbour code and the native macOS Objective-C API, providing a rich set of classes (Windows, Dialogs, Controls, Browsers, Scintilla Editors) to build modern Mac apps.

## Recent Updates (January 2026)

### Fivedit (Advanced Editor Sample)
- **Integrated Manual Search**: The Toolbar search field now supports a native manual search workflow. Clicking the magnifying glass icon triggers the search without stealing focus while typing.
- **Improved Replace Dialog**: Redesigned layout and added "Wrap Around" logic.
- **Smart Auto-Indentation**: Full implementation of auto-indentation for Harbour control structures (`if`, `for`, `while`, `do case`, etc.) with correct handling of opening, middle, and closing blocks.
- **Stability**: Fixed various focus issues and crashes (Goto Line, Replace).

### Browse & Data Management
- **Record Synchronization**: Fixed `TWBrowse` to ensure reliable synchronization between the UI and DBF record pointer. Implemented pointer stabilization in `GetValue` and corrected event dispatching.
- **Auto-Save**: Integrated auto-save logic in `scripts.prg` samples using `TScintilla:IsModify()`.

### Database Support
- **SQLite**: Added `TSQLite` class wrapping the native macOS `libsqlite3`. Supports `Execute`, `Query`, and row management methods, enabling lightweight, serverless database integration directly within FiveMac apps.

### Graphics & User Interface
- **TBrush Engine**: Rewritten `TBrush` class with support for numeric colors, pattern images, and gradients.
- **Layer-Aware Coloring**: Modernized `WNDSETBKGCOLOR`, `WNDSETBRUSH`, and `WNDSETGRADIENTCOLOR` to use `CALayer` and `CGColor`. This fixes the "black background" issues on modern macOS versions.
- **DEFINE DIALOG**: Corrected macro to properly pass brush objects.

### Architecture & Modernization (January 2026 - Part 2)
- **64-bit Architecture**: Extensive refactoring of the entire `winapi` layer. Replaced 32-bit handle functions (`hb_parnl`, `hb_retnl`) with 64-bit safe counterparts (`hb_parnll`, `hb_retnll`) across 40+ files (`windows.m`, `dialogs.m`, `toolbars.m`, etc.) to ensure stability on modern macOS.
- **FiveDBU Modernization**: Refactored `fivedbu` sample to use **SF Symbols** for all toolbar icons, replacing legacy PNG/TIFF images.
- **File Dialogs**: Fixed `ChooseFile` and `ChooseFolder` compatibility issues on newer macOS versions by migrating to the `UniformTypeIdentifiers` framework (`UTType`).
- **Build System**: Updated `build.sh` and `makefile` to link against `UniformTypeIdentifiers`.

### Simple Project Builder (January 2026 - Part 3)
- **UI Overhaul**: Redesigned `simple_builder` interface with improved layout, support for **Project Version** and **Icon** configuration.
- **Project Loading**: New "Load Project" feature to import existing `.hbp` files, automatically populating source lists and setting the build environment.
- **Robustness**: Build process switched to native `TaskExec` (compilation) and `CopyFileTo` (deployment) for better error handling and reliability.
- **One-Click Launch**: Added "Launch App" button to run the compiled application directly from the tool using `MacExec`.
- **Security**: Updated `CreateInfoFile` to generate compliant `Info.plist` files with `NSAppTransportSecurity` and High-DPI support.

### Visual Designer (January 2026 - Part 4)
- **Visual Designer Core**: Complete overhaul of `TForm` (the designer canvas) using the new `TRect` class. This enables precise control resizing, movement, and "hotspot" management (corners/handles).
- **Inspector Integration**: Robust two-way synchronization between the visual designer and the Object Inspector (`inspect.prg`). Properties derived from `TRect` (Top, Left, Width, Height) now update in real-time.
- **TRect Class**: Introduced `TRect.prg` and `Areas.m` to provide a high-level Harbour object wrapper around native Cocoa `NSRect` manipulations. This powers the new geometric logic of the designer.
- **New Controls**: Added support for **WebView** and **ColorWell** in the designer palette and inspector.
- **Mouse Interaction**: Created `trst_mouse` sample to validate complex mouse interactions (drag-and-drop, resizing handles, cursor changes) before integrating them into the main designer.

### Project Builder & Fivedit Integration (January 2026 - Part 5)
- **CreaBuilder Integration**: The "Simple Project Builder" (`CreaBuilder.prg`) is now fully integrated into the **Fivedit** environment. Developers can create, manage, and build projects directly from the IDE via a new "Build Project" toolbar button and menu item.
- **Context Menu Fixes**: Resolved issues with the File Tree context menu in `fivedit` (`outlines.m`), ensuring reliable file management (Closing/Deleting files) without UI glitches.
- **Build System Improvements**: Updated `build.sh` to correctly generate and manage `Info.plist` files, solving issues with missing metadata and stale configurations in app bundles.
- **Say Class**: Enhanced `TSay` with `PICTURE` support (`New`, `SetText`) for formatted output of numeric and date values.

- **Project Tree**: Fivedit now includes a dedicated Project Explorer view (`OpenProject`). When a project is loaded, it visualizes the project structure in a dedicated tree node, allowing quick access to source files and project management. Modified `OpenProject` to reliably parse `.hbp` files cross-platform (LF/CRLF).

### IntelliSense & Snippets (January 2026 - Part 7)
- **Code Snippets**: Implemented full support for standard VSCode-style snippets (`snippets.json`). Typing a keyword (like `for`, `class`, `function`) and pressing `TAB` expands the template with cursor placeholders support.
- **IntelliSense Autocomplete**: Added a robust, icon-aware Autocomplete system for Harbour functions.
    - **Visuals**: Distinct icons for Functions (Cube) and Keywords/Snippets (Box) loaded directly from memory.
    - **Smart Insertion**: Automatically strips metadata (like library names) from inserted text.
    - **Contextual Help**: Persistent Tooltips (CallTips) appear upon insertion to guide parameter entry, styled with a modern light-gray theme.
- **SCNotification Fixes**: Resolved critical 64-bit alignment issues in the Objective-C layer (`scintillas.m`) that prevented correct text retrieval from Scintilla notifications on macOS.
- **SwiftUI Integration**: Initial rollout of native SwiftUI controls bridged to Harbour.
    - **TSwiftVStack**: A powerful vertical list control with support for dynamic item addition (Text, Images, HStack Rows).
    - **Layout Control**: Added `SetSpacing` and `SetAlignment` (Leading/Center/Trailing) for precise UI layout.
    - **Interactivity**: Native click support for all items, delegating events back to Harbour codeblocks.
    - **HStack Rows**: Support for complex rows containing Icons + Text with proper alignment.

## Building

To build the library and samples:

1. Ensure you have Xcode Command Line Tools installed.
2. Run `make` to build the `libfive.a` and `libfivec.a` libraries.
3. Use `./build.sh <samplename>` in the `samples` directory to build specific applications (e.g., `./build.sh fivedit`).

### Fivedit Location & Build System (January 2026 - Part 6)
- **Repo Structure**: `fivedit` has been moved to its own directory `samples/fivedit/` to better organize its growing codebase and resources.
- **Build Robustness**: Fixed critical issues in `CreaBuilder.prg` and `Info.plist` generation ("App Damaged" errors) by ensuring `CFBundleExecutable` contains only the filename and using relative paths for bundle creation. 
- **Self-Healing Environment**: `NewFile` in Fivedit now automatically detects and creates missing indexes (`scripts.cdx`) for the template database, preventing runtime errors on fresh installs.
- **Script Engine**: Corrected various path resolution issues in `RunScript` and `BuildApp` to support the new directory structure.

## Documentation

See `whatsnew.txt` for a detailed history of changes and new features.

