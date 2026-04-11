# FiveMac

FiveMac is a powerful GUI library for **Harbour** that allows you to create native macOS applications using the Cocoa framework.

## Overview

FiveMac bridges the gap between xBase/Harbour code and the native macOS Objective-C API, providing a rich set of classes (Windows, Dialogs, Controls, Browsers, Scintilla Editors) to build modern Mac apps.

## Recent Updates (January 2026)

### SplitBox Control & FiveEdit Integration
- **New SplitBox Control**: Completely rewritten splitter component (`TSplitBox` and `FMSplitView`) using native `NSSplitView`. This offers a significantly more robust and reliable implementation than the legacy `TSplitter`.
- **FiveEdit Modernization**: FiveEdit now uses the new `SplitBox` control for its main layout panels, improving resizing stability and visual consistency. The new control fully supports automatic resizing (`AUTORESIZE`), dynamic pane addition (`SetPane`, `AddView`), and standard FiveMac flipped coordinates.

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
- **MySQL**: Enhanced `TMySQL` class with standard Harbour `hbmysql` library support.
    - **Standardized API**: Improved `Query()` to correctly handle metadata (record and field counts) using official `LastRec()` and `FCount()` methods.
    - **Command Execution**: Introduced `Execute( cSql )` for direct SQL command execution without result sets.
    - **CRUD Sample**: New comprehensive sample `testmysql_browse.prg` demonstrating a modern Browse-based CRUD interface with MySQL.
    - **xBase Navigation**: Full support for `GoTop()`, `GoBottom()`, `Skip()`, `RecNo()`, and `RecCount()` on MySQL result sets.

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

### Fivedit Location & Build System (January 2026 - Part 6)
- **Repo Structure**: `fivedit` has been moved to its own directory `samples/fivedit/` to better organize its growing codebase and resources.
- **Build Robustness**: Fixed critical issues in `CreaBuilder.prg` and `Info.plist` generation ("App Damaged" errors) by ensuring `CFBundleExecutable` contains only the filename and using relative paths for bundle creation. 
- **Self-Healing Environment**: `NewFile` in Fivedit now automatically detects and creates missing indexes (`scripts.cdx`) for the template database, preventing runtime errors on fresh installs.
- **Script Engine**: Corrected various path resolution issues in `RunScript` and `BuildApp` to support the new directory structure.

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
    - **Interactivity**: Native click support for all# FiveMac Framework - Modernization Log

## 🚀 Native ListBox & Selection Modernization (Abril 2026)
Hemos transformado el sistema de selección de listas para ofrecer una experiencia 100% macOS nativa y de alto rendimiento:

*   **Nuevo `MsgSelectList`**: Implementado como una función C pura en `listboxes.m`, eliminando redundancias y mejorando la estabilidad.
*   **Filtrado en Tiempo Real (Live Search)**: Integración de `NSSearchField` en el selector modal y soporte para ListBox standalone.
*   **Mapeo Inteligente de Índices**: El sistema traduce automáticamente la selección filtrada a la posición real del array original de Harbour, garantizando la integridad de los datos.
*   **TListBox Evolution**: Nueva metodología `:SetSearch( oSearch )` para conectar un campo de búsqueda a cualquier lista con una sola línea de código.
*   **Optimización del Editor Monaco**: Rediseñado el "Symbol Navigator" (Navegador de Funciones) utilizando el nuevo componente nativo, simplificando drásticamente el código fuente del usuario.

---

# Fivemac
Framework de desarrollo para Mac con Harbour
 codeblocks.
    - **HStack Rows**: Support for complex rows containing Icons + Text with proper alignment.
    - **TSwiftZStack**: New Layered control for overlaying content (Images beneath Text), supported by `TestSwiftZStack.prg`. Supports both SF Symbols and File Images.

### SwiftUI Integration & Aesthetics (January 2026 - Part 8)
- **Batch Registration API**: Radical performance improvement for large lists. Developers can now use `AddItem()` and `AddBatch()` to create thousands of UI elements (Text, Buttons, Stacks) in a single optimized JSON-based transaction.
- **Premium UI Styling**: Overhauled the default aesthetic for SwiftUI Buttons. Buttons now feature a modern semi-bold font, consistent padding, linear gradients, and subtle drop shadows out-of-the-box.
- **Aesthetic Parameters**: The Batch API now supports per-item customization:
    - **Custom Colors**: Pass `nClrFore` and `nClrBack` to `AddItem` to override default styles.
    - **Alpha Transparency**: Full support for `nAlphaFore` and `nAlphaBack` (0.0 to 1.0) for sophisticated layering and glassmorphism effects.
