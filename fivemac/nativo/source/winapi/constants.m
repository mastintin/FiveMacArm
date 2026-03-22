#include <fivemac.h>

HB_FUNC(IMGGORIGHT) {
  // Retornamos el objeto imagen predefinido del sistema
  // imageNamed: devuelve un objeto autorelease (Correcto para No-ARC)
  NSImage *image = [NSImage imageNamed:NSImageNameGoRightTemplate];
  hb_retnll((HB_LONGLONG)image);
}

//--------------------------------------------------------------------------------//

NSImage *ImgTemplate(NSString *name) {
  // Usamos static para que el diccionario se cree SOLO UNA VEZ en toda la vida
  // de la app
  static NSDictionary *dict = nil;

  if (dict == nil) {
    NSArray *templates = [[NSArray alloc]
        initWithObjects:NSImageNameQuickLookTemplate,
                        NSImageNameBluetoothTemplate,
                        NSImageNameIChatTheaterTemplate,
                        NSImageNameSlideshowTemplate, NSImageNameActionTemplate,
                        NSImageNameSmartBadgeTemplate,
                        NSImageNameIconViewTemplate,
                        NSImageNameListViewTemplate,
                        NSImageNameColumnViewTemplate,
                        NSImageNameFlowViewTemplate, NSImageNamePathTemplate,
                        NSImageNameInvalidDataFreestandingTemplate,
                        NSImageNameLockLockedTemplate,
                        NSImageNameLockUnlockedTemplate,
                        NSImageNameGoRightTemplate, NSImageNameGoLeftTemplate,
                        NSImageNameRightFacingTriangleTemplate,
                        NSImageNameLeftFacingTriangleTemplate,
                        NSImageNameAddTemplate, NSImageNameRemoveTemplate,
                        NSImageNameRevealFreestandingTemplate,
                        NSImageNameFollowLinkFreestandingTemplate,
                        NSImageNameEnterFullScreenTemplate,
                        NSImageNameExitFullScreenTemplate,
                        NSImageNameStopProgressTemplate,
                        NSImageNameStopProgressFreestandingTemplate,
                        NSImageNameRefreshTemplate,
                        NSImageNameRefreshFreestandingTemplate,
                        NSImageNameBonjour, NSImageNameComputer,
                        NSImageNameFolderBurnable, NSImageNameFolderSmart,
                        NSImageNameFolder, NSImageNameNetwork,
                        NSImageNameMobileMe, NSImageNameMultipleDocuments,
                        NSImageNameUserAccounts, NSImageNamePreferencesGeneral,
                        NSImageNameAdvanced, NSImageNameInfo,
                        NSImageNameFontPanel, NSImageNameColorPanel,
                        NSImageNameUser, NSImageNameUserGroup,
                        NSImageNameEveryone, NSImageNameUserGuest,
                        NSImageNameMenuOnStateTemplate,
                        NSImageNameMenuMixedStateTemplate,
                        NSImageNameApplicationIcon, NSImageNameTrashEmpty,
                        NSImageNameTrashFull, NSImageNameHomeTemplate,
                        NSImageNameBookmarksTemplate, NSImageNameCaution,
                        NSImageNameStatusAvailable,
                        NSImageNameStatusPartiallyAvailable,
                        NSImageNameStatusUnavailable, NSImageNameStatusNone,
                        nil];

    NSArray *names = [[NSArray alloc]
        initWithObjects:@"QuickLook", @"Bluetooth", @"IChatTheater",
                        @"Slideshow", @"Action", @"SmartBadge", @"IconView",
                        @"ListView", @"ColumnView", @"FlowView", @"Path",
                        @"InvalidDataFreestanding", @"LockLocked",
                        @"LockUnlocked", @"GoRight", @"GoLeft",
                        @"RightFacingTriangle", @"LeftFacingTriangle", @"Add",
                        @"Remove", @"RevealFreestanding",
                        @"FollowLinkFreestanding", @"EnterFullScreen",
                        @"ExitFullScreen", @"StopProgress",
                        @"StopProgressFreestanding", @"Refresh",
                        @"RefreshFreestanding", @"Bonjour", @"Computer",
                        @"FolderBurnable", @"FolderSmart", @"Folder",
                        @"Network", @"MobileMe", @"MultipleDocuments",
                        @"UserAccounts", @"PreferencesGeneral", @"Advanced",
                        @"Info", @"FontPanel", @"ColorPanel", @"User",
                        @"UserGroup", @"Everyone", @"UserGuest", @"MenuOnState",
                        @"MenuMixedState", @"ApplicationIcon", @"TrashEmpty",
                        @"TrashFull", @"Home", @"Bookmarks", @"Caution",
                        @"StatusAvailable", @"StatusPartiallyAvailable",
                        @"StatusUnavailable", @"StatusNone", nil];

    // Creamos el diccionario y lo retenemos (sin autorelease para que viva
    // siempre)
    dict = [[NSDictionary alloc] initWithObjects:templates forKeys:names];

    // Liberamos los arrays temporales inmediatamente
    [templates release];
    [names release];
  }

  // 1. Buscamos el nombre técnico en el diccionario
  NSString *technicalName = [dict objectForKey:name];

  // 2. Si no está en el dict, probamos con el 'name' tal cual (por si pasan el
  // técnico directo)
  NSImage *img = [NSImage imageNamed:technicalName ? technicalName : name];

  // 3. Soporte para SF Symbols (macOS 11+) si no se encontró imagen estándar
  if (img == nil) {
    if ([NSImage respondsToSelector:@selector(imageWithSystemSymbolName:
                                               accessibilityDescription:)]) {
      img = [NSImage imageWithSystemSymbolName:name
                      accessibilityDescription:nil];
    }
  }

  return img; // Retorna un objeto autorelease (Correcto para No-ARC)
}

//--------------------------------------------------------------------------------//

HB_FUNC(IMGTEMPLATE) {
  hb_retnll((HB_LONGLONG)ImgTemplate(hb_NSSTRING_par(1)));
}
