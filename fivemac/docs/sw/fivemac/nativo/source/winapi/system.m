#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/network/IOEthernetController.h>
#import <IOKit/network/IOEthernetInterface.h>
#import <IOKit/network/IONetworkInterface.h>
#import <QuartzCore/QuartzCore.h>
#import <UserNotifications/UserNotifications.h>

#include <fivemac.h>
#import <iTunes.h>

void MsgAlert(NSString *, NSString *messageText);

//-------------------------------------------------------

HB_FUNC(APPNAME) {
  // En No-ARC, mainBundle y bundlePath devuelven objetos autorelease
  NSBundle *bundle = [NSBundle mainBundle];

  if (bundle != nil) {
    NSString *path = [bundle bundlePath];

    if (path != nil) {
      hb_retc([path UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(APPPATH) {
  // En No-ARC, mainBundle y bundlePath devuelven objetos autorelease
  NSBundle *bundle = [NSBundle mainBundle];

  if (bundle != nil) {
    NSString *path = [bundle bundlePath];

    if (path != nil) {
      hb_retc([path UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(RESPATH) {
  // En No-ARC, resourcePath es un objeto autorelease
  NSString *bundlePath = [[NSBundle mainBundle] resourcePath];

  if (hb_pcount() > 0 && bundlePath != nil) {
    NSString *fileName = hb_NSSTRING_par(1);

    // Creamos la ruta base expandiendo tildes (autorelease)
    NSString *fullPath = [bundlePath stringByExpandingTildeInPath];

    // Combinamos el nombre del archivo (autorelease)
    NSString *testPath = [fullPath stringByAppendingPathComponent:fileName];

    // Verificamos si el archivo existe directamente en Resources
    if ([[NSFileManager defaultManager] fileExistsAtPath:testPath]) {
      hb_retc([testPath UTF8String]);
    } else {
      // Si no existe, buscamos en la subcarpeta 'bitmaps' (estándar FiveMac)
      NSString *bitmapsPath =
          [bundlePath stringByAppendingPathComponent:@"bitmaps"];
      testPath = [bitmapsPath stringByAppendingPathComponent:fileName];

      hb_retc([testPath UTF8String]);
    }
  } else if (bundlePath != nil) {
    hb_retc([bundlePath UTF8String]);
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(CURRENTPATH) {
  // En No-ARC, defaultManager y currentDirectoryPath devuelven objetos
  // autorelease
  NSFileManager *fileManager = [NSFileManager defaultManager];

  if (fileManager != nil) {
    NSString *currentPath = [fileManager currentDirectoryPath];

    if (currentPath != nil) {
      hb_retc([currentPath UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

HB_FUNC(SETCURRENTPATH) {
  // Obtenemos el string desde Harbour (asumiendo que hb_NSSTRING_par maneja el
  // autorelease)
  NSString *path = hb_NSSTRING_par(1);

  if (path != nil) {
    // En No-ARC, defaultManager es un objeto compartido que no requiere release
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // Cambiamos el directorio de trabajo actual del proceso
    [fileManager changeCurrentDirectoryPath:path];
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(PATH) {
  // mainBundle y bundlePath devuelven objetos en el autoreleasepool
  NSBundle *bundle = [NSBundle mainBundle];

  if (bundle != nil) {
    NSString *buPath = [bundle bundlePath];

    // stringByDeletingLastPathComponent también devuelve un objeto autorelease
    NSString *parentPath = [buPath stringByDeletingLastPathComponent];

    if (parentPath != nil) {
      hb_retc([parentPath UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(HOMEPATH) {
  NSURL *homeURL = [[NSFileManager defaultManager] homeDirectoryForCurrentUser];
  if (homeURL != nil) {
    NSString *path = [homeURL path];
    if (path != nil) {
      hb_retc([path UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

HB_FUNC(HOME) {
   // Alias para facilitar su uso
   PHB_ITEM pPath = hb_itemPutC( NULL, "" );
   NSURL *homeURL = [[NSFileManager defaultManager] homeDirectoryForCurrentUser];
   if (homeURL != nil) {
      hb_itemPutC( pPath, [[homeURL path] UTF8String] );
   }
   hb_itemReturn( pPath );
   hb_itemRelease( pPath );
}

//----------------------------------------------------------------------------//

HB_FUNC(PARENTPATH) {
  // Obtenemos el path desde Harbour de forma segura
  NSString *path = hb_NSSTRING_par(1);

  if (path != nil) {
    // stringByDeletingLastPathComponent devuelve un objeto autorelease
    NSString *parent = [path stringByDeletingLastPathComponent];

    if (parent != nil) {
      hb_retc([parent UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(FILENOPATH) {
  // Usamos stringWithUTF8String que devuelve un objeto autorelease directamente
  NSString *path = hb_NSSTRING_par(1);

  if (path != nil) {
    // lastPathComponent devuelve un objeto autorelease
    NSString *fileName = [path lastPathComponent];

    if (fileName != nil) {
      hb_retc([fileName UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(LIBRARYPATH) {
  // En No-ARC, los literales de string y stringByExpandingTildeInPath
  // devuelven objetos en el autoreleasepool.
  NSString *userPath = [@"~/Library" stringByExpandingTildeInPath];

  if (userPath != nil) {
    // Usamos UTF8String para pasar el puntero char* a Harbour
    hb_retc([userPath UTF8String]);
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(USERPATH) {
  // En No-ARC, los literales y métodos de conveniencia son autorelease
  NSString *userPath = [@"~" stringByExpandingTildeInPath];

  if (userPath != nil) {
    // Usamos UTF8String para un retorno limpio a Harbour
    hb_retc([userPath UTF8String]);
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(ISFILE) {
  // Obtenemos el string de Harbour (autorelease)
  NSString *path = hb_NSSTRING_par(1);

  if (path != nil) {
    // En No-ARC, defaultManager es un objeto compartido (no requiere release)
    NSFileManager *filemgr = [NSFileManager defaultManager];

    // fileExistsAtPath devuelve un BOOL directo
    hb_retl([filemgr fileExistsAtPath:path]);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(COPYFILETO) {
  // Usamos tu función puente que ya devuelve objetos 'autorelease'
  NSString *fileIni = hb_NSSTRING_par(1);
  NSString *fileFin = hb_NSSTRING_par(2);

  // Verificamos que no recibamos strings vacíos (que hb_NSSTRING_par devuelve
  // por defecto)
  if ([fileIni length] > 0 && [fileFin length] > 0) {

    // En No-ARC, defaultManager es un objeto compartido (no requiere release)
    NSFileManager *filemgr = [NSFileManager defaultManager];

    // Ejecutamos la copia.
    // Nota: Fallará si el archivo de destino ya existe.
    BOOL success = [filemgr copyItemAtPath:fileIni toPath:fileFin error:NULL];

    hb_retl(success);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(DELETEFILE) {
  bool lresult = false;

  NSString *string = hb_NSSTRING_par(1);

  if (string != nil) {
    // En No-ARC, defaultManager es compartido
    NSFileManager *filemgr = [NSFileManager defaultManager];

    // Verificamos si es borrable (opcional pero buena práctica)
    if ([filemgr isDeletableFileAtPath:string]) {
      // removeItemAtPath devuelve BOOL. Usamos NULL para el error.
      lresult = [filemgr removeItemAtPath:string error:NULL];
    }
  }

  hb_retl(lresult);
}

//----------------------------------------------------------------------------//

HB_FUNC(DELETEDIR) {
  // Usamos tu función puente (devuelve un objeto autorelease)
  NSString *path = hb_NSSTRING_par(1);

  if ([path length] > 0) {
    NSFileManager *fManager = [NSFileManager defaultManager];
    BOOL isDir = NO;

    // Verificamos si existe y si es un directorio
    if ([fManager fileExistsAtPath:path isDirectory:&isDir]) {
      // removeItemAtPath elimina el directorio y todo su contenido
      BOOL success = [fManager removeItemAtPath:path error:NULL];
      hb_retl(success);
    } else {
      hb_retl(NO);
    }
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(CREATEDIR) {
  NSString *cDirName = hb_NSSTRING_par(1);

  if ([cDirName length] > 0) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL exists = [fileManager fileExistsAtPath:cDirName isDirectory:&isDir];

    if (!exists) {
      // withIntermediateDirectories:YES crea toda la ruta (como mkdir -p)
      BOOL success = [fileManager createDirectoryAtPath:cDirName
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:NULL];
      if (!success) {
        NSLog(@"Error: Create folder failed %@", cDirName);
      }
      hb_retl(success);
    } else {
      hb_retl(isDir); // Ya existe y es un directorio
    }
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------------//

NSURL *AppURLFromAppName(NSString *appName) {
  NSURL *appURL = nil;

  if ([appName isAbsolutePath]) {
    appURL = [NSURL fileURLWithPath:appName];
  } else {
    // Buscamos por Bundle Identifier (ej: com.apple.Safari)
    appURL = [[NSWorkspace sharedWorkspace]
        URLForApplicationWithBundleIdentifier:appName];

    if (appURL == nil) {
      // Creamos el array de rutas (es un objeto autorelease)
      NSArray *paths = [NSArray
          arrayWithObjects:@"/Applications", @"/System/Applications",
                           [@"~/Applications" stringByExpandingTildeInPath],
                           nil];

      for (NSString *searchPath in paths) {
        NSString *fullPath =
            [searchPath stringByAppendingPathComponent:appName];

        if (![fullPath hasSuffix:@".app"]) {
          fullPath = [fullPath stringByAppendingPathExtension:@"app"];
        }

        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
          appURL = [NSURL fileURLWithPath:fullPath];
          break;
        }
      }
    }
  }
  // El objeto NSURL devuelto es autorelease, la función que lo llame
  // deberá hacer [appURL retain] si necesita guardarlo fuera del ciclo.
  return appURL;
}

//----------------------------------------------------------------------------//

HB_FUNC(MACEXEC) {
  if (hb_pcount() >= 1) {
    NSString *appName = hb_NSSTRING_par(1);
    NSURL *appURL = AppURLFromAppName(appName);

    if (appURL != nil) {
      // configuration es un método de clase (autorelease)
      NSWorkspaceOpenConfiguration *config =
          [NSWorkspaceOpenConfiguration configuration];

      if (hb_pcount() >= 2) {
        // Creamos el array de argumentos (autorelease)
        [config setArguments:[NSArray arrayWithObject:hb_NSSTRING_par(2)]];
      }

      // Variable compartida con el bloque
      __block BOOL success = NO;

      // Los semáforos se crean con un retain count de 1 (deben liberarse)
      dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

      [[NSWorkspace sharedWorkspace]
          openApplicationAtURL:appURL
                 configuration:config
             completionHandler:^(NSRunningApplication *_Nullable app,
                                 NSError *_Nullable error) {
               success = (error == nil);
               // Despertamos al hilo principal
               dispatch_semaphore_signal(semaphore);
             }];

      // Esperamos hasta 5 segundos
      dispatch_semaphore_wait(
          semaphore,
          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)));

      // IMPORTANTE en No ARC: Liberar el semáforo manualmente
      dispatch_release(semaphore);

      hb_retl(success);
    } else {
      hb_retl(NO);
    }
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(OPENFILEWITHAPP) {
  if (hb_pcount() == 2) {
    NSString *filePath = hb_NSSTRING_par(1);
    NSString *appName = hb_NSSTRING_par(2);

    // NSURL fileURLWithPath y AppURLFromAppName devuelven objetos autorelease
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSURL *appURL = AppURLFromAppName(appName);

    if (fileURL != nil && appURL != nil) {
      // configuration es un método de clase (autorelease)
      NSWorkspaceOpenConfiguration *config =
          [NSWorkspaceOpenConfiguration configuration];

      __block BOOL success = NO;

      // En No-ARC, los semáforos deben ser liberados manualmente
      dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

      // Creamos el array de URLs (autorelease)
      NSArray *urls = [NSArray arrayWithObject:fileURL];

      [[NSWorkspace sharedWorkspace]
                      openURLs:urls
          withApplicationAtURL:appURL
                 configuration:config
             completionHandler:^(NSRunningApplication *_Nullable app,
                                 NSError *_Nullable error) {
               success = (error == nil);
               dispatch_semaphore_signal(semaphore);
             }];

      // Esperamos hasta 5 segundos para que Harbour reciba el resultado
      dispatch_semaphore_wait(
          semaphore,
          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)));

      // LIBERACIÓN MANUAL del semáforo (Crucial en No-ARC)
      dispatch_release(semaphore);

      hb_retl(success);
    } else {
      hb_retl(NO);
    }
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(SCREENWIDTH) {
  // mainScreen es un objeto compartido (no requiere release)
  NSScreen *screen = [NSScreen mainScreen];

  if (screen != nil) {
    // frame devuelve una estructura NSRect (no es un objeto, no requiere
    // memoria dinámica)
    NSRect rect = [screen frame];

    // Retornamos el ancho como un entero largo (long)
    hb_retnl((long)rect.size.width);
  } else {
    hb_retnl(0);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(SCREENVISIBLEWIDTH) {
  // mainScreen es un objeto compartido (no requiere release)
  NSScreen *screen = [NSScreen mainScreen];

  if (screen != nil) {
    // visibleFrame devuelve una estructura NSRect (no es un objeto)
    NSRect rect = [screen visibleFrame];

    // Retornamos el ancho visible
    hb_retnl((long)rect.size.width);
  } else {
    hb_retnl(0);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(STATUSBARHEIGHT) {
  // systemStatusBar es un objeto compartido (no requiere release)
  NSStatusBar *bar = [NSStatusBar systemStatusBar];

  if (bar != nil) {
    // Obtenemos el grosor de la barra de estado (normalmente 22 puntos)
    CGFloat thickness = [bar thickness];

    // Retornamos el valor como un entero largo (long)
    hb_retnl((long)thickness);
  } else {
    hb_retnl(0);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(SCREENHEIGHT) {
  // mainScreen es un objeto compartido (no requiere release)
  NSScreen *screen = [NSScreen mainScreen];

  if (screen != nil) {
    // frame devuelve una estructura NSRect (no es un objeto, no requiere
    // memoria dinámica)
    NSRect rect = [screen frame];

    // Retornamos la altura como un entero largo (long)
    hb_retnl((long)rect.size.height);
  } else {
    hb_retnl(0);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(SCREENVISIBLEHEIGHT) {
  // mainScreen es un objeto compartido (no requiere release)
  NSScreen *screen = [NSScreen mainScreen];

  if (screen != nil) {
    // visibleFrame devuelve una estructura NSRect (no es un objeto)
    NSRect rect = [screen visibleFrame];

    // Retornamos la altura visible
    hb_retnl((long)rect.size.height);
  } else {
    hb_retnl(0);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(GETDOCKPOSITION) {
  // Objeto compartido (no requiere release)
  NSScreen *screen = [NSScreen mainScreen];

  if (screen != nil) {
    // Estructura en la pila (no requiere memoria dinámica)
    NSRect rect = [screen visibleFrame];

    if (rect.origin.y == 0) {
      if (rect.origin.x == 0) {
        hb_retc("right");
      } else {
        hb_retc("left");
      }
    } else {
      hb_retc("bottom");
    }
  } else {
    hb_retc("unknown");
  }
}

//----------------------------------------------------------------------------//

CGFloat GetDockSize(void) {
  CGFloat nSize = 0;
  // mainScreen es un objeto compartido (no requiere release)
  NSScreen *screen = [NSScreen mainScreen];

  if (screen != nil) {
    // visibleFrame excluye el Dock y la barra de menús
    NSRect rectvisible = [screen visibleFrame];
    // frame es el tamaño total del monitor
    NSRect rect = [screen frame];

    if (rectvisible.origin.y == 0) {
      if (rectvisible.origin.x == 0) {
        // El Dock está a la derecha
        nSize = rect.size.width - rectvisible.size.width;
      } else {
        // El Dock está a la izquierda
        nSize = rectvisible.origin.x;
      }
    } else {
      // El Dock está en la parte inferior
      nSize = rectvisible.origin.y;
    }
  }
  return nSize;
}

HB_FUNC(GETDOCKSIZE) {
  // Convertimos el CGFloat a long para Harbour
  hb_retnl((long)GetDockSize());
}

//----------------------------------------------------------------------------//

HB_FUNC(ISDOCKHIDDEN) {
  // Llamamos a la función auxiliar que ya definimos antes
  CGFloat nSize = GetDockSize();

  // Si el tamaño detectado es muy pequeño (típicamente < 25),
  // significa que el Dock está oculto automáticamente.
  if (nSize < 25.0f) {
    hb_retl(YES);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(GETMACMODEL) {
  char model[64] = {0};
  // Buscamos el servicio "model" en el registro del sistema
  io_service_t service = IOServiceGetMatchingService(
      kIOMainPortDefault, IOServiceMatching("defaults"));

  if (service) {
    // Obtenemos la propiedad del modelo
    CFDataRef data = (CFDataRef)IORegistryEntryCreateCFProperty(
        service, CFSTR("model"), kCFAllocatorDefault, 0);

    if (data != NULL) {
      CFIndex len = CFDataGetLength(data);
      if (len > 0 && len < sizeof(model)) {
        CFDataGetBytes(data, CFRangeMake(0, len), (UInt8 *)model);
      }
      // LIBERACIÓN MANUAL (Crucial en No-ARC/CoreFoundation)
      CFRelease(data);
    }
    // LIBERACIÓN MANUAL del servicio IOKit
    IOObjectRelease(service);
  }

  if (model[0] != '\0') {
    hb_retc(model);
  } else {
    hb_retc("Unknown Mac");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(GETCLASSNAME) {
  // Recuperamos el objeto desde el puntero de Harbour
  NSObject *control = (NSObject *)hb_parnll(1);

  if (control != nil) {
    // En No-ARC, className devuelve un objeto autorelease
    NSString *className = [control className];

    if (className != nil) {
      hb_retc([className UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(APPTOFROM) {
  // sharedApplication es un objeto gestionado por el sistema (no requiere
  // release)
  NSApplication *app = [NSApplication sharedApplication];

  if (app != nil) {
    // En No-ARC usamos la sintaxis de mensajes clásica
    // YES fuerza que la app pase al frente incluso si otra tiene el foco
    [app activateIgnoringOtherApps:YES];
  }
}

//----------------------------------------------------------------------------//
HB_FUNC(HIDEAPPS) {
  // sharedWorkspace es un objeto gestionado por el sistema (autorelease)
  // No uses alloc/init aquí para evitar sobrecarga innecesaria
  NSWorkspace *workspace = [NSWorkspace sharedWorkspace];

  if (workspace != nil) {
    // Oculta todas las aplicaciones excepto la actual
    [workspace hideOtherApplications];
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(MSGABOUT) {
  // hb_NSSTRING_par ya devuelve objetos autorelease
  NSString *cVersion = hb_NSSTRING_par(1);
  NSString *cAppName = hb_NSSTRING_par(2);
  NSString *cCopyright = hb_NSSTRING_par(3);

  // dictionaryWithObjectsAndKeys: devuelve un objeto del autoreleasepool
  // Ojo: el orden es Objeto, Clave, Objeto, Clave... terminado en nil
  NSDictionary *options =
      [NSDictionary dictionaryWithObjectsAndKeys:cVersion, @"Version", cAppName,
                                                 @"ApplicationName", cCopyright,
                                                 @"Copyright", nil];

  // sharedApplication es un objeto gestionado por el sistema
  [[NSApplication sharedApplication]
      orderFrontStandardAboutPanelWithOptions:options];
}

//----------------------------------------------------------------------------//

HB_FUNC(SPOTLITE) {
  // hb_NSSTRING_par devuelve un objeto autorelease
  NSString *query = hb_NSSTRING_par(1);

  if ([query length] > 0) {
    // sharedWorkspace es un objeto gestionado por el sistema (no requiere
    // release)
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];

    // Ejecuta la búsqueda en Spotlight y abre la ventana de resultados
    BOOL success = [workspace showSearchResultsForQueryString:query];

    hb_retl(success);
  } else {
    hb_retl(NO);
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(SYSTEM) { hb_retnl(system(hb_parc(1))); }

HB_FUNC(FM_OPENFILE) {
  if (hb_pcount() < 1) {
    hb_retl(NO);
    return;
  }

  NSString *filePath = hb_NSSTRING_par(1);
  NSURL *fileURL = [NSURL fileURLWithPath:filePath];
  if (!fileURL) {
    hb_retl(NO);
    return;
  }

  NSWorkspaceOpenConfiguration *config =
      [NSWorkspaceOpenConfiguration configuration];
  __block BOOL success = NO;
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

  if (hb_pcount() == 1) {
    [[NSWorkspace sharedWorkspace]
                  openURL:fileURL
            configuration:config
        completionHandler:^(NSRunningApplication *_Nullable app,
                            NSError *_Nullable error) {
          success = (error == nil);
          dispatch_semaphore_signal(semaphore);
        }];
  } else if (hb_pcount() == 2) {
    NSString *appName = hb_NSSTRING_par(2);
    NSURL *appURL = AppURLFromAppName(appName);

    if (appURL) {
      [[NSWorkspace sharedWorkspace]
                      openURLs:@[ fileURL ]
          withApplicationAtURL:appURL
                 configuration:config
             completionHandler:^(NSRunningApplication *_Nullable app,
                                 NSError *_Nullable error) {
               success = (error == nil);
               dispatch_semaphore_signal(semaphore);
             }];
    } else {
      hb_retl(NO);
      return;
    }
  }

  dispatch_semaphore_wait(
      semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)));

  // LIBERACIÓN MANUAL (Crucial en No-ARC)
  dispatch_release(semaphore);

  hb_retl(success);
}

HB_FUNC(MOVETOTRASH2) {
  NSFileManager *filemgr = NSFileManager.defaultManager;
  bool lresult = false;

  NSString *string = hb_NSSTRING_par(1);

  if ([filemgr isDeletableFileAtPath:string]) {
    NSURL *originalURL = [[NSURL alloc] initFileURLWithPath:string];

    lresult = [filemgr trashItemAtURL:originalURL
                     resultingItemURL:nil
                                error:nil];

    // LIBERACIÓN MANUAL (Crucial en No-ARC)
    [originalURL release];
  }

  hb_retl(lresult);
}

HB_FUNC(MOVETOTRASH) {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1060
  NSString *path =
      [[[NSString alloc] initWithCString:HB_ISCHAR(1) ? hb_parc(1) : ""
                                encoding:NSUTF8StringEncoding] autorelease];
  NSURL *originalURL = [[NSURL alloc] initFileURLWithPath:path];
  NSArray *urls = [NSArray arrayWithObject:originalURL];

  [[NSWorkspace sharedWorkspace]
            recycleURLs:urls
      completionHandler:^(NSDictionary *newURLs, NSError *error) {
        if (error != nil) {
          [NSApp presentError:error];
          // NSLog( @"error: %@", error );
        }
        // else
        // {
        // NSLog(@"newURLs: %@", newURLs);
        // }
      }];
#endif
}

HB_FUNC(TASKEXEC) {
  NSString *comando = hb_NSSTRING_par(1);

  NSTask *task = [[NSTask alloc] init];

  [task setLaunchPath:comando];

  NSMutableArray *arguments = [[[NSMutableArray alloc] init] autorelease];
  NSString *cArg;
  int n = hb_parinfa(2, 0);
  int i;

  for (i = 0; i <= n - 1; i++) {

    cArg =
        [[[NSString alloc] initWithCString:hb_parvc(2, i + 1)
                                  encoding:NSUTF8StringEncoding] autorelease];

    [arguments addObject:cArg];
  }

  [task setArguments:arguments];

  NSPipe *pipe = [NSPipe pipe];
  [task setStandardOutput:pipe];
  [task setStandardError:pipe];

  NSFileHandle *file = [pipe fileHandleForReading];
  [task launch];

  NSData *data = [file readDataToEndOfFile];
  NSString *string = [[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding];
  // NSLog( @"woop! got\n%@", string );
  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(TASKEXECARRAY) {
  NSString *comando = hb_NSSTRING_par(1);

  NSTask *task = [[NSTask alloc] init];

  //   NSURL * urlFile = [ NSURL fileURLWithPath: comando ];

  [task setCurrentDirectoryURL:[[NSBundle mainBundle] bundleURL]];

  [task setLaunchPath:comando];

  NSArray *arguments = (NSArray *)hb_parnll(2);
  [task setArguments:arguments];

  NSPipe *pipe = [NSPipe pipe];
  [task setStandardOutput:pipe];
  [task setStandardError:pipe];

  NSFileHandle *file = [pipe fileHandleForReading];
  [task launch];

  NSData *data = [file readDataToEndOfFile];
  NSString *string = [[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding];
  // NSLog( @"woop! got\n%@", string );
  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(BUILD) {
  NSString *cFileName = hb_NSSTRING_par(1);
  NSTask *build = [[NSTask alloc] init];

  NSString *buPath = [[NSBundle mainBundle] bundlePath];
  NSString *secondParentPath = [buPath stringByDeletingLastPathComponent];

  secondParentPath =
      [secondParentPath stringByAppendingString:@"/fivebuild.sh"];

  //  NSURL * urlFile = [ NSURL fileURLWithPath: secondParentPath ];

  //  NSURL * urlFile = [ NSURL fileURLWithPath: secondParentPath ];

  //  [ build setCurrentDirectoryURL : [ urlFile filePathURL ] ] ;

  [build setLaunchPath:@"/bin/sh"];
  [build
      setArguments:[NSArray arrayWithObjects:secondParentPath, cFileName, nil]];

  NSPipe *pipe = [NSPipe pipe];
  [build setStandardOutput:pipe];
  [build setStandardError:pipe];

  NSFileHandle *file = [pipe fileHandleForReading];

  [build launch];

  NSData *data = [file readDataToEndOfFile];
  NSString *string = [[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding];

  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(MAKEEXEC) {
  NSString *cShFile = hb_NSSTRING_par(1);
  NSString *cFileName = hb_NSSTRING_par(2);
  NSString *SdkPath = hb_NSSTRING_par(3);
  NSString *Frameworks = hb_NSSTRING_par(4);
  NSString *HarbLibs = hb_NSSTRING_par(5);
  NSString *HarbPath = hb_NSSTRING_par(6);
  NSString *FivePath = hb_NSSTRING_par(7);
  NSString *ExtraFrameworks = hb_NSSTRING_par(8);

  NSTask *build = [[NSTask alloc] init];

  //------------- ajuste de enviroment ------------------

  // NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];

  NSMutableDictionary *env = [NSMutableDictionary
      dictionaryWithObjectsAndKeys:@"dumb", @"TERM", SdkPath, @"SDKPATH",
                                   Frameworks, @"FRAMEWORKS", HarbLibs,
                                   @"HRBLIBS", HarbPath, @"HARBPATH", FivePath,
                                   @"FIVEPATH", ExtraFrameworks,
                                   @"EXTRAFRAMEWORKS", nil];

  [build setEnvironment:env];

  //------------------------------------------------------

  NSString *buPath = [[NSBundle mainBundle] bundlePath];
  NSString *secondParentPath = [buPath stringByDeletingLastPathComponent];
  secondParentPath = [secondParentPath stringByAppendingString:cShFile];
  [build setLaunchPath:@"/bin/sh"];

  [build
      setArguments:[NSArray arrayWithObjects:secondParentPath, cFileName, nil]];

  NSPipe *pipe = [NSPipe pipe];
  [build setStandardOutput:pipe];
  [build setStandardError:pipe];

  NSFileHandle *file = [pipe fileHandleForReading];
  [build launch];

  NSData *data = [file readDataToEndOfFile];
  NSString *string = [[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding];

  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(USERNAME) {
  NSString *userName = NSUserName();

  hb_retc([userName cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(WINEXEC) { HB_FUN_MACEXEC(); }

HB_FUNC(WAITRUN) { HB_FUN_SYSTEM(); }

HB_FUNC(SETEXECUTABLE) {
  NSString *script = hb_NSSTRING_par(1);

  NSFileManager *fileManager = [NSFileManager defaultManager];

  if (![fileManager isExecutableFileAtPath:script]) {
    NSArray *chmodArguments = [NSArray arrayWithObjects:@"+x", script, nil];
    NSTask *chmod = [NSTask launchedTaskWithLaunchPath:@"/bin/chmod"
                                             arguments:chmodArguments];
    [chmod waitUntilExit];
  }
}

HB_FUNC(SHFILEFROMSTRING) {
  NSString *script = hb_NSSTRING_par(1);
  NSString *FileName = hb_NSSTRING_par(2);
  NSString *attachmentsString = @"#!/bin/sh\n";

  attachmentsString = [attachmentsString stringByAppendingString:script];
  attachmentsString = [attachmentsString stringByAppendingString:@"\n"];
  attachmentsString = [attachmentsString stringByAppendingString:@"\n"];
  attachmentsString =
      [attachmentsString stringByAppendingString:@"echo done!\n"];

  [attachmentsString writeToFile:FileName
                      atomically:YES
                        encoding:NSASCIIStringEncoding
                           error:nil];
}

HB_FUNC(RUNSCRIPTSFROMFILE) {
  NSString *script = hb_NSSTRING_par(1);
  NSAppleScript *theScript = [[NSAppleScript alloc]
      initWithContentsOfURL:[NSURL fileURLWithPath:script]
                      error:nil];
  [theScript executeAndReturnError:nil];
}

//----------------------------------------------------------------------------//

HB_FUNC(GETCURRENTLANGUAGE) {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  // En No-ARC, 'languages' es un objeto autorelease
  NSArray *languages = [defaults objectForKey:@"AppleLanguages"];

  // Verificamos que el array exista y tenga al menos un elemento
  if (languages != nil && [languages count] > 0) {

    // objectAtIndex:0 devuelve el objeto sin incrementar el contador (no
    // requiere release)
    NSString *currentLanguage = [languages objectAtIndex:0];

    if (currentLanguage != nil) {
      hb_retc([currentLanguage UTF8String]);
    } else {
      hb_retc("");
    }
  } else {
    // Valor por defecto si no hay configuración
    hb_retc("");
  }
}

//----------------------------------------------------------------------------//

HB_FUNC(GETAPPICON) {
  NSImage *image = [NSApp applicationIconImage];
  hb_retnll((HB_LONGLONG)image);
}

HB_FUNC(SETAPPICON) {
  NSImage *image = (NSImage *)hb_parnll(1);
  [NSApp setApplicationIconImage:image];
}

HB_FUNC(DOCKGET) {
  NSDockTile *docTile = [NSApp dockTile];
  hb_retnll((HB_LONGLONG)docTile);
}

HB_FUNC(APPISACTIVE) { hb_retl([NSApp isActive]); }

HB_FUNC(APPISHIDE) { hb_retl([NSApp isHidden]); }

HB_FUNC(SYSREFRESH) { [NSApp setWindowsNeedUpdate:YES]; }

HB_FUNC(DOCKDISPLAY) { [[NSApp dockTile] display]; }

HB_FUNC(DOCKSETIMAGE) {
  NSDockTile *docTile = [NSApp dockTile];
  NSImage *image = (NSImage *)hb_parnll(1);
  NSImageView *iv = [[NSImageView alloc] init];
  [iv setImage:image];
  [docTile setContentView:iv];
}

//-------------------------------------------------------------//

HB_FUNC(DOCKADDPROGRESS) {
  NSDockTile *docTile = [NSApp dockTile];
  NSImageView *iv = (NSImageView *)[docTile contentView];

  // Usamos alloc/init pero añadimos autorelease al final
  NSProgressIndicator *progressIndicator = [[[NSProgressIndicator alloc]
      initWithFrame:NSMakeRect(0.0f, 0.0f, docTile.size.width, 10.0f)]
      autorelease];

  [progressIndicator setStyle:NSProgressIndicatorStyleBar];
  [progressIndicator setIndeterminate:NO];

  // Al hacer addSubview, 'iv' hace un retain interno del progressIndicator
  [iv addSubview:progressIndicator];

  [progressIndicator setWantsLayer:YES];
  // En No ARC, mejor usar la sintaxis de corchetes para propiedades de layer
  [[progressIndicator layer] setBorderWidth:1.0];
  [[progressIndicator layer] setBorderColor:[[NSColor lightGrayColor] CGColor]];

  [docTile display];

  // Devolvemos el puntero a Harbour
  hb_retnll((HB_LONGLONG)progressIndicator);
}

//-------------------------------------------------------------//

@interface FNotifyDelegate : NSObject <UNUserNotificationCenterDelegate>
@end

@implementation FNotifyDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:
             (void (^)(UNNotificationPresentationOptions options))
                 completionHandler {
  completionHandler(UNNotificationPresentationOptionList |
                    UNNotificationPresentationOptionBanner |
                    UNNotificationPresentationOptionSound);
}
@end

static FNotifyDelegate *myDelegate = nil;

HB_FUNC(USERNOTIFICATION) {
  NSString *title = hb_NSSTRING_par(1);
  NSString *info = hb_NSSTRING_par(2);

  UNUserNotificationCenter *center =
      [UNUserNotificationCenter currentNotificationCenter];

  if (myDelegate == nil)
    myDelegate = [[FNotifyDelegate alloc] init];

  [center setDelegate:myDelegate];

  [center
      requestAuthorizationWithOptions:(UNAuthorizationOptionAlert |
                                       UNAuthorizationOptionSound)
                    completionHandler:^(BOOL granted,
                                        NSError *_Nullable error) {
                      if (granted) {
                        UNMutableNotificationContent *content =
                            [[UNMutableNotificationContent alloc] init];
                        content.title = title;
                        content.body = info;
                        content.sound = [UNNotificationSound defaultSound];

                        UNTimeIntervalNotificationTrigger *trigger =
                            [UNTimeIntervalNotificationTrigger
                                triggerWithTimeInterval:1
                                                repeats:NO];

                        UNNotificationRequest *request = [UNNotificationRequest
                            requestWithIdentifier:@"FivemacNotification"
                                          content:content
                                          trigger:trigger];

                        [center
                            addNotificationRequest:request
                             withCompletionHandler:^(NSError *_Nullable error) {
                               if (error) {
                                 NSLog(@"Error adding notification: %@", error);
                               }
                             }];
                      }
                    }];
}

//-------------------------------------------------------------//

HB_FUNC(CREATE_UUID) {
  NSString *uuid = [[NSUUID UUID] UUIDString];
  hb_retc([uuid UTF8String]);
}

HB_FUNC(GETSDKPATH) {
  NSPipe *outPipe = [NSPipe pipe];
  NSTask *task = [[NSTask alloc] init];

  [task setLaunchPath:@"/usr/bin/xcrun"];
  [task setArguments:[NSArray arrayWithObjects:@"--show-sdk-path", nil]];
  [task setStandardOutput:outPipe];

  [task launch];
  [task waitUntilExit];

  NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
  NSString *string = [[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding];

  string = [string
      stringByTrimmingCharactersInSet:[NSCharacterSet
                                          whitespaceAndNewlineCharacterSet]];

  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);

  [string release];
  [task release];
}
// Helper to pump the event loop
// preventing the "beach ball" during long blocking operations (like curl)
HB_FUNC(PUMPEVENTS) {
  NSEvent *event;

  // Process all pending events
  while ((event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                     untilDate:[NSDate distantPast]
                                        inMode:NSDefaultRunLoopMode
                                       dequeue:YES]) != nil) {
    [NSApp sendEvent:event];
  }
}

//----------------------------------------------------------------------------//

//---------usar para configuraciones  en library------------------------------//

HB_FUNC(MAC_SETCONFIG) {
  NSString *key = hb_NSSTRING_par(1);
  NSString *value = hb_NSSTRING_par(2);

  [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
  // En versiones antiguas de macOS se usaba [defaults synchronize],
  // pero hoy el sistema lo hace solo de forma automática.
}

HB_FUNC(MAC_GETCONFIG) {
  NSString *key = hb_NSSTRING_par(1);
  NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:key];

  hb_retc(value ? [value UTF8String] : "");
}
