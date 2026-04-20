# FiveMac

FiveMac is a powerful GUI library for **Harbour** that allows you to create native macOS applications using the Cocoa framework.

## Overview

FiveMac bridges the gap between xBase/Harbour code and the native macOS Objective-C API, providing a rich set of classes (Windows, Dialogs, Controls, Browsers, Scintilla Editors) to build modern Mac apps.

---

# Recent Updates (April 2026)

## 🏝️ Swift Island (sw): Revolucionaria Arquitectura Harbour-Swift
Esta nueva arquitectura representa el futuro de FiveMac, eliminando las barreras tradicionales entre el mundo xBase y el ecosistema moderno de Apple.

*   **Universal Dispatcher 2.0 (Type-Agnostic)**: Se ha eliminado totalmente la necesidad de pasar tipos de control al orquestador de ventanas. Ahora el bridge solo maneja IDs, delegando la identidad y el renderizado al registro universal de Swift.
*   **Geometría Reactiva en Tiempo Real**: Implementación de `ACCESS/ASSIGN` para `nTop`, `nLeft`, `nWidth` y `nHeight` en la clase base. Cualquier cambio en estas propiedades desde Harbour se refleja instantáneamente en la UI de SwiftUI sin parpadeos ni refrescos de ventana.
*   **Bridge Minimalista**: Reducción drástica del tráfico en el bridge. La función `SW_ADD_WINDOW_ITEM` ha pasado de 7 parámetros a solo **2 parámetros** (ID Ventana e ID Control), simplificando el mantenimiento y mejorando el rendimiento.
*   **Identidad en el Estado (hState)**: Cada componente nace ahora con su "mochila" de metadatos completa (`type`, geometría, estado), permitiendo que los controles sean entidades autónomas y self-positioning desde el primer milisegundo.
*   **Ventanas Swift Nativas**: La interfaz se construye directamente con el motor de Swift, permitiendo acceso a todas las capacidades modernas de macOS (Translucidez, animaciones fluidas, layouts dinámicos).
*   **Protocolo de Comunicación "Zero-Bridge"**: Se elimina la necesidad de `HarbourDirect` y de crear manualmente funciones puente para cada control. Todo fluye a través de un canal JSON unificado.
*   **Estado Sincronizado (Return Train)**: Swift notifica automáticamente a Harbour de cualquier cambio de estado, manteniendo los objetos de Harbour siempre sincronizados.

## 🏝️ Independencia de Build y Soporte SQLite Nativo (v2.0)
Hemos alcanzado un hito arquitectónico clave: el desarrollo de **"La Isla" (sw)** es ahora un ecosistema **totalmente autónomo e independiente**.

*   **Desacoplamiento Total**: Se han eliminado las dependencias de las librerías nativas legacy (`libfive.a`, `libfivec.a`) y MariaDB en el proceso de construcción de La Isla. El framework se compila ahora como una entidad ligera y moderna.
*   **Motor SQLite Nativo Directo**: Integración de un motor SQLite síncrono que ataca directamente la librería del sistema de macOS (`libsqlite3.dylib`). 
    *   **SwSqliteBridge.c**: Puente en C puro para máxima velocidad y mínima fricción.
    *   **TSwSqlite**: Clase Harbour portada para gestión de datos, navegación xBase y soporte de inserción mediante Hashes.
    *   **Zero-Dependency**: No requiere instalaciones externas; utiliza el motor residente y optimizado de macOS.
*   **Reducción de Puntos de Riesgo**: Saneamiento de las exportaciones `@_cdecl`. Funciones como `MSGBEEP` han sido refactorizadas para usar el despachador centralizado, mejorando la robustez futura del framework.
*   **Diálogos Nativos Directos**: Implementación de un canal de emergencia para mensajes (`SW_MSGINFO`) basado en `NSAlert` de Swift, garantizando la visibilidad de diagnósticos incluso si el pipeline de eventos principal no está disponible.

## 📝 Modernización de Motores de Edición
Gran salto adelante en las capacidades de edición de código:

*   **Scintilla 5**: Actualización del motor Scintilla al **Framework 5**, proporcionando mayor estabilidad y compatibilidad con las últimas APIs de macOS.
*   **Monaco Editor Integration**: Introducción del motor de edición Monaco (el corazón de VS Code) como alternativa de primer nivel.
*   **Extensión Harbour para Monaco**: Soporte nativo de sintaxis Harbour mediante extensiones dinámicas.
*   **Test Funcional desde CDN**: El motor Monaco y sus extensiones se cargan y testean directamente desde CDN, permitiendo pruebas instantáneas sin instalaciones complejas.
*   **Optimización del Symbol Navigator**: Rediseñado el navegador de funciones utilizando el nuevo componente nativo de selección filtrada.

