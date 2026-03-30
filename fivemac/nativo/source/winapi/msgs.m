#import "Quartz/Quartz.h"
#import <ScreenCaptureKit/ScreenCaptureKit.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#include <fivemac.h>

NSAutoreleasePool *pool;

void CocoaInit(void) {
  static BOOL bInit = FALSE;

  if (!bInit) {
    pool = [[NSAutoreleasePool alloc] init];
    NSApp = [NSApplication sharedApplication];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

    [NSApp activateIgnoringOtherApps:YES];
    bInit = TRUE;
  }
}

void CocoaExit(void) {
  static BOOL bExit = FALSE;

  if (!bExit) {
    // 1. NUNCA liberes NSApp. El sistema lo hace al cerrar el proceso.

    // 2. Liberamos el pool global (esto sí es correcto)
    if (pool) {
      [pool release];
      pool = nil; // Buena práctica: dejarlo a nil tras liberar
    }

    bExit = TRUE;
  }
}

HB_FUNC(COCOAINIT) { CocoaInit(); }
HB_FUNC(COCOAEXIT) { CocoaExit(); }

void MsgAlert(NSString *detailedInformation, NSString *messageText) {
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
  NSAlert *alert = [[NSAlert alloc] init];

  alert.messageText = messageText;
  alert.informativeText = detailedInformation;
  alert.alertStyle = NSAlertStyleWarning;

  [alert addButtonWithTitle:@"OK"];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [alert runModal];

  [alert release];
  [localPool release];
}

HB_FUNC(DOCKSETBADGE) {
  [[NSApp dockTile] setBadgeLabel:hb_NSSTRING_VAL_par(1)];
}

HB_FUNC(MSGINFONATIVE) {
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];

  // ¡Mucho mas limpio y seguro!
  NSString *msg = (hb_pcount() >= 1) ? hb_NSSTRING_par(1) : @"Mensaje";
  NSString *title = (hb_pcount() >= 2) ? hb_NSSTRING_par(2) : @"Atención";

  if ([msg length] == 0)
    msg = @" ";

  NSAlert *alert = [[NSAlert alloc] init];
  [alert setMessageText:title];
  [alert setInformativeText:msg];
  [alert setAlertStyle:NSAlertStyleInformational];
  [alert addButtonWithTitle:@"Aceptar"];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [alert runModal];

  [[alert window] close];
  [alert release];
  // No hacemos release de msg/title porque HB_To_NSString devuelve autorelease
  [localPool drain];

  hb_retl(YES);
}

HB_FUNC(MSGWAIT) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // 1. Extraccion segura
  NSString *msg = hb_NSSTRING_VAL_par(1);
  NSString *title = hb_NSSTRING_VAL_par(2);
  double seconds = (hb_pcount() >= 3) ? hb_parnd(3) : 2.0;

  // 2. NSAlert
  NSAlert *alert = [[NSAlert alloc] init];
  [alert setAlertStyle:NSAlertStyleInformational];
  [alert setMessageText:title];
  [alert setInformativeText:msg];

  for (NSButton *btn in [alert buttons]) {
    [btn setHidden:YES];
  }

  // 3. Configuración de Ventana
  NSWindow *window = [alert window];
  [window setStyleMask:NSWindowStyleMaskBorderless];
  [window setBackgroundColor:[NSColor clearColor]];
  [window setOpaque:NO];
  [window setHasShadow:YES];
  [window setLevel:NSStatusWindowLevel];

  // 4. Vibrancia (Requiere release al final)
  NSVisualEffectView *vibrant =
      [[NSVisualEffectView alloc] initWithFrame:[[window contentView] bounds]];
  [vibrant setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
  [vibrant setMaterial:NSVisualEffectMaterialHUDWindow];
  [vibrant setState:NSVisualEffectStateActive];
  [vibrant setWantsLayer:YES];
  [[vibrant layer] setCornerRadius:12.0];

  [[window contentView] addSubview:vibrant
                        positioned:NSWindowBelow
                        relativeTo:nil];

  // 5. Auto-cierre (En No-ARC no usamos @(), usamos [NSNumber numberWith...])
  NSNumber *response = [NSNumber numberWithInteger:NSModalResponseOK];
  [NSApp performSelector:@selector(stopModalWithCode:)
              withObject:response
              afterDelay:seconds];

  // 6. Ejecución
  [alert runModal];

  // 7. LIMPIEZA MANUAL (Crítico en No-ARC)
  [vibrant release]; // Lo creamos con alloc
  [alert release];   // Lo creamos con alloc
  [pool release];    // Libera el NSNumber y los NSStrings

  hb_ret();
}