- **TSwiftList**: Simplified root list control that inherits from `TSwiftVStack`, optimized for high-performance data display using the new Batch API.
- **Unified Action Bridge**: Centralized the `SwiftOnAction` callback mechanism to handle all button and interaction events across different Swift views, improving reliability and simplifying registration.

### Glass Window & Sidebar Support (January 2026 - Part 9)
- **Glass Effect**: Added full support for modern macOS "Glass" windows (translucent title bars and sidebars).
    - **TWindow**: New property `lGlass` enables the `NSWindowStyleMaskFullSizeContentView` and transparent title bar style.
    - **WNDGETGLASS**: New C function to query the Glass state of any window handle.
- **TSidebar**: New dedicated class in `panel.prg` for building standard macOS sidebars. Inherits from `TPanel` but optimized for full-height, translucent "Vibrancy" effects.
- **Shadow Fix**: Resolved a critical crash when using `SetShadow()` on `NSView` subclasses (like Panels). Moved the safe implementation to `TControl`, ensuring all custom views can have shadows without conflicting with `TWindow`'s shadow logic.
- **Library Stability**: Fixed compilation issues in `FiveMac.ch` related to optional command clauses, ensuring robust builds.

### ViewStack & Modern Browsing (January 2026 - Part 10)
- **TViewStack**: New native control for building modern, multi-view interfaces (like segmented views or tab replacements).
    - **ViewStackBar**: A stylish, floating "capsule" navigation bar using `NSVisualEffectView` with rounded corners (16px) and vibrancy support. Supports customization via `SetColor()`.

### Popover & Swift Integration Refinements (January 2026 - Part 11)
- **Popover Mechanism**:
    - **Robust Positioning**: Completely rewrote `popover.m` to use **Window-Relative** coordinates for anchor calculation. This fixes visibility issues when popovers are triggered from deeply nested views (e.g., inside SplitViews or Flipped Panels).
    - **Styling**: Refined default padding and minimum size constraints for a cleaner, native look.
    - **Event Routing**: Implemented `setOriginalWindow` propagation to ensure events (like button clicks) inside popovers are correctly routed back to the main Harbour event loop.
- **SwiftButton**:
    - **Stability**: Updated `SwiftButton.m` to use 64-bit pointer returns (`hb_retnll`) instead of 32-bit (`hb_retnl`), preventing potential crashes on modern architectures.
    - **Cleanup**: Removed verbose debug logging (`SWIFTBTNCREATE`) for a silent production experience.
- **Documentation**: Updated `task.md` and `walkthrough.md` to reflect the current stable state of the library.


### SwiftUI & Focus Reliability (January 2026 - Part 12)
- **SwiftPicker**: New native picklist component with integrated search, scrollable popover, and dynamic label support (`SWIFTPICKER` command).
    - **Delayed Editor Focus**: Enhanced `TWBrowse:Edit()` logic to ensure the inline text editor receives focus correctly, bypassing OS event race conditions.
    - **Global Activation**: Modified `CocoaInit` to explicitly activate the application (`activateIgnoringOtherApps:YES`), ensuring keyboard focus on launch and when switching windows.
- **Browse Safety**: Changed default column behavior to non-editable. Editing now requires explicit `SetColEditable()` per column, preventing unintended data entry during standard navigation.
- **Popover UX**: Adjusted popover presentation to appear below controls (`NSMaxYEdge`) for better visibility in complex layouts.

### NiceGUI Wrapper (January 2026 - Part 13)
- **Hybrid Framework**: Introduced a NiceGUI-inspired wrapper for building modern, reactive UIs using Vue.js and Quasar components within native FiveMac windows.
- **Modular Architecture**: Ported to a clean multi-file structure: `NiceCore`, `NiceLayout`, `NiceControls`, `NiceTable`, and `NiceDialog`.
- **xBase Syntax**: New intuitive preprocessor commands in `Nice.ch` (`NICE GET`, `NICE SAY`, `NICE BUTTON`, `DEFINE NICE TABLE`, etc.).
- **Data Table**: High-performance `TNiceTable` for displaying complex Harbour data with automatic JSON serialization and column width control.
- **Offline Reliability**: Full support for self-contained, offline operation by bundling Vue/Quasar/Material Icons resources within the App's `.app` bundle.
- **Build System**: New `build_app.sh` script for packaging hybrid apps and `makelib.sh` for generating the static library `libnice.a`.
- **Hybrid Dashboard**: High-level commands for building navigation-driven apps with multiple cards, KPIs and responsive sidebars.