## 🚀 Native ListBox & Selection Modernization
Hemos transformado el sistema de selección de listas para ofrecer una experiencia 100% macOS nativa y de alto rendimiento:

*   **Nuevo `MsgSelectList`**: Implementado como una función C pura en `listboxes.m`, eliminando redundancias y mejorando la estabilidad.
*   **Filtrado en Tiempo Real (Live Search)**: Integración de `NSSearchField` en el selector modal y soporte para ListBox standalone.
*   **Mapeo Inteligente de Índices**: El sistema traduce automáticamente la selección filtrada a la posición real del array original de Harbour, garantizando la integridad de los datos.
*   **TListBox Evolution**: Nueva metodología `:SetSearch( oSearch )` para conectar un campo de búsqueda a cualquier lista con una sola línea de código.

## 🛠️ Modern Event Dispatching & SwiftUI Registry
*   **Universal Event Portal**: Implemented a high-performance, centralized event dispatching system using `SwiftBridge` (Swift) and generic `SW_ONCHANGE`/`SW_ONACTION` (Harbour) handlers.
*   **UUID-based Registry**: Transitioned to an O(1) global Hash registry (`s_hRegistry`) for all SwiftUI controls, replacing inefficient array scans and ensuring reliable control lookup.
*   **State Synchronization**: Unified `OnChange` delegation across all text and value-based controls (Slider, Toggle, TextField, DatePicker, etc.), ensuring Harbour `DATAs` (`::lOn`, `::cText`, `::nValue`) are automatically synchronized with the native UI state.
*   **Architecture Refactoring**: 
    *   Standardized control lifecycle with `SwiftRegisterItem` and `SwiftUnregisterItem`.
    *   Genericized `OnAction` delegation for Buttons, Images, Lists, and Stacks, removing legacy control-specific callbacks.
    *   Implemented delegated event handling, shifting state management from global functions to individual control classes.
*   **Bug Fixes**: 
    *   Resolved critical closure-capture race conditions in Swift controls by enforcing pre-generation of UUIDs.
    *   Fixed asynchronous execution deadlocks in control creation via `Thread.isMainThread` checks and synchronous dispatching.

---

# Updates (March 2026)

### Native Network Modernization
- **High-Performance Network Engine**: Completely replaced the legacy `libcurl` dependency with a modern, native infrastructure based on Apple's **Foundation** (`NSURLSession`) and **Network** frameworks.
- **Memory Safety & Stability**: Fixed critical memory leaks in the Objective-C layer related to semaphores, `NSURL` objects, and screen capture buffers. The new engine is 100% leak-free and thread-safe.
- **Unified API (Zero-Transition Path)**: Introduced two twin classes that share the exact same API, allowing seamless switching between native Objective-C and modern Swift backends:
    - **`TNetwork`**: High-level Harbour wrapper for the native Objective-C implementation.
    - **`TSwiftNetwork`**: High-level Harbour wrapper for the modern Swift implementation with automatic JSON-to-Hash decoding.
- **Full REST Support**: Both engines now support the complete set of HTTP methods: `GET`, `POST`, `PUT`, and `DELETE`.
- **Advanced Features**:
    - **Custom Headers**: New `SetHeader( cKey, cValue )` method to support modern APIs requiring `Authorization: Bearer` tokens and other custom metadata.
    - **JSON-to-Hash Bridging**: Native Swift implementation automatically decodes HTTP JSON responses into Harbour Hashes/Arrays, eliminating manual string parsing.
    - **Smart File Operations**: Robust `Download( cUrl, cFile )` and `Upload( cUrl, cFile )` methods with automatic file collision handling.
    - **Robust Connectivity**: Standardized `IsConnected()`, `GetIP()`, `GetPublicIP()`, and `GetMac()` methods.
- **Production-Ready Defaults**: All requests now include a standard Chrome-like **User-Agent** to avoid blockages from strict servers (like INE) and a default 30-second timeout.

### SwiftUI Expansion & Speech Recognition
- **Comprehensive SwiftUI Bridge Refactor**: 
    - **UUID-based Registry**: Migrated the internal UI registry to a robust UUID system (`SWIFT_UUID`). This ensures absolute uniqueness and reliability for event tracking in complex layouts.
    - **Memory Safety**: Optimized object lifecycle management and C-bridge logic, resolving critical "excessive recursion" crashes during callback assignments.
- **Advanced Speech Engine (`TSwiftSpeech`)**:
    - **Real-Time Transcription**: High-performance, low-latency live speech-to-text with partial result reporting.
    - **Vocal Metrics**: Native extraction of acoustic features: **Pitch**, **Jitter**, and **Shimmer** (requires macOS 11.3+).
    - **File Recording**: New `RecordToFile( cPath )` method to save voice sessions directly to high-quality compressed AAC files.
    - **File Transcription**: New `TranscribeFile( cPath )` to asynchronously process existing audio files and return full text transcripts.
