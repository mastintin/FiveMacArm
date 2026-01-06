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

Changes Made
Core API Refactors & Fixes

funcs.m
Modernized SPEAK:

Switched back to AVSpeechSynthesizer (AVFoundation) to avoid deprecated APIs.
Fixed deallocation crash: Used a static instance of the synthesizer to ensure it stays alive while speaking.
Adjustable Rate: Added an optional second parameter rate. If values like 100/200 are passed, they are automatically scaled to the correct range (0.0 to 1.0) for the modern motor.
Improved FMSAVESCREEN logic:

Corrected the NSTask flow to allow setting the output pipe before launching, preventing a "Task already launched" error.
Added manual release for the task to prevent memory leaks.
Improved Memory & Safety:

Fixed memory management in SDKVERSION where a pointer was incorrectly reassigned and released.
Added safety checks in GETSERIALNUMBER to prevent passing NULL values.
Fixed Linker Errors for UserNotifications:

Updated 

samples/build.sh
 and 

samples/fivebuild.sh
 to include the -framework UserNotifications flag.
This resolves "Undefined symbols" errors for UNUserNotificationCenter and related classes when linking applications against libfivec.a.
Refactored AVTRIMMMOVIE in 

movies.m
:

Replaced deprecated exportPresetsCompatibleWithAsset: with modern asynchronous determineCompatibilityOfExportPreset:withAsset:outputFileType:completionHandler:.
Fixed deprecated method access for AVPlayerItem's reversePlaybackEndTime and forwardPlaybackEndTime, switching to property access.
Improved memory management by adding a proper release for the AVAssetExportSession within its completion block.
Updated Notification Presentation Options:

Replaced the deprecated UNNotificationPresentationOptionAlert with the modern UNNotificationPresentationOptionList | UNNotificationPresentationOptionBanner in both 

system.m
 and 

notifications.m
.
This ensures notifications continue to display correctly as banners and in the notification list on macOS 11.0 and later.
Refactored 

notifications.m
 (Full Migration to UserNotifications):

Replaced all usages of NSUserNotification and NSUserNotificationCenter with modern UNMutableNotificationContent and UNUserNotificationCenter.
Updated NotiDelegate to UNUserNotificationCenterDelegate, ensuring that the Harbour callback _FMN continues to work when notifications are clicked.
Implemented unique identifier management (UUID) within notification userInfo to allow for precise deletion and individual property updates.
Refactored NOTIFICREATE, NOTIFYDELIVER, NOTIFYDELETE, NOTIFYDELETEALL, and NOTIFIINTERVAL to align with the modern notification request-trigger-center workflow.
Refactored PROGRESSSETBEZELED in 

progress.m
:

Replaced the deprecated setBezeled: with a modern manual border simulation using CALayer.
When enabled, the control now gets a 1.0pt gray border via layer.borderWidth and layer.borderColor.
Refactored USERNOTIFICATION and FNotifyDelegate in 

system.m
:

Migrated from the deprecated NSUserNotificationCenter to the modern UserNotifications framework (UNUserNotificationCenter).
Updated FNotifyDelegate to implement UNUserNotificationCenterDelegate.
Added automatic authorization request handling within USERNOTIFICATION to ensure notifications are delivered on modern macOS versions.
Used UNMutableNotificationContent and UNNotificationRequest for standard notification delivery.
Refactored FM_OPENFILE in 

system.m
:

Replaced deprecated openFile: and openFile:withApplication: with modern openURL:configuration:completionHandler: and openURLs:withApplicationAtURL:configuration:completionHandler:.
Leveraged the AppURLFromAppName helper for consistent application resolution.
Used semaphores to bridge asynchronous Cocoa calls back to synchronous Harbour returns.
Refactored OPENFILEWITHAPP in 

system.m
:

Replaced deprecated openFile:withApplication: with the modern openURLs:withApplicationAtURL:configuration:completionHandler: API.
Extracted application resolution logic into a reusable helper function AppURLFromAppName, improving code maintainability.
Used semaphores to maintain synchronous behavior for Harbour compatibility.
Refactored MACEXEC in 

system.m
:

Replaced deprecated launchApplication:, fullPathForApplication:, and NSWorkspaceLaunchDefault with the modern openApplicationAtURL:configuration:completionHandler: API.
Implemented a robust URL resolution mechanism that finds applications by Bundle ID, absolute path, or name in standard locations (/Applications, etc.).
Used a semaphore to bridge the new asynchronous API back to a synchronous return, ensuring compatibility with Harbour's expectation of immediate results.
Refactored DOCKADDPROGRESS in system.m:

Replaced the deprecated setBezeled: with modern CALayer border simulation for the Dock progress indicator.
Updated progress style constants to modern Cocoa standards (NSProgressIndicatorStyleBar).
Refactored setControlTint functions (Codebase-wide):

Replaced the deprecated setControlTint: in both progress.m and browses.m with a dynamic CIFilter approach.
Graphite look: Uses a CIColorControls filter to desaturate the color of progress bars and scrollers, achieving the classic graphite appearance.
Blue/Default: Automatically removes filters to restore the native system accent color.
Infrastructure update: Integrated QuartzCore and CoreImage into the build to support these modern visual effects.
Modernized PRNSETPAPERNAME in printers.m:

Replaced the deprecated sizeForPaperName: with pageSizeForPaper: from NSPrinter.
Switched to using direct NSPrintInfo properties (setPaperName:, setPaperSize:) instead of manual dictionary manipulation.
Fixed Warning: Replaced the non-standard sharedPrinter with [[NSPrintInfo sharedPrintInfo] printer] to correctly retrieve the default printer without warnings.

[MODIFY] 
menus.m
Update MNUITEMSETIMAGE, MNUITEMSETONIMAGE, and MNUITEMSETOFFIMAGE to:
Support NSImage handles (numeric parameters).
Use autorelease for images loaded from files to fix existing memory leaks.
Maintain existing fallback to ImgTemplate for string parameters.
[MODIFY] 
menuitem.prg
Update New method to skip file existence checks if cImage is a number (handle).
Update SetImage to ensure it passes the correct parameters to MNUITEMSETIMAGE.
Verification Plan
Automated Tests
Recompile the Fivemac library: make clean && make.
Compile and run a sample that uses MENUITEM with ImgSymbols().
Manual Verification
Verify that icons are correctly displayed in the menu using ImgSymbols("star", "Star").
Verify that standard image files still work.
Modernización de Preferencias: Se han actualizado todos los iconos a SF Symbols y se ha mejorado el layout de la vista de Workspace.
Soporte de SF Symbols en TMenu: Ahora TMenu acepta manejadores de ImgSymbols() directamente. También se han corregido fugas de memoria en la gestión de imágenes de menús.
MODIFY] 
scintilla.prg
Add HandleBraceMatch() method to automate the logic (checking both at and before cursor).
Update Notify() to call HandleBraceMatch() on SCN_UPDATEUI.
Fix BraceBadLight to correctly use only one parameter for SCI_BRACEBADLIGHT.
Update Setup() to call SetMBrace() for consistent style initialization.
[Samples]
[MODIFY] 
fivedit.prg
Simplify EditorChange() by removing redundant brace matching logic, as it will now be handled by the class.
Verification Plan
Automated Tests
Recompile Fivemac library.
Build and run fivedit.
Test typing braces (), {}, [] and verify they highlight correctly when the caret is adjacent to them.
Test mismatched braces to verify "BadLight" highlighting.