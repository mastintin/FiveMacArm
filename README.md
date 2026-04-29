# FiveMac Framework - Modernization Log (Abril 2026)

## 🏝️ Swift Island (sw): Arquitectura 2.0
Esta nueva arquitectura representa el futuro de FiveMac, eliminando las barreras tradicionales entre el mundo xBase y el ecosistema moderno de Apple.

**[📖 Leer más sobre la Evolución de "La Isla" (Arquitectura SW)](fivemac/doc/sw/SW_CONCEPT.md)**

Hemos dado un salto generacional en la integración Harbour-Swift:
*   **Universal Dispatcher (Type-Agnostic)**: El bridge ya no necesita conocer el tipo de control. Todo se maneja por IDs y estados atómicos, simplificando el mantenimiento un 90%.
*   **Geometría Reactiva**: Primer sistema de coordenadas dinámicas en tiempo real. Al cambiar `oControl:nTop` en Harbour, el objeto se desplaza en SwiftUI instantáneamente.
*   **Bridge Minimalista**: Reducción de la complejidad de comunicación. Las llamadas de orquestación de ventanas han pasado de 7 parámetros a solo **2** (IDs puros).
*   **Self-Identifying Components**: Los controles son autónomos; nacen con su identidad y estado cargado en el `hState`, eliminando latencias de inicialización.

## 🚀 Componentes de Lista y Navegación

## 📝 Motores de Edición y Scintilla
*   **Scintilla 5**: Migración al framework 5 para mayor estabilidad en macOS modernos.
*   **Monaco Editor**: Integración del motor de VS Code con extensiones para Harbour.
*   **Carga vía CDN**: Test funcional de Monaco y sus extensiones sin instalación local.
*   **Symbol Navigator**: Selector de funciones rediseñado con búsqueda inteligente.

---

# FiveMacArm

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

## 🏝️ Swift Island (sw): Arquitectura 2.0
Esta nueva arquitectura representa el futuro de FiveMac, eliminando las barreras tradicionales entre el mundo xBase y el ecosistema moderno de Apple.

**[📖 Leer más sobre la Evolución de "La Isla" (Arquitectura SW)](fivemac/doc/sw/SW_CONCEPT.md)**

---

## 🎯 Development Strategy

In the recent evolution of FiveMac, we are prioritizing new developments in **Swift** over **Objective-C** for specific modules (especially in the `SwiftUI/` and modern network wrappers). This strategic shift is based on:

1. **Superior Memory Management**: Swift's modern memory safety and ARC (Automatic Reference Counting) are significantly more robust than Objective-C, helping to prevent leaks and pointer-related crashes.
2. **Apple's Modern API Priority**: Apple increasingly prioritizes new system functions and frameworks (such as `SwiftUI`, `Network`, and `Observation`) that are optimized for or exclusive to Swift.
3. **Code Simplicity & Maintainability**: Swift allows for cleaner and more concise code. A clear example is the implementation of networking and asynchronous tasks, which are handled with much less boilerplate than in Objective-C.
4. **Future-Proofing**: Swift is the future of the macOS ecosystem. While Objective-C remains supported for compatibility, it has moved into a maintenance phase while Swift continues to evolve rapidly.

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
  - **Image Embedding**: `TNiceImage` support for including local path or Base64 images directly in reports (`DEFINE NICE IMAGE`).
- **SwiftUI Enhancements**:
  - **SwiftGrid**: Improved internal state management, row indexing, and correct handling of multiple grid instances.
  - **Zebra Striping**: Native support for alternating row colors for better readability.
- **Database Synchronization Suite**:
  - Full bi-directional data flow between **DBF ↔ SQLite ↔ MySQL**.
  - **High-Precision Numeric Support**: Enhanced `CreateTable` and `DbStruct` (SQLite/MySQL) to preserve decimal precision using `NUMERIC(L,D)` and `DOUBLE(L,D)`.
  - **Automatic Type Conversion**: Robust handling of ISO dates, logicals, and numeric types during cross-database migrations.
  - **Identifier Quoting**: Full support for backticks (MySQL) and double quotes (SQLite), preventing conflicts with reserved SQL keywords.
  - **Migration Progress**: Native support for progress callbacks during large data imports/exports.
- **Music Control Improvements**:
  - **Native AppleScript Integration**: Direct control of macOS Music app without deprecated ScriptingBridge.
  - **Artwork Support**: `GetTrackArtwork()` now retrieves high-resolution album art from the current track.
  - **Metadata**: Reliable retrieval of song title, artist, duration, and player state.
- **Memory Management Overhaul**:
  - **Proactive Cleanup**: Implemented `End()` methods across all core classes (`TMultiView`, `TToolBar`, `TToolBarBtn`, `TGroup`, `TDatePicker`, `TImage`) to ensure immediate resource release.
  - **Native Release Patterns**: Integrated `autorelease` and `removeFromSuperview` patterns in Objective-C wrappers, aligning with modern Cocoa memory management standards.
  - **SwiftUI Leak Fixes**: Resolved critical memory leaks in `TSwiftVStack`, `TSwiftList`, and `TSwiftButton` by ensuring correct de-registration from global internal registries.
  - **Advanced Image Handling**: New `Retain()` and `Release()` methods in `TImage` for manual control of native `NSImage` handles, plus automatic cleanup on control destruction.
- **SwiftUI Modern Architecture (Atomic State)**:
  - **TSwWindow (POC)**: New support for Pure SwiftUI windows with absolute positioning and direct state-driven initialization.
  - **Atomic Initialization**: All modern controls now use a JSON-encoded state object during creation, eliminating visual "flicker" and ensuring all properties (colors, prominence, glass effects) are applied natively at the moment of instantiation.
  - **Standardized Color Scale**: Unified opacity management using a **0-100 percentage scale** across Harbour, Swift, and C bridges, replacing the legacy 0-255 byte scale.
  - **Intelligent Defaults**: UI elements now default to intuitive native styles (transparent backgrounds for stacks, solid black for text) driven directly by Harbour class logic for maximum predictability.
- **Enhanced Robustness**:
  - Improved data validation and null-pointer checks in Objective-C wrappers to prevent `EXC_BAD_ACCESS` crashes.
  - Optimized Harbour Garbage Collector integration with manual `hb_gcAll(.T.)` calls during complex view transitions.

## 🖥️ IDE: Fivedit

FiveMac includes `fivedit`, a fully functional IDE written in FiveMac itself (`fivemac/nativo/Fivedit`).
- **Syntax Highlighting**: Powered by Scintilla (recompiled for macOS).
- **Project Building**: "Run" button compiles and runs the current PRG.
- **App Bundling**: Automatically generates `.app` bundles, copying necessary Frameworks (`Contents/Frameworks`) and Resources.
- **Debugging**: Integrated build log and error reporting.

---
*Powered by Harbour & Objective-C*
