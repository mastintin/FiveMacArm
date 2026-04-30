#import "Music.h"
#import <Cocoa/Cocoa.h>
#import <fivemac.h>

#include "hbapi.h"
#include "hbapiitm.h"

#import <Foundation/Foundation.h>

//----------------------------------------

// Helper to run AppleScript
static NSAppleEventDescriptor *RunAppleScript(NSString *source) {
  if (!source)
    return nil;
  NSLog(@"[FiveMac Music] Executing: %@", source);
  NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
  NSDictionary *error = nil;
  NSAppleEventDescriptor *result = [script executeAndReturnError:&error];
  [script release];
  if (error) {
    NSLog(@"[FiveMac Music] AppleScript Error: %@", error);
    return nil;
  }
  NSLog(@"[FiveMac Music] Result: %@", result);
  return result;
}

//------------------ music functions ------------------

HB_FUNC(MUSICCREATE) {
  // We don't need to hold an SBApplication object anymore.
  // Return a dummy non-zero value so TMusic checks pass.
  hb_retnll(1);
}

HB_FUNC(MUSICISRUN) {
  NSArray *apps = [NSRunningApplication
      runningApplicationsWithBundleIdentifier:@"com.apple.Music"];
  hb_retl([apps count] > 0);
}

HB_FUNC(MUSICRUN) {
  if (@available(macOS 10.15, *)) {
    NSURL *url = [[NSWorkspace sharedWorkspace]
        URLForApplicationWithBundleIdentifier:@"com.apple.Music"];
    if (url) {
      [[NSWorkspace sharedWorkspace]
          openApplicationAtURL:url
                 configuration:[NSWorkspaceOpenConfiguration configuration]
             completionHandler:nil];
      return;
    }
  }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  [[NSWorkspace sharedWorkspace] launchApplication:@"Music"];
#pragma clang diagnostic pop
}

HB_FUNC(MUSICQUIT) { RunAppleScript(@"tell application \"Music\" to quit"); }

HB_FUNC(MUSICPLAY) { RunAppleScript(@"tell application \"Music\" to play"); }

HB_FUNC(MUSICPAUSE) { RunAppleScript(@"tell application \"Music\" to pause"); }

HB_FUNC(MUSICPLAYPAUSE) {
  RunAppleScript(@"tell application \"Music\" to playpause");
  NSLog(@"[FiveMac Music] PlayPause executed");
}

HB_FUNC(MUSICSTOP) { RunAppleScript(@"tell application \"Music\" to stop"); }

HB_FUNC(MUSICNEXTTRACK) {
  NSString *script = @"tell application \"Music\"\n"
                     @"   try\n"
                     @"       set idx to index of current track\n"
                     @"       play track (idx + 1) of library playlist 1\n"
                     @"   on error\n"
                     @"       play track 1 of library playlist 1\n"
                     @"   end try\n"
                     @"end tell";
  RunAppleScript(script);
  NSLog(@"[FiveMac Music] Manual NextTrack executed");
}

HB_FUNC(MUSICPREVIOUSTRACK) {
  NSString *script = @"tell application \"Music\"\n"
                     @"   try\n"
                     @"       set idx to index of current track\n"
                     @"       if idx > 1 then\n"
                     @"           play track (idx - 1) of library playlist 1\n"
                     @"       end if\n"
                     @"   on error\n"
                     @"   end try\n"
                     @"end tell";
  RunAppleScript(script);
  NSLog(@"[FiveMac Music] Manual PreviousTrack executed");
}

HB_FUNC(MUSICBACKTRACK) {
  RunAppleScript(@"tell application \"Music\" to back track");
}

HB_FUNC(MUSICSETVOL) {
  //   MusicApplication * music = ( MusicApplication * ) hb_parnll( 1 );
  int volume = hb_parni(2);
  NSLog(@"[FiveMac Music] SetVol called with: %d", volume);
  NSString *script = [NSString
      stringWithFormat:@"tell application \"Music\" to set sound volume to %d",
                       volume];
  RunAppleScript(script);
}

HB_FUNC(MUSICGETVOL) {
  NSAppleEventDescriptor *desc =
      RunAppleScript(@"tell application \"Music\" to get sound volume");
  if (desc)
    hb_retnl([desc int32Value]);
  else
    hb_retnl(0);
}

HB_FUNC(MUSICSONGNAME) {
  NSAppleEventDescriptor *stateDesc = RunAppleScript(
      @"tell application \"Music\" to get player state as string");
  if (stateDesc && [[stateDesc stringValue] isEqualToString:@"stopped"]) {
    hb_retc("");
    return;
  }

  NSAppleEventDescriptor *desc = RunAppleScript(
      @"tell application \"Music\" to get name of current track");
  if (desc && [desc stringValue]) {
    NSString *song = [desc stringValue];
    NSLog(@"[FiveMac Music] SongName returning: %@", song);
    hb_retc([song UTF8String]);
  } else {
    hb_retc("");
  }
}