### NiceGUI Sidebar & Advanced Borders (January 2026 - Part 14)
- **Navigation Sidebars**: New `NICE DRAWER` and `NICE DRAWER ITEM` commands for building modern, desktop-style dashboards. Supports "Push" layout mode to prevent content overlapping.
- **Advanced Card Styling**: Enhanced `DEFINE NICE CARD` with granular border control:
    - **Single-Side Borders**: Specify `SIDE "left"`, `SIDE "top"`, etc., for decorative colored frills.
    - **Radius & Borders**: Custom corner rounding and colored border width support.
- **Direct JS Actions**: Added `JS` clause to buttons and items for high-performance, lag-free client-side interactions (e.g., toggling menus instantly).
- **Offline Reliability**: Automated fallback to local `nicegui_dist` assets for icons and framework dependencies.
- **Layout Precision**: Fine-tuned WebView height calculation to ensure pixel-perfect Footer alignment in `FLIPPED` window modes.

### Architecture (January 2026)
- **64-bit Core**: Finalized pointer size migration for button and picklist handles to ensure absolute stability on modern macOS.
- **WebView Bridge**: Specialized JavaScript-to-Harbour communication bridge for bidirectional events and reactive state updates.

## Recent Updates (February 2026)

### Real-Time Object Inspector (Prototype)
> [!IMPORTANT]
> This feature is currently an **unfinished prototype**. While functional, it is intended for developer preview and may undergo significant internal changes.

- **Deep Hierarchy Discovery**: New tree-traversal logic that recursively explores both `aControls` and `aViews` arrays. This ensures visibility into complex containers like Panels, SplitViews, and TabViews.
- **Live Property Editing**: ⚡ Immediate visual feedback when editing properties in the inspector grid:
  - **Geometry**: Real-time updates for `nTop`, `nLeft`, `nWidth`, and `nHeight` via native `SetPos` and `SetSize` methods.
  - **Aesthetics**: Support for `nClrText` and `nClrBack` across all controls (Panels, Buttons, Gets).
  - **Content**: Safe, polymorphic text editing for Windows and Controls (`cText`, `cTitle`) with automatic Harbour variable (`bSetGet`) synchronization.
- **Lifecycle Management**: Implemented a **Singleton pattern** for the `Inspector()` function to prevent UI duplication and ensure stable window management.
- **Improved Filtering**: Logic to prevent the inspector from inspecting itself, ensuring a clean and focused debugging experience.

### TSplitter API Simplification
- **Simplified Provisioning**: New `SetPane( nPane, oControl, lFill )` method that automates the complex process of embedding controls into split views. It handles:
  - Parenting and view hierarchy registration.
  - Automatic positioning at (0,0) of the subview.
  - Optional full-pane filling with `AUTORESIZE` pre-configured.
- **Improved Access**: New `View( n )` helper to safely access child views by index.
- **Clean Architecture**: Refactored `TSplitItem` to remove redundant data, improving memory efficiency and class consistency.

### Reporting & Swift Enhancements (Part 15)
- **Advanced Reporting (NiceGui)**:
    - **Image Embedding**: New `TNiceImage` class supporting both local paths and Base64-encoded images (`DEFINE NICE IMAGE`).
    - **PDF Generation**: Improved rendering engine (`TNicePrinter`) with support for high-fidelity HTML-to-PDF conversion including embedded charts and images.
- **SwiftUI Integration**:
    - **SwiftGrid**: Fixed row indexing and state management for reliable data display. Added native "Zebra Striping" for better readability.
    - **SwiftPDF**: Enhanced `ImageRenderer` logic for pixel-perfect PDF output from SwiftUI views.
