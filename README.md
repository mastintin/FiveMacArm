# FiveMac

**FiveMac** is a library that allows **Harbour** developers to create native macOS applications using the **Cocoa (AppKit)** framework. It bridges the power of the xBase language with the modern macOS user interface.

## 🚀 Features

- **Native UI**: Uses standard Cocoa controls (`NSWindow`, `NSButton`, `NSToolbar`, `WKWebView`, etc.) for a true native look and feel.
- **Harbour Integration**: Familiar syntax for FiveWin/Harbour developers.
- **Modern Support**: 
  - Optimized for **Apple Silicon (ARM64)** and Intel. (Harbour binaries included are compiled for ARM64).
  - Built using **macOS SDK 15.4 / 26.2** (dynamically detected).
  - Support for **SF Symbols** (`ImgSymbols`) alongside traditional bitmaps.
  - Updated build system using `clang` and dynamic SDK path detection.

## 📂 Project Structure

- **`fivemac/`**: Core source code.
  - `source/classes/`: Harbour class definitions (prg).
  - `source/winapi/`: Objective-C low-level API wrappers.
  - `include/`: Header files (`fivemac.ch`, etc.).
- **`samples/`**: Example applications showing how to use various controls.
- **`bitmaps/`**: Shared image resources for samples.

## 🛠️ Build & Installation

### Prerequisites
1. **Xcode** (or Xcode Command Line Tools).
2. **Harbour** compiler installed and accessible.

### Compiling the Library
To build the static libraries (`libfive.a` and `libfivec.a`):

```bash
cd fivemac
make
```

### Building Samples
Samples are located in the `fivemac/samples` directory. Use the provided `build.sh` script:

```bash
cd fivemac/samples
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

---
*Powered by Harbour & Objective-C*