HB_FUNC(MUSICGETARTIST) {
  NSAppleEventDescriptor *stateDesc = RunAppleScript(
      @"tell application \"Music\" to get player state as string");
  if (stateDesc && [[stateDesc stringValue] isEqualToString:@"stopped"]) {
    hb_retc("");
    return;
  }

  NSAppleEventDescriptor *desc = RunAppleScript(
      @"tell application \"Music\" to get artist of current track");
  if (desc && [desc stringValue])
    hb_retc([[desc stringValue] UTF8String]);
  else
    hb_retc("");
}

HB_FUNC(MUSICGETALBUM) {
  NSAppleEventDescriptor *stateDesc = RunAppleScript(
      @"tell application \"Music\" to get player state as string");
  if (stateDesc && [[stateDesc stringValue] isEqualToString:@"stopped"]) {
    hb_retc("");
    return;
  }

  NSAppleEventDescriptor *desc = RunAppleScript(
      @"tell application \"Music\" to get album of current track");
  if (desc && [desc stringValue])
    hb_retc([[desc stringValue] UTF8String]);
  else
    hb_retc("");
}

HB_FUNC(MUSICGETSONGDURATION) {
  NSAppleEventDescriptor *stateDesc = RunAppleScript(
      @"tell application \"Music\" to get player state as string");
  if (stateDesc && [[stateDesc stringValue] isEqualToString:@"stopped"]) {
    hb_retnl(0);
    return;
  }

  NSAppleEventDescriptor *desc = RunAppleScript(
      @"tell application \"Music\" to get duration of current track");
  if (desc)
    hb_retnl((long)[desc doubleValue]);
  else
    hb_retnl(0);
}

HB_FUNC(MUSICGETSONGPROGRESS) {
  NSString *scriptSource =
      @"tell application \"Music\"\n"
       "    if player state is playing then\n"
       "        set curr to player position\n"          // Segundos actuales
       "        set dur to duration of current track\n" // Segundos totales
       "        return (curr as string) & \"|\" & (dur as string)\n"
       "    end if\n"
       "end tell";

  NSAppleScript *appleScript =
      [[NSAppleScript alloc] initWithSource:scriptSource];
  NSAppleEventDescriptor *result = [appleScript executeAndReturnError:nil];

  if (result) {
    NSArray *parts = [[result stringValue] componentsSeparatedByString:@"|"];
    if (parts.count == 2) {
      double currentSeconds = [parts[0] doubleValue];
      // double totalSeconds = [parts[1] doubleValue];
      // double porcentaje = (currentSeconds / totalSeconds) * 100;

      //  NSLog(@"Progreso: %.2f%% (%0.f/%0.f seg)", porcentaje, currentSeconds,
      //  totalSeconds);

      hb_retnl((long)currentSeconds);
    }

  } else {
    hb_retnl(0);
  }
}

HB_FUNC(MUSICSEEKTOSECOND) {
  // El comando 'set player position' posiciona el cabezal de reproducción
  NSString *scriptSource =
      [NSString stringWithFormat:@"tell application \"Music\"\n"
                                  "    if exists (current track) then\n"
                                  "        set player position to %.2f\n"
                                  "    end if\n"
                                  "end tell",
                                 hb_parnd(1)];

  NSAppleScript *appleScript =
      [[NSAppleScript alloc] initWithSource:scriptSource];
  NSDictionary *errorInfo = nil;
  [appleScript executeAndReturnError:&errorInfo];

  if (errorInfo) {
    NSLog(@"Error al saltar: %@", errorInfo[NSAppleScriptErrorMessage]);
  }
}

HB_FUNC(MUSICGETSONGLYRICS) {
  NSAppleEventDescriptor *stateDesc = RunAppleScript(
      @"tell application \"Music\" to get player state as string");
  if (stateDesc && [[stateDesc stringValue] isEqualToString:@"stopped"]) {
    hb_retc("");
    return;
  }

  NSAppleEventDescriptor *desc = RunAppleScript(
      @"tell application \"Music\" to get lyrics of current track");
  if (desc && [desc stringValue])
    hb_retc([[desc stringValue] UTF8String]);
  else
    hb_retc("");
}

HB_FUNC(MUSICGETSTATE) {
  // Music state: stopped/playing/paused
  NSAppleEventDescriptor *desc = RunAppleScript(
      @"tell application \"Music\" to get player state as string");
  if (desc && [desc stringValue]) {
    NSString *state = [[desc stringValue] lowercaseString];
    if ([state isEqualToString:@"playing"])
      hb_retnl(1);
    else if ([state isEqualToString:@"paused"])
      hb_retnl(2);
    else
      hb_retnl(0); // stopped
  } else {
    hb_retnl(0);
  }
}