- **TSQLite xBase Enhancements**:
    - **xBase Navigation**: New methods `GoTop()`, `GoBottom()`, `Skip()`, `EOF()`, `RecCount()`, and `RecNo()` for table-based navigation.
    - **Data Mutation**: Implemented `DbAppend()`, `DelRecord()`, and `FieldPut()` for DBF-like record management.
    - **Smart Field Mapping**: `FieldPutName( cName, uVal )` and `FieldGetName( cName )` for case-insensitive column access by name.
    - **Hash-based Insert**: `Insert( cTable, hData )` for efficient record insertion using Harbour Hashes.
    - **Natural Language Commands**: New `sqlite.ch` header defining intuitive xBase-style commands:
        - `SQLITE CONNECT ... CREATE INTO ...`
        - `SQLITE USE ... ORDER ...`
        - `SQLITE APPEND`
        - `SQLITE REPLACE ... WITH ...`
        - `SQLITE DELETE`
        - `SQLITE INSERT INTO ... HASH ...`

### MusicKit & Modern UI (Part 16)
- **MusicKit Integration**: Full integration with Apple's `MusicKit` framework via a hybrid Swift/Objective-C/Harbour bridge.
    - **Playback Control**: Native control over the Music app (Play, Pause, Next, Previous, Stop) with real-time state synchronization.
    - **Metadata & Artwork**: seamless retrieval of Song Title, Artist, Duration, Position, and Album Artwork.
    - **Hybrid Architecture**: Uses a robust mix of Swift (for modern APIs) and optimized AppleScript (for legacy control) to bypass signing restrictions in ad-hoc builds.
- **Polished UI Components**:
    - **TSwiftButton**: Enhanced with **SF Symbols** support (`SetImage`), circular shapes (`SetRadius`), and custom background/foreground colors.
    - **TSwiftImage**: Improved image handling with `SetFile` to bypass caching and support dynamic artwork updates.
    - **TSwiftLabel**: Modern label control with support for large fonts and custom styling.
- **TestMusicKit Sample**: A new flagship sample application (`SwiftUI/samples/TestMusicKit.prg`) demonstrating a modern, vertical music player interface with:
    - Large 300x300 artwork display.
    - Real-time progress slider and timer-based updates.
    - Smart Play/Pause toggle button with state-aware icon switching.
- **Build System**: Updated `build_lib.sh` and `build.sh` to correctly link `MusicKit`, `SwiftUI`, and `Combine` frameworks, ensuring smooth compilation on macOS 14+.
    - **Layout**: Flexible architecture allowing views to be added dynamically.
- **TCVBrowse**: A completely rewritten Image Browser component.
    - **Modern Backend**: Replaces the legacy `IKImageBrowserView` with `NSCollectionView` and Diffable Data Sources for stability and performance.
    - **Features**: Supports selection callbacks (`bChange`), double-click actions (`bLDblClick`), and Core Animation effects ("Pulse" on selection).
    - **Visuals**: Clean grid layout with customizable item sizing.
- **Cleanup**: Extensive removal of debug logs (`NSLog`, `MsgInfo`) across the library ensuring a production-ready build.

### Quartz Cleanup & Modernization (February 2026 - Part 17)
- **PDFKit Migration**: Migrated `PDFView` from the deprecated Quartz framework to the modern **PDFKit** framework.
    - Updated `pdfviews.m` to import `<PDFKit/PDFKit.h>`.
    - Updated build scripts to link `PDFKit.framework`.
    - Verified with `testpdf.prg`.
- **Quartz Framework Removal**: Replaced the deprecated `-framework Quartz` with `-framework QuartzCore` in build scripts.
    - This retains Core Animation capabilities (gradients, shadows) while removing unused legacy dependencies.
    - Cleaned up `funcs.m` by removing `Quartz/Quartz.h` imports.
- **SF Symbols Integration**: Enhanced `NSIMAGEFROMNAME` in `images.m` to automatically fallback to **SF Symbols** if a local image file is not found.
    - Allows using system icons like `"gear"`, `"folder"`, `"trash"` directly in `DEFINE BUTTON ... IMAGE "name"`.
- **CoverFlow Removal**: Removed the deprecated `IKImageFlowView` (CoverFlow) component and its associated files (`testcovf.prg`, `coverflow.prg`, `coverflows.m`) to ensure compatibility with future macOS releases.
- **ImageBrowser Migration**: Replaced `IKImageBrowserView` (ImageKit) with `NSCollectionView` (AppKit) via `cvbrowser.m`.
    - Deleted obsolete `IKImabr.m`.
    - Maintained API compatibility with `TCVBrowse` / `IKImgBr*` functions.
    - Verified with `testcv.prg`.
