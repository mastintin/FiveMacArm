# FiveMac Development Tasks (January 2026)

## Browse & Data Persistence
- [x] Fix `TWBrowse` record synchronization (WM_BRWCHANGED).
- [x] Implement Pointer Stabilization in `GetValue` (Save/Restore RecNo).
- [x] Integrate `TScintilla:IsModify()` for auto-saving scripts.
- [x] Fix Browse Keyboard Navigation.

## Graphics & UI Engine
- [x] Implement `TBrush` class (Solid, Pattern, Gradient).
- [x] Fix `TBrush:New()` to handle numeric colors correctly.
- [x] Modernize Window Backgrounds: Implement `CALayer` support in `WNDSETBKGCOLOR`.
- [x] Ensure `WNDSETCOLOR` is layer-aware for both windows and views.
- [x] Fix `DEFINE DIALOG` macro in `FiveMac.ch` to properly pass Brush objects.
- [x] Remove deprecated `WNDSETRESIZEINDICATOR`.

## Fivedit Enhancements
- [x] Implement manual toolbar search (Magnifying glass click).
- [x] Fix Goto Line crash and focus issues.
- [x] Redesign Replace Dialog and implement Wrap Around logic.
- [x] Modernize toolbar with SF Symbols (`ImgSymbols`).

## Build & Samples
- [x] Update `makefile` for ARM64 and modern SDKs.
- [x] Create `testbrush.prg` and `testbrw.prg` for verification.
- [x] Verify `scripts.prg` with auto-save and complex backgrounds.