HB_FUNC(MUSICGETSONGRATING) {
  NSAppleEventDescriptor *desc = RunAppleScript(
      @"tell application \"Music\" to get rating of current track");
  if (desc)
    hb_retni([desc int32Value]);
  else
    hb_retni(0);
}

HB_FUNC(MUSICADDTRACK) {
  // Adding track via AppleScript is doable but complicated with path escaping.
  // For now, implementing as no-op or simple open
  NSString *sourceMediaFile = hb_NSSTRING_par(2);
  // "open" command in Music can accept a file alias
  // set theFile to POSIX file "/path/to/file"
  // tell app "Music" to open theFile
  // Converting path to HFS or POSIX file in AS
  NSString *script =
      [NSString stringWithFormat:
                    @"tell application \"Music\" to open (POSIX file \"%@\")",
                    sourceMediaFile];
  RunAppleScript(script);
}

HB_FUNC(MUSICGETARTWORK) {
  // Getting artwork data via AppleScript is tricky to return as pointer.
  // Usually it involves getting raw data.
  // Native implementation returned NSImage *.
  // We can try getting data of artwork of current track

  // Simplest way via AS: data of artwork 1 of current track
  // But returning it to C?
  // RunAppleScript returns NSAppleEventDescriptor. [desc data] gives NSData.

  NSAppleEventDescriptor *desc = RunAppleScript(
      @"tell application \"Music\" to get data of artwork 1 of current track");
  if (desc) {
    NSData *data = [desc data];
    if (data) {
      NSImage *image = [[NSImage alloc] initWithData:data];
      hb_retnll((HB_LONGLONG)image); // Pass ownership? Usually FiveMac expects
                                     // autorelease or not?
      // Original code: songArtwork = [thisArtwork data]; hb_retnll(...)
      // [thisArtwork data] returns NSImage in ScriptingBridge?? No, "data"
      // property of "Artwork" object returns NSImage in SB.

      // In AS, "get data of artwork 1" returns raw data (PICT/JPEG/etc).
      // NSImage initWithData handles that.
      // We should probably NOT release it if FiveMac manages it, or autorelease
      // it. Original code: [theArtworks objectAtIndex:0] -> thisArtwork.
      // [thisArtwork data] -> returns NSImage object allocated by SB. So
      // returning [[NSImage alloc] initWithData...] is fine, maybe autorelease
      // check memory later.
      return;
    }
  }
  hb_retnll(0);
}

HB_FUNC(MUSICGETTRACKARTWORK) {
  // 1. Definimos la ruta temporal donde se guardará la carátula
  NSString *tempPath = [NSTemporaryDirectory()
      stringByAppendingPathComponent:@"current_artwork.jpg"];

  // 2. AppleScript que extrae los datos y los escribe en disco
  // Usamos 'raw data' para obtener la imagen original sin pérdida
  NSString *scriptSource = [NSString
      stringWithFormat:
          @"tell application \"Music\"\n"
           "    try\n"
           "        set rawArt to raw data of artwork 1 of current track\n"
           "        set fileRef to (open for access POSIX file \"%@\" with "
           "write permission)\n"
           "        set eof fileRef to 0\n"
           "        write rawArt to fileRef\n"
           "        close access fileRef\n"
           "        return \"OK\"\n"
           "    on error\n"
           "        return \"Error\"\n"
           "    end try\n"
           "end tell",
          tempPath];

  NSAppleScript *appleScript =
      [[NSAppleScript alloc] initWithSource:scriptSource];
  NSAppleEventDescriptor *result = [appleScript executeAndReturnError:nil];

  // 3. Si el script tuvo éxito, cargamos el archivo como NSImage
  if ([[result stringValue] isEqualToString:@"OK"]) {
    NSImage *artwork = [[NSImage alloc] initWithContentsOfFile:tempPath];
    if (artwork) {
      hb_retnll((HB_LONGLONG)[artwork autorelease]);
    } else {
      hb_retnll(0);
    }
  } else {
    hb_retnll(0);
  }

  hb_retnll(0); // No hay carátula o la app está cerrada
}