- **Image Editing Removed**: Replaced `IKImageView` (ImageKit) with `NSImageView` (AppKit) in `simages.m`.
    - Removed dependency on deprecated `Quartz` framework.
    - **Note**: Built-in interactive cropping and editing tools are no longer supported.
    - Added basic image rotation support via `NSAffineTransform`.
    - Verified with `testsimage.prg`.
- **TestPDF Updated**: Refactored `nativo/samples/testpdf.prg` to demonstrate:
    - Loading local PDF files via `cGetFile`.
    - Using SF Symbols for toolbar navigation icons.

### Advanced Image Filters (February 2026 - Part 18)
- **Multiple Filter Stack**:
    - **Layer-Based Stacking**: Implemented a robust filter stack mechanism allowing multiple Core Image filters (e.g., Color Controls + Comic Effect + Sepia) to be applied simultaneously to an image layer.
    - **Non-Destructive Chain**: Filters usually process the output of the previous one, enabling complex visual effects pipelines.
    - **Refactored `TCIFilter`**: Updated class to manage an internal array of filter handles, with methods `Add()`, `Clear()`, and `GetValue( nIndex )` for precise control.
- **Synchronized Adjustments**:
    - **Real-Time Sliders**: `testsimage.prg` now demonstrates synchronized Brightness, Contrast, and Saturation sliders. Adjusting one parameter maintains the state of others without resetting the filter.
    - **Smart Reset**: "Reset Values" button restores default parameters (0/1/1) while preserving other active effects in the stack.
- **Core Optimization**:
    - **Forced Layer Refresh**: Implemented filter cloning (`[filter copy]`) in `SIMAGESETFILTERSTACK` to bypass `CALayer` caching. This ensures immediate visual updates even when reusing the same filter objects.
    - **API Consistency**: Refactored `cifilters.m` and `objc.m` to use `HB_LONGLONG` for all object handles, aligning Core Image integration with the standard FiveMac 64-bit architecture.

### QR Code & System Modernization (February 2026 - Part 19)
- **Native QR Code Generation**:
    - **SIMAGEGENQR**: New C function `SIMAGEGENQR( cText, nScale )` that generates high-quality QR codes using `CIQRCodeGenerator`.
    - **Automatic Scaling**: The function automatically scales the vector output to a usable bitmap size, ready for display in `SIMAGE` controls.
    - **Demo**: Added `testqr.prg` sample application to demonstrate real-time QR code generation from user input.
- **Messaging Architecture**:
    - **Smart OBJC_MSGSEND**: Enhanced `OBJC_MSGSEND` in `objc.m` to use `NSMethodSignature` for runtime type introspection. It now automatically detects if a selector expects an object (`@`) or a class (`#`) argument and correctly casts numeric handles to pointers (`id`). This eliminates the need for manual casting or specific function wrappers for most Cocoa interactions.
    - **TSimage Enhancement**: Added `SetImage( hImage )` method to `TSimage` class, now fully supported by the improved messaging system.
- **Legacy Cleanup**:
    - **Modern File Dialogs**: Removed all deprecated `setAllowedFileTypes:` calls and `@available` checks from `simages.m`. The library now exclusively uses the modern `UTType` API (macOS 11.0+) for file opening and saving operations, ensuring future compatibility.

### Glassmorphism & Translucency (February 2026 - Part 20)
- **Native macOS Vibrancy**: Implemented robust support for macOS `NSVisualEffectView` to create modern, translucent "Glass" interfaces that automatically adapt to light and dark modes.
- **Window Level Glass**: `DEFINE WINDOW ... GLASS` applies a "Behind Window" blending mode for full-window frosted effects.
- **Control Level Glass**: Extended support to dynamically apply "Within Window" blending to various UI components using the `GLASS` or `LIQUID GLASS` clauses.
    - Supported controls include: `PANEL`, `GROUP`, `MULTIGET`, `GET`, `SAY`, and `BUTTON`.
    - Example: `@ 20, 20 PANEL oPanel SIZE 300, 300 OF oWnd GLASS`
- **Architecture Improvements**: 
    - Refactored `TPanel:New()` to natively accept `nAutoResize`.
    - Stabilized `FiveMac.ch` macros (`#xcommand`) for `PANEL`, `GROUP`, and `MULTIGET` using robust multi-line expansions. This resolves long-standing Harbour parsing ambiguities and syntax errors when certain optional clauses were omitted.
    - Simplified rendering pipeline by routing all `LIQUID GLASS` aliases to uniform native C/Objective-C functions (`VIEWSETLIQUIDGLASS`, `WNDSETGLASS`, `BTNSETGLASS`).