- **SwiftUI Refinement & Date Support**:
    - **SwiftDatePicker**: New native SwiftUI date selector featuring locale precision (`es_ES`) for Day/Month/Year formatting.
    - **SwiftPicker Refinements**: Fixed layout logic and placeholder restoration.
    - **Direct Bridge Architecture (@HarbourDirect)**: Architectural milestone allowing Swift code to talk directly to Harbour C-API bypassing Objective-C wrappers.

### Memory Optimization & Plist Enhancements
- **Memory Leak Resolution (Browse)**: Fixed leak where `NSTableColumn` objects were not being released.
- **Enhanced Plist Engine (`TPlist`)**: Atomic, binary-safe writing of `.plist` files and improved lifecycle management.
- **TArray Class Refinements**: Native bridge for high-performance array manipulation with automatic type detection.
- **Control Lifecycle**: Updated `TControl:End()` to guarantee `ViewEnd()` is called.

---

# Updates (February 2026)

### Real-Time Object Inspector (Prototype)
- **Deep Hierarchy Discovery**: New tree-traversal logic that recursively explores both `aControls` and `aViews` arrays.
- **Live Property Editing**: Immediate visual feedback when editing geometry (Top, Left, Size), aesthetics (Colors) and content.
- **Lifecycle Management**: Singleton pattern to prevent UI duplication.

### MusicKit & Modern UI
- **MusicKit Integration**: Full integration with Apple's `MusicKit` framework. Supports Playback control, Metadata & Artwork retrieval.
- **Polished UI Components**: Enhanced `TSwiftButton` with SF Symbols support and circular shapes. `TSwiftImage` with dynamic file-based updates.
- **TCVBrowse**: Completely rewritten Image Browser component using `NSCollectionView` and Diffable Data Sources.

### Advanced Image Utilities
- **Native QR Code Generation**: New `SIMAGEGENQR` function for high-quality QR code generation.
- **Vision Framework (OCR)**: New `NSIMGTEXTOCR` function to extract text directly from images.
- **Advanced Image Filters**: Layer-based filter stacking mechanism allowing multiple Core Image filters simultaneously.
- **Quartz Cleanup**: Migrated to modern **PDFKit** and retired deprecated Quartz-based components (CoverFlow).

### System & Architecture
- **Excel integration**: Advanced Excel Writer (`hbxlsxwriter`) with UDC commands and Image Deduplication (MD5). Native Excel Reader (`XLSXReader`) in pure Harbour.
- **Audio Processing**: Refactored to use modern **AVFoundation** APIs with live streaming metadata support.
- **Glassmorphism**: Native macOS Vibrancy support for translucent "Glass" interfaces.
- **MapKit Integration**: Support for interactive maps, routing, POIs and custom annotations.

---

# Updates (January 2026)

### Core Components
- **New SplitBox Control**: Completely rewritten splitter using native `NSSplitView`. Robust alternative to legacy `TSplitter`.
- **Fivedit Evolution**: Integrated Manual Search, Smart Auto-Indentation and Monaco Editor support.
- **IntelliSense & Snippets**: VSCode-style snippets and icon-aware Autocomplete for Harbour functions.

### Database & Data
- **SQLite & MySQL**: Standardized xBase API for record navigation and Hash-based inserts. Native 64-bit SQLite integration.
- **Browse & Data Management**: Pointer stabilization and UI/DBF synchronization fixes for `TWBrowse`.

### Graphics & Architecture
- **TBrush Engine**: Support for gradients, patterns and CALayer-aware coloring.
- **64-bit Architecture**: Refactored entire `winapi` layer for absolute 64-bit stability across modern macOS.
- **Visual Designer**: Major overhaul of `TForm` resizing and geometry logic using the new `TRect` class.

### SwiftUI Integration (Phase 1)
- **Batch Registration API**: Optimized JSON-based transactions for high-performance UI population.
- **Aesthetics & Styling**: Premium semi-bold fonts, linear gradients and glassmorphism support for Swift controls.
- **Glass & Sidebar**: Full support for translucent windows and sidebars with Frosted effects.

---

## Building

To build the library and samples:

1. Ensure you have Xcode Command Line Tools installed.
2. Run `make` to build the `libfive.a` and `libfivec.a` libraries.
3. Use `./build.sh <samplename>` in the `samples` directory to build specific applications (e.g., `./build.sh fivedit`).

## Documentation

See `whatsnew.txt` for a detailed history of changes and new features.