HB_FUNC(MUSICGETTRACKS) {
  NSString *libraryName = hb_NSSTRING_par(2);
  if (!libraryName || [libraryName length] == 0) {
    libraryName = @"Library";
  }

  PHB_ITEM pArray = hb_itemArrayNew(0);

  // tell application "Music" to get name of every track of library playlist 1
  NSString *scriptSource;
  if ([libraryName isEqualToString:@"Library"] ||
      [libraryName isEqualToString:@"Biblioteca"]) {
    scriptSource = @"tell application \"Music\" to get name of every track of "
                   @"library playlist 1";
  } else {
    scriptSource =
        [NSString stringWithFormat:@"tell application \"Music\" to get name of "
                                   @"every track of playlist \"%@\"",
                                   libraryName];
  }

  NSAppleScript *appleScript =
      [[NSAppleScript alloc] initWithSource:scriptSource];
  NSDictionary *errorInfo = nil;
  NSAppleEventDescriptor *result =
      [appleScript executeAndReturnError:&errorInfo];

  if (result) {
    // Result should be a list descriptor
    NSInteger count = [result numberOfItems];
    for (NSInteger i = 1; i <= count; i++) {
      NSAppleEventDescriptor *item = [result descriptorAtIndex:i];
      NSString *trackName = [item stringValue];
      if (trackName) {
        PHB_ITEM pItem = hb_itemPutC(NULL, [trackName UTF8String]);
        hb_arrayAdd(pArray, pItem);
        hb_itemRelease(pItem);
      }
    }
  } else {
    NSLog(@"[FiveMac Music] Error getting tracks: %@", errorInfo);
  }

  hb_itemReturnRelease(pArray);
}

HB_FUNC(MUSICGETCURRENTTRACKNUMBER) {
  @autoreleasepool {
    // Script para obtener el número de pista de la canción que suena
    NSString *scriptSource =
        @"tell application \"Music\" to get track number of current track";
    NSAppleScript *appleScript =
        [[NSAppleScript alloc] initWithSource:scriptSource];

    NSDictionary *errorInfo = nil;
    NSAppleEventDescriptor *descriptor =
        [appleScript executeAndReturnError:&errorInfo];

    if (descriptor != nil) {
      // El resultado de 'track number' es un entero
      int iTrackNum = (int)[descriptor int32Value];
      hb_retni(iTrackNum); // Devuelve el entero directamente a Harbour
    } else {
      // Si no hay nada sonando o hay error, devolvemos 0
      hb_retni(0);
    }
  }
}

HB_FUNC(MUSICGETCURRENTTRACKINDEX) {
  @autoreleasepool {
    // Script para obtener el número de pista de la canción que suena
    NSString *scriptSource =
        @"tell application \"Music\" to get index of current track";
    NSAppleScript *appleScript =
        [[NSAppleScript alloc] initWithSource:scriptSource];

    NSDictionary *errorInfo = nil;
    NSAppleEventDescriptor *descriptor =
        [appleScript executeAndReturnError:&errorInfo];

    if (descriptor != nil) {
      // El resultado de 'track number' es un entero
      int iTrackNum = (int)[descriptor int32Value];
      hb_retni(iTrackNum); // Devuelve el entero directamente a Harbour
    } else {
      // Si no hay nada sonando o hay error, devolvemos 0
      hb_retni(0);
    }
  }
}

HB_FUNC(MUSICPLAYBYINDEX) {
  @autoreleasepool {
    // Obtenemos el índice pasado desde Harbour: MusicPlayByIndex( 50 )
    long nIndex = hb_parnl(1);

    if (nIndex > 0) {
      // Script para reproducir la pista por su número de índice
      NSLog(@"[FiveMac Music] PlayByIndex called with index: %ld", nIndex);
      NSString *scriptSource =
          [NSString stringWithFormat:@"tell application \"Music\" to play "
                                     @"track %ld of library playlist 1",
                                     nIndex];

      NSAppleScript *appleScript =
          [[NSAppleScript alloc] initWithSource:scriptSource];

      NSDictionary *errorInfo = nil;
      [appleScript executeAndReturnError:&errorInfo];

      if (errorInfo) {
        NSLog(@"Error: %@", errorInfo);
        hb_retl(NO); // Devolvemos .F. si falló
      } else {
        hb_retl(YES); // Devolvemos .T. si tuvo éxito
      }
    } else {
      hb_retl(NO);
    }
  }
}

HB_FUNC(MUSICGETCURRENTDATABASEID) {
  @autoreleasepool {
    // Pedimos el database ID, que es único para cada pista en la biblioteca
    NSString *scriptSource =
        @"tell application \"Music\" to get database ID of current track";
    NSAppleScript *appleScript =
        [[NSAppleScript alloc] initWithSource:scriptSource];

    NSAppleEventDescriptor *descriptor =
        [appleScript executeAndReturnError:nil];

    if (descriptor) {
      // Los IDs de base de datos pueden ser números muy grandes
      hb_retnl((long)[descriptor int32Value]);
    } else {
      hb_retni(0);
    }
  }
}

HB_FUNC(MUSICDEBUG) {
  // No-op or simple print
  NSLog(@"[FiveMac Music] Debug called.");
}