HB_FUNC(MSGSTOP) {
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
  NSAlert *dlg = [[NSAlert alloc] init];

  dlg.informativeText = hb_NSSTRING_VAL_par(1);
  dlg.messageText = (hb_pcount() >= 2) ? hb_NSSTRING_VAL_par(2) : @"Stop";
  dlg.alertStyle = NSAlertStyleCritical;

  [dlg addButtonWithTitle:@"OK"];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [dlg runModal];

  [dlg release];
  [localPool drain];
  hb_ret();
}

HB_FUNC(MSGALERT) {
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
  NSAlert *dlg = [[NSAlert alloc] init];

  dlg.informativeText = hb_NSSTRING_VAL_par(1);
  dlg.messageText = (hb_pcount() >= 2) ? hb_NSSTRING_VAL_par(2) : @"Alert";
  dlg.alertStyle = NSAlertStyleWarning;

  [dlg addButtonWithTitle:@"OK"];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [dlg runModal];

  [dlg release];
  [localPool drain];
  hb_ret();
}

HB_FUNC(MSGALERTSHEET) {
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
  NSAlert *alert = [[NSAlert alloc] init];

  alert.messageText = (hb_pcount() >= 2) ? hb_NSSTRING_VAL_par(2) : @"Alert";
  alert.informativeText = hb_NSSTRING_VAL_par(1);

  [alert addButtonWithTitle:@"OK"];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [alert runModal];

  [alert release];
  [localPool drain];
  hb_ret();
}

HB_FUNC(MSGYESNO) {
  // 1. Creamos el pool manual
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // 2. Usamos tu función hb_NSSTRING_par (que ya devuelve autorelease)
  NSString *msg =
      (hb_pcount() >= 1) ? hb_NSSTRING_par(1) : @"¿Desea continuar?";
  NSString *title = (hb_pcount() >= 2) ? hb_NSSTRING_par(2) : @"Confirmación";

  // 3. NSAlert se crea con alloc, por lo que SOMOS responsables de liberarlo
  NSAlert *alert = [[NSAlert alloc] init];
  [alert setMessageText:title];
  [alert setInformativeText:msg];
  [alert addButtonWithTitle:@"Sí"];
  [alert addButtonWithTitle:@"No"];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

  NSInteger res = [alert runModal];
  hb_retl(res == NSAlertFirstButtonReturn);

  // 4. LIMPIEZA OBLIGATORIA EN NO-ARC
  [alert release]; // Liberamos el objeto que creamos con 'alloc'
  [pool release];  // Liberamos el pool (y con él los NSStrings temporales)
}

HB_FUNC(MSGNOYES) // cMsg --> lYesNo
{
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];

  CocoaInit();

  NSAlert *alert = [[NSAlert alloc] init];

  NSString *text1 = hb_NSSTRING_VAL_par(2);
  if ([text1 length] == 0)
    text1 = @"Please select";

  alert.messageText = text1;

  NSString *text2 = hb_NSSTRING_VAL_par(1);
  if ([text2 length] == 0)
    text2 = @"make a choice";

  alert.informativeText = text2;

  [alert addButtonWithTitle:@"No"];
  [alert addButtonWithTitle:@"Yes"];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  NSInteger res = [alert runModal];

  hb_retl(res != NSAlertFirstButtonReturn);

  [alert release];
  [localPool release];
}

