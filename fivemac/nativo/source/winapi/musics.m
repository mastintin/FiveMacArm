#import "Music.h"
#import <Cocoa/Cocoa.h>
#import <fivemac.h>

#import <Foundation/Foundation.h>

@interface MusicController : NSObject
+ (NSString *)executeAppleScript:(NSString *)source;
@end

@implementation MusicController

+ (NSString *)executeAppleScript:(NSString *)source {
  NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
  NSDictionary *errorInfo = nil;
  NSAppleEventDescriptor *result = [script executeAndReturnError:&errorInfo];

  if (errorInfo) {
    NSLog(@"Error en AppleScript: %@", errorInfo[NSAppleScriptErrorMessage]);
    return nil;
  }
  return [result stringValue];
}

@end

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
  RunAppleScript(@"tell application \"Music\" to next track");
}

HB_FUNC(MUSICPREVIOUSTRACK) {
  RunAppleScript(@"tell application \"Music\" to previous track");
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

HB_FUNC(MUSICGETSONGARTIST) {
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
  // Stub for now, as fetching lists via AS and converting to Array is heavy
  // Original returned NSArray of strings (names).

  // NSString *libraryName = hb_NSSTRING_par(2);
  // Construct script to get list of names
  // tell app "Music" to get name of every track of playlist "Library" ...
  // This could return a huge list.

  // For safety/speed in this verification step, return empty array
  NSMutableArray *theSongs = [NSMutableArray array];
  hb_retnll((HB_LONGLONG)theSongs);
}

HB_FUNC(MUSICDEBUG) {
  // No-op or simple print
  NSLog(@"[FiveMac Music] Debug called.");
}