### MapKit, Vision OCR & Advanced Symbols (February 2026 - Part 21)
- **TNativeMap (MapKit Integration)**: Complete native implementation of Apple's MapKit framework.
    - **Interactive Maps**: Support for displaying Standard, Satellite, and Hybrid maps.
    - **Geocoding & POI**: Integrated Points of Interest (POI) search and direct address geocoding (`MKMAPGOTOLOCATION`).
    - **Routing & Navigation**: Real-time route generation (`MKMAPSHOWROUTE`) with detailed step-by-step turn instructions, distance, and duration callbacks.
    - **Custom Annotations**: Support for custom map pins (`MKMAPSETANNOTATIONICON`, `MKMAPSETANNOTATIONCOLOR`) and handling annotation selection events.
    - **Camera Control**: Advanced 3D camera controls for setting Pitch, Heading, and Zoom levels.
- **Vision Framework (OCR)**: 
    - **Text Recognition**: New `NSIMGTEXTOCR` function to extract text directly from images using Apple's native Vision framework. Features a sample `testocr.prg` demonstrating image selection and text extraction.
- **Advanced SF Symbols**:
    - **Color Configurations**: Enhanced `TSFSymbol` and native functions to support `NSImageSymbolConfiguration` with Palette and Hierarchical color modes. Allows for multi-colored system icons directly from Harbour.
- **Word Document Support**:
    - Added `GELOADRTF` and `GESAVERTF` capabilities in the Rich Text/Memo controls to natively open and save `.doc` and `.docx` files using standard macOS text frameworks.

### Audio Processing & TNativeAudio (February 2026 - Part 22)
- **TNativeAudio Modernization**: Completely refactored the native audio engine to use modern **AVFoundation** APIs, ensuring full compatibility with macOS 15+ and 64-bit architectures.
- **High-Performance Streaming**: New `Stream( cUrl )` method using `AVURLAsset` for robust internet radio and HLS stream playback. Automatically handles URLs without file extensions.
- **Modern Metadata Engine**: Migrated from deprecated properties to the asynchronous `AVPlayerItemMetadataOutput` API.
    - **Live Updates**: Real-time extraction of Artist and Song Title from live streams using an optimized Objective-C delegate.
    - **Smart Parsing**: Automatically detects and splits "Artist - Title" strings from mixed metadata sources.
    - **Zero Warnings**: Replaced all obsolete `timedMetadata` calls, ensuring a clean and future-proof build.
- **Event Synchronization**: Integrated `IsPlaying()` and `IsReady()` (buffering detection) for precise UI control. Improved auto-play logic and buffering state visual feedback.
- **Memory Safety**: Implemented `objc_setAssociatedObject` to link metadata delegates directly to the `AVPlayer` lifecycle, preventing memory leaks and ensuring clean resource management.
- **New Sample**: `StreamPlayer.prg` demonstrating a professional internet radio player with real-time metadata display and volume control.

### Excel Integration (February 2026 - Part 23)
- **Advanced Excel Writer (`hbxlsxwriter`)**:
    - **UDC Command System**: Introduced a simplified command-based API in `xlsxCmd.ch` (e.g., `CREATE XLS BOOK`, `ADD SHEET`, `@ row, col XLS WRITE`).
    - **Formula Support**: Full support for Excel formulas including absolute references (e.g., `XLS FORMULA "=A:1 + $B:$5"`).
    - **Alias System**: Use `BOOK` and `SHEET` as shorter aliases for `WORKBOOK` and `WORKSHEET`.
    - **Column Referencing**: Support for both numerical indices and Excel-style column letters (e.g., `"A"`, `"BC"`).
- **Native Excel Reader (`XLSXReader`)**:
    - **Pure Harbour Implementation**: Integrated a robust `.xlsx` reader class (`XLSXReader`) directly into the library.
    - **Feature Rich**: Supports reading cell values, shared strings, and basic formatting metadata without external dependencies besides ZIP support.
    - **Performance**: Optimized for large files with progress callback support.
- **Build Integration**: Standardized `Makefile` for the wrapper and automated build scripts (`build_xlsx.sh`) to link all required compression libraries (`hbziparc`, `zlib`).

