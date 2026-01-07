# FiveMac

FiveMac is a powerful GUI library for **Harbour** that allows you to create native macOS applications using the Cocoa framework.

## Overview

FiveMac bridges the gap between xBase/Harbour code and the native macOS Objective-C API, providing a rich set of classes (Windows, Dialogs, Controls, Browsers, Scintilla Editors) to build modern Mac apps.

## Recent Updates (January 2026)

### Fivedit (Advanced Editor Sample)
- **Integrated Manual Search**: The Toolbar search field now supports a native manual search workflow. Clicking the magnifying glass icon triggers the search without stealing focus while typing.
- **Improved Replace Dialog**: Redesigned layout and added "Wrap Around" logic.
- **Stability**: Fixed various focus issues and crashes (Goto Line, Replace).

### Browse & Data Management
- **Record Synchronization**: Fixed `TWBrowse` to ensure reliable synchronization between the UI and DBF record pointer. Implemented pointer stabilization in `GetValue` and corrected event dispatching.
- **Auto-Save**: Integrated auto-save logic in `scripts.prg` samples using `TScintilla:IsModify()`.

### Graphics & User Interface
- **TBrush Engine**: Rewritten `TBrush` class with support for numeric colors, pattern images, and gradients.
- **Layer-Aware Coloring**: Modernized `WNDSETBKGCOLOR`, `WNDSETBRUSH`, and `WNDSETGRADIENTCOLOR` to use `CALayer` and `CGColor`. This fixes the "black background" issues on modern macOS versions.
- **DEFINE DIALOG**: Corrected macro to properly pass brush objects.

### Architecture & Modernization (January 2026 - Part 2)
- **64-bit Architecture**: Extensive refactoring of the entire `winapi` layer. Replaced 32-bit handle functions (`hb_parnl`, `hb_retnl`) with 64-bit safe counterparts (`hb_parnll`, `hb_retnll`) across 40+ files (`windows.m`, `dialogs.m`, `toolbars.m`, etc.) to ensure stability on modern macOS.
- **FiveDBU Modernization**: Refactored `fivedbu` sample to use **SF Symbols** for all toolbar icons, replacing legacy PNG/TIFF images.
- **File Dialogs**: Fixed `ChooseFile` and `ChooseFolder` compatibility issues on newer macOS versions by migrating to the `UniformTypeIdentifiers` framework (`UTType`).
- **Build System**: Updated `build.sh` and `makefile` to link against `UniformTypeIdentifiers`.

## Building

To build the library and samples:

1. Ensure you have Xcode Command Line Tools installed.
2. Run `make` to build the `libfive.a` and `libfivec.a` libraries.
3. Use `./build.sh <samplename>` in the `samples` directory to build specific applications (e.g., `./build.sh fivedit`).

## Documentation

See `whatsnew.txt` for a detailed history of changes and new features.