HB_FUNC(MSGDEBUG) {
  CocoaInit();
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
  NSAlert *dlg = [[NSAlert alloc] init];

  dlg.informativeText = hb_NSSTRING_VAL_par(1);
  dlg.messageText = @"Debug Info";
  dlg.alertStyle = NSAlertStyleInformational;

  [dlg addButtonWithTitle:@"Aceptar"];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [dlg runModal];

  [dlg release];
  [localPool release];
  hb_ret();
}

HB_FUNC(MSGBEEP) { NSBeep(); }

HB_FUNC(CHOOSETEXT) {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
  NSString *string = hb_NSSTRING_par(1);
  NSOpenPanel *panel = [NSOpenPanel openPanel];

  if ([string length] != 0) {
    [panel setDirectoryURL:[NSURL fileURLWithPath:string]];
  }

  panel.canChooseDirectories = YES;
  panel.message = @"Please select ";

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  if (panel.runModal == NSModalResponseOK) {
    NSString *source =
        [[[[panel URLs] objectAtIndex:0] path] stringByRemovingPercentEncoding];

    hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
  } else
    hb_retc("");

  [localPool release];
#endif
}

HB_FUNC(CHOOSEFILE) {
  NSString *types = hb_NSSTRING_par(2);
  NSOpenPanel *op = [NSOpenPanel openPanel]; //[ [ NSOpenPanel alloc ] init ];

  [op setPrompt:@"Ok"];

  if (!HB_ISCHAR(1))
    [op setTitle:@"Please select a filename"];
  else
    [op setTitle:hb_NSSTRING_par(1)];

  if (![types isEqualToString:@""]) {
    NSMutableArray *allowedTypes = [NSMutableArray array];
    NSArray *extensions;

    if ([types containsString:@","]) {
      extensions = [types componentsSeparatedByString:@","];
    } else {
      extensions = @[ types ];
    }

    for (NSString *ext in extensions) {
      if (@available(macOS 11.0, *)) {
        UTType *type = [UTType typeWithFilenameExtension:ext];
        if (type) {
          [allowedTypes addObject:type];
        }
      }
    }

    if (@available(macOS 11.0, *)) {
      [op setAllowedContentTypes:allowedTypes];
    }
  }

  if ([op runModal] == NSModalResponseOK) {
    NSString *source =
        [[[[op URLs] objectAtIndex:0] path] stringByRemovingPercentEncoding];

    hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
  } else
    hb_retc("");
}

HB_FUNC(CHOOSEFILEURL) {
  NSOpenPanel *op = [[NSOpenPanel alloc] init];
  NSURL *source;

  [op setPrompt:@"Ok"];
  [op setMessage:@"Please select a file"];

  if ([op runModal] == NSModalResponseOK) {
    source = [[op URLs] objectAtIndex:0];
    hb_retnll((HB_LONGLONG)source);
  } else
    hb_ret();
}

HB_FUNC(CHOOSEFOLDER) {
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
  NSString *types = hb_NSSTRING_par(2);
  NSOpenPanel *op = [NSOpenPanel openPanel];

  [op setCanChooseFiles:NO];
  [op setCanChooseDirectories:YES];
  [op setPrompt:@"Ok"];

  if (!HB_ISCHAR(1))
    [op setTitle:@"Please select a folder"];
  else
    [op setTitle:hb_NSSTRING_par(1)];

  if (![types isEqualToString:@""]) {
    NSMutableArray *allowedTypes = [NSMutableArray array];
    NSArray *extensions;

    if ([types containsString:@","]) {
      extensions = [types componentsSeparatedByString:@","];
    } else {
      extensions = @[ types ];
    }

    for (NSString *ext in extensions) {
      if (@available(macOS 11.0, *)) {
        UTType *type = [UTType typeWithFilenameExtension:ext];
        if (type) {
          [allowedTypes addObject:type];
        }
      }
    }

    if (@available(macOS 11.0, *)) {
      [op setAllowedContentTypes:allowedTypes];
    }
  }

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  if ([op runModal] == NSModalResponseOK) {
    NSString *source =
        [[[[op URLs] objectAtIndex:0] path] stringByRemovingPercentEncoding];

    hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
  } else
    hb_retc("");

  [localPool release];
}