### Modular Extras & Advanced Imaging (March 2026 - Part 25)
- **New Modular Build System**: Introduced the `extras` directory with an independent `Makefile`. This allows for clean, separate building and maintenance of third-party libraries (`libxlsxwriter`, `expat`, `xlsxio`) without cluttering the core FiveMac build scripts.
- **Enhanced Excel Engine (`libxlsxwriter`)**:
    - **MD5 Image Deduplication**: Highly optimized image handling. Utilizing a global MD5 hashing mechanism, the library now automatically detects duplicate images. When the same image is inserted multiple times (e.g., a company logo on many rows), it is stored only once in the `.xlsx` bundle, resulting in massive file size savings for image-heavy reports.
    - **Robust Command Set**: Improved `xlsxCmd.ch` with intelligent defaulting. Commands like `DEFINE WORKSHEET` no longer require an explicit `OF oXlsx` clause if a standard `oXlsx` workbook object exists, simplifying developer code.
    - **Direct Image Insertion**: New `XLSX INSERT IMAGE` command with support for complex positioning and scaling.
- **Improved 64-bit Core**: Unified MD5 implementations across the library (`Md5Wrappers.m`) to ensure consistent behavior between different modules and third-party libraries.
- **Maintenance**: Automated cleanup of legacy development folders and standardization of header include paths (e.g., `stdint.h` for ARM64 compatibility).

### SwiftUI Expansion & Speech Recognition (March 2026 - Part 26)
- **Comprehensive SwiftUI Bridge Refactor**: 
    - **UUID-based Registry**: Migrated the internal UI registry to a robust UUID system (`SWIFT_UUID`). This ensures absolute uniqueness and reliability for event tracking in complex layouts.
    - **Memory Safety**: Optimized object lifecycle management and C-bridge logic, resolving critical "excessive recursion" crashes during callback assignments.
- **Advanced Speech Engine (`TSwiftSpeech`)**:
    - **Real-Time Transcription**: High-performance, low-latency live speech-to-text with partial result reporting.
    - **Vocal Metrics**: Native extraction of acoustic features: **Pitch**, **Jitter**, and **Shimmer** (requires macOS 11.3+).
    - **File Recording**: New `RecordToFile( cPath )` method to save voice sessions directly to high-quality compressed AAC files.
    - **File Transcription**: New `TranscribeFile( cPath )` to asynchronously process existing audio files and return full text transcripts.
    - **Smart Locale Management**: Dynamic support for 50+ languages via `SetLocale( cId )`. Defaults to the user's system language (`Locale.current`).
- **Modern UI Components**:
    - **TSwiftTextEditor**: New multi-line text editor component ("Multiget" equivalent) in the SwiftUI bridge, supporting large text blocks with automatic scrolling.
    - **TSwiftTextField**: Enhanced with ID-based data retrieval and improved focus management.
    - **Architecture Improvements**: Unified common methods (`SetText`, `GetText`, `SetColor`, `SetRadius`) across all Swift input components.
- **Build System Modernization**:
    - **macOS 26.0 Target**: Updated `Makefile` and `BuildTest.sh` to target `macosx26.0` (Arm64), resolving all linker version mismatch warnings.
    - **Flag Standardization**: Unified `TARGET_FLAG` across Swift, Objective-C, and Harbour C compilation steps for a clean, warning-free build.
- **New flagship samples**:
    - `TestSpeechFile.prg`: Complete demonstration of the "Record -> Stop -> Select -> Transcribe" workflow with a multi-line editor.
    - `TestSpeech.prg`: Real-time analysis of voice metrics and transcription.
- `testdatepicker.prg`: Demonstration of the new native DatePicker with custom colors and Spanish format support.

### SwiftUI Refinement & Date Support (March 2026 - Part 27)
- **SwiftDatePicker**:
    - **Native Component**: New native SwiftUI date selector (`SWIFTDATEPICKER` command) featuring multiple styles.
    - **Locale Precision**: Forced `es_ES` locale support to ensure the date stepper always follows the **Day/Month/Year** order, regardless of system primary language.
    - **Async Callback Safety**: Re-engineered the communication bridge to Harbour. Callbacks are now systematically handled asychronously. This prevents critical system crashes (Segfault 11) when Harbour opens modal dialogs (like `MsgInfo`) during the native control's interaction tracking loop.
- **SwiftPicker Refinements**:
    - **Placeholder Restoration**: Re-implemented support for placeholders ("Seleccionar...").
    - **Title & Selection Visibility**: Fixed layout logic to ensure the selected item name is always visible alongside the label, providing immediate visual feedback.
