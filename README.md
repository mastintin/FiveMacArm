# FiveMac

**FiveMac** is a library that allows **Harbour** developers to create native macOS applications using the **Cocoa (AppKit)** framework. It bridges the power of the xBase language with the modern macOS user interface.

## 🚀 Features

- **Native UI**: Uses standard Cocoa controls (`NSWindow`, `NSButton`, `NSToolbar`, `WKWebView`, etc.) for a true native look and feel.
- **Harbour Integration**: Familiar syntax for FiveWin/Harbour developers.
- **Modern Support**: 
  - Optimized for **Apple Silicon (ARM64)** and Intel. (Harbour binaries included are compiled for ARM64).
  - Built using **macOS SDK 15.4 / 26.2** (dynamically detected).
  - **Scintilla Framework** recompiled for **ARM64**.
  - Support for **SF Symbols** (`ImgSymbols`) alongside traditional bitmaps.
  - Updated build system using `clang` and dynamic SDK path detection.

## 📂 Project Structure

The project is organized to separate the native core from high-level modern GUI wrappers.

- **`fivemac/`**: Main development folder.
  - **`nativo/`**: Core native components.
    - `source/`: Harbour class definitions and Objective-C wrappers.
    - `include/`: Framework header files.
    - `lib/`: Compiled static libraries.
    - `samples/`: Classic native samples (Cocoa).
    - `Fivedit/`: The native FiveMac IDE.
    - `makefile`: Root build system for the native core.
  - **`NiceGui/`**: Modern web-based GUI wrapper (Vue/Quasar).
  - **`SwiftUI/`**: Modern SwiftUI-based GUI wrapper.
- **`harbour/`**: The Harbour compiler and its libraries.
- **`bitmaps/`**: Shared image resources.

## 🛠️ Build & Installation

### Prerequisites
1. **Xcode** (or Xcode Command Line Tools).
2. **Harbour** compiler installed and accessible.

### Compiling the Library
To build the static libraries (`libfive.a` and `libfivec.a`):

```bash
cd fivemac/nativo
make
```

### Building Samples
Native samples are located in `fivemac/nativo/samples`. Modern UI samples are in `fivemac/NiceGui` or `fivemac/SwiftUI`.

```bash
cd fivemac/nativo/samples
./build.sh testweb
```
*(Replace `testweb` with the name of the sample you want to build)*

This will create a macOS Application Bundle (e.g., `testweb.app`) inside the `samples` folder.

## 📖 Usage Example

```clipper
#include "fivemac.ch"

FUNCTION Main()
   LOCAL oWnd

   DEFINE WINDOW oWnd TITLE "Hello FiveMac" ;
      FROM 200, 200 TO 600, 800

   @ 40, 40 BUTTON "Check Status" ;
      SIZE 150, 40 ;
      ACTION MsgInfo( "FiveMac is running natively!" ) ;
      OF oWnd

   ACTIVATE WINDOW oWnd
RETURN NIL
```

## 📝 Recent Updates
- **SF Symbols Support**: Use `ImgSymbols("gear", "Description")` to use system icons.
- **Improved Build Scripts**: Automatic detection of SDK and Swift paths.
- **Webview Improvements**: Fixed ATS issues for loading external websites.
- **Fivedit IDE**: Now capable of self-hosting! built-in compiling and linking of native apps, generating fully bundled `.app` structures with correct dependencies and Frameworks.
- **TWBrowse Improvements**: Fixed `TBrwColumn` and implemented `SetHeader` method for dynamic column header updates.
- **NiceGUI Enhancements**: 
  - New Harbour-style attributes for all controls: `BOLD`, `SIZE`, `COLOR`, `BGCOLOR`.
  - Advanced layout control for `HSTACK`, `VSTACK`, and `GRID` using `GAP`, `ALIGN`, and `JUSTIFY` clauses.
  - Seamless integration with Tailwind CSS and Quasar Framework.
- **Advanced Reporting (TNicePrinter)**:
  - High-fidelity HTML reporting engine with A4/Landscape support.
  - **Native Preview**: Dedicated preview window with zoom, navigation, and PDF export.
  - **Headless PDF Generation**: Generate professional PDFs (`TWebview:SaveToPDF`) without user interaction.
  - Automatic resource detection for standalone and bundled (`.app`) execution.
  - Seamless integration of Material Icons, Tailwind, and Quasar in printed documents.

## 🖥️ IDE: Fivedit

FiveMac includes `fivedit`, a fully functional IDE written in FiveMac itself (`fivemac/nativo/Fivedit`).
- **Syntax Highlighting**: Powered by Scintilla (recompiled for macOS).
- **Project Building**: "Run" button compiles and runs the current PRG.
- **App Bundling**: Automatically generates `.app` bundles, copying necessary Frameworks (`Contents/Frameworks`) and Resources.
- **Debugging**: Integrated build log and error reporting.

---
*Powered by Harbour & Objective-C*