HB_FUNC(SAVEFILE) {
  NSAutoreleasePool *localPool = [[NSAutoreleasePool alloc] init];
  NSSavePanel *op = [[NSSavePanel alloc] init];

  [op setPrompt:@"Ok"];

  if (!HB_ISCHAR(1))
    [op setTitle:@"Please select a filename"];
  else
    [op setTitle:hb_NSSTRING_par(1)];

  if (HB_ISCHAR(2))
    [op setNameFieldStringValue:hb_NSSTRING_par(2)];

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  if ([op runModal] == NSModalResponseOK) {

    NSString *source = [[[op URL] path] stringByRemovingPercentEncoding];
    hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
  } else
    hb_retc("");

  [op release];
  [localPool release];
}

HB_FUNC(CHOOSEIMAGEFILE) {
  // 1. Pool local para limpiar los objetos temporales (URLs, Arrays, Strings)
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  // 2. NSOpenPanel creado con alloc: SOMOS responsables de liberarlo
  NSOpenPanel *op = [[NSOpenPanel alloc] init];

  // imageTypes es un método de clase (ya es autoreleased)
  NSArray *imageTypes = [NSImage imageTypes];

  [op setPrompt:@"Ok"];
  [op setMessage:@"Please select a file"];

  // Nota: setAllowedContentTypes requiere macOS 11.0+.
  // Para versiones antiguas se usaba setAllowedFileTypes:
  [op setAllowedContentTypes:imageTypes];

  if ([op runModal] == NSModalResponseOK) {
    // Obtenemos la ruta. Todos estos métodos devuelven objetos autoreleased.
    NSString *source =
        [[[[op URLs] objectAtIndex:0] path] stringByRemovingPercentEncoding];

    // Devolvemos el string a Harbour ANTES de liberar el pool
    hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
  } else {
    hb_retc("");
  }

  // 3. LIMPIEZA MANUAL (Crítico en No-ARC)
  [op release];   // Liberamos el panel (alloc)
  [pool release]; // Liberamos los arrays y strings temporales
}

HB_FUNC(CHOOSESHEETTXTIMG) {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
  NSTextField *texto = (NSTextField *)hb_parnll(1);
  NSImageView *vista = (NSImageView *)hb_parnll(2);
  NSOpenPanel *panel = [NSOpenPanel openPanel];

  [panel setDirectoryURL:[NSURL fileURLWithPath:[texto stringValue]]];
  [panel setMessage:@"Import the file"];

  [panel
      beginSheetModalForWindow:[vista window]
             completionHandler:^(NSInteger result) {
               if (result == NSModalResponseOK) {
                 [vista setHidden:NO];
                 [vista
                     setImage:[[NSImage alloc]
                                  initWithContentsOfURL:[[panel URLs]
                                                            objectAtIndex:0]]];

                 NSString *source = [[[[panel URLs] objectAtIndex:0] path]
                     stringByRemovingPercentEncoding];

                 [texto setStringValue:source];
                 [[vista image] setName:source];
               }
             }];
#endif
}

HB_FUNC(CHOOSESHEETTEXT) {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060

  NSString *string = hb_NSSTRING_par(1);
  NSOpenPanel *panel = [NSOpenPanel openPanel];

  if ([string length] != 0) {
    [panel setDirectoryURL:[NSURL fileURLWithPath:string]];
  }

  panel.canChooseDirectories = YES;
  panel.message = @"Importe Texto";
  if (panel.runModal == NSModalResponseOK) {
    NSString *source =
        [[[[panel URLs] objectAtIndex:0] path] stringByRemovingPercentEncoding];

    hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
  } else
    hb_retc("");
#endif
}