- **Direct Bridge Architecture (@HarbourDirect)**:
    - **Native Swift-Harbour Bridge**: Significant architectural milestone. SwiftUI controls and Swift logic now communicate **directly** with the Harbour C-API, bypassing the need for Objective-C (`.m`) wrapper files as intermediaries. This results in a cleaner codebase, improved performance, and a seamless bidirectional relationship between the modern Swift ecosystem and the xBase layer.
    - **Streamlined Integration**: This allows Swift code to be exposed directly as Harbour-callable C functions, simplifying development and maintenance of modern UI components.
- **HBMISC Library Support**:
    - **System-Wide Linking**: Updated build scripts for native samples, SwiftUI samples, and the Fivedit editor to automatically link against the **`hbmisc`** Harbour library. This enables the use of miscellaneous Harbour utility functions across the entire ecosystem.

### Memory Optimization & Plist Enhancements (March 2026 - Part 28)
- **Memory Leak Resolution (Browse)**: Identified and fixed a critical memory leak in `browses.m`. `NSTableColumn` objects were being allocated without `autorelease`, causing a cumulative leak as columns were added to the browse.
- **Enhanced Plist Engine (`TPlist`)**:
    - **Stability**: Refined the `TPlist` class to ensure reliable file-based configuration management.
    - **Memory Safety**: Renamed `Destroy()` to `End()` for consistency with FiveMac standards and ensured native `DictRelease()` is called to prevent CoreFoundation object accumulation.
    - **Binary Writing**: Added `DICTWRITETOFILE` to the native layer, allowing for atomic, binary-safe writing of `.plist` files.
- **TArray Class Refinements**:
    - **Native Bridge**: Added `TARRAY_SET`, `TARRAY_DEL`, and `TARRAY_DELALL` to the Objective-C layer (`tarrays.m`) for high-performance array manipulation.
    - **Type Detection**: Implemented automatic Harbour-to-Cocoa type detection (String, Number, Logical) for native `Set()` operations.
- **Control Lifecycle**: Updated `TControl:End()` to guarantee `ViewEnd()` is called, ensuring native views are cleanly removed from the window hierarchy even if the parent window is `nil`.
- **Panel Stability**: Reinstated control registration logic in `TPanel:AddControl()` to ensure proper rendering of complex components like Browses.

### Native Network Modernization (March 2026 - Part 29)
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
- **New Samples**: Added `testnet.prg` (Native) and `TestSwiftNetwork.prg` (SwiftUI) for immediate developer reference.
- **Bug Fixes**: Resolved the long-standing `HOMEPATH` typo in `system.m` and introduced a convenient `HOME()` alias for executable path retrieval.

### Modern Event Dispatching & SwiftUI Registry (April 2026)
- **Universal Event Portal**: Implemented a high-performance, centralized event dispatching system using `SwiftBridge` (Swift) and generic `SW_ONCHANGE`/`SW_ONACTION` (Harbour) handlers.
- **UUID-based Registry**: Transitioned to an O(1) global Hash registry (`s_hRegistry`) for all SwiftUI controls, replacing inefficient array scans and ensuring reliable control lookup.
- **State Synchronization**: Unified `OnChange` delegation across all text and value-based controls (Slider, Toggle, TextField, DatePicker, etc.), ensuring Harbour `DATAs` (`::lOn`, `::cText`, `::nValue`) are automatically synchronized with the native UI state.
- **Architecture Refactoring**: 
    - Standardized control lifecycle with `SwiftRegisterItem` and `SwiftUnregisterItem`.
    - Genericized `OnAction` delegation for Buttons, Images, Lists, and Stacks, removing legacy control-specific callbacks.
    - Implemented delegated event handling, shifting state management from global functions to individual control classes.
- **Bug Fixes**: 
    - Resolved critical closure-capture race conditions in Swift controls by enforcing pre-generation of UUIDs.
    - Fixed asynchronous execution deadlocks in control creation via `Thread.isMainThread` checks and synchronous dispatching.

## Building

To build the library and samples:

1. Ensure you have Xcode Command Line Tools installed.
2. Run `make` to build the `libfive.a` and `libfivec.a` libraries.
3. Use `./build.sh <samplename>` in the `samples` directory to build specific applications (e.g., `./build.sh fivedit`).

## Documentation

See `whatsnew.txt` for a detailed history of changes and new features.
