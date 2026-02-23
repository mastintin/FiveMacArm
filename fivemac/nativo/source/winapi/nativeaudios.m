#import <AVFoundation/AVFoundation.h>
#import <Cocoa/Cocoa.h>
#include <fivemac.h>

#ifndef NSEC_PER_SEC
#define NSEC_PER_SEC 1000000000ull
#endif

//----------------------------------------------------------------------------//

// Función que FiveMac llamará para activar el observador
HB_FUNC(MUSIC_SET_OBSERVER) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  if (player) {
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);

    [player
        addPeriodicTimeObserverForInterval:interval
                                     queue:dispatch_get_main_queue()
                                usingBlock:^(CMTime time) {
                                  // --- LLAMADA DE VUELTA A HARBOUR ---
                                  // Esto ejecuta la función "_FMAUDIO" en
                                  // tu PRG cada vez que el player avanza
                                  PHB_DYNS pDynSym =
                                      hb_dynsymFindName("_FMAUDIO");
                                  if (pDynSym) {
                                    hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
                                    hb_vmPushNil();
                                    hb_vmPushNumInt((HB_LONGLONG)player);
                                    hb_vmDo(1);
                                  }
                                }];
  }
}

HB_FUNC(NATIVEAUDIOCREATE) {
  NSString *cFile = hb_NSSTRING_par(1);
  NSURL *url = [NSURL fileURLWithPath:cFile];
  AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
  AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];

  hb_retnll((HB_LONGLONG)player);
}

HB_FUNC(NATIVEAUDIOPLAY) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  [player play];
}

HB_FUNC(NATIVEAUDIOPAUSE) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  [player pause];
}

HB_FUNC(NATIVEAUDIOSTOP) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  [player pause];
  [player seekToTime:kCMTimeZero];
}

HB_FUNC(NATIVEAUDIOGETDURATION) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  CMTime duration = player.currentItem.asset.duration;
  if (CMTIME_IS_VALID(duration))
    hb_retnd(CMTimeGetSeconds(duration));
  else
    hb_retnd(0);
}

HB_FUNC(NATIVEAUDIOGETTIME) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  CMTime time = player.currentTime;
  if (CMTIME_IS_VALID(time))
    hb_retnd(CMTimeGetSeconds(time));
  else
    hb_retnd(0);
}

HB_FUNC(NATIVEAUDIOSEEK) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  double seconds = hb_parnd(2);
  [player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC)];
}

HB_FUNC(NATIVEAUDIOSETVOL) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  [player setVolume:(float)hb_parni(2) / 100.0f];
}

HB_FUNC(NATIVEAUDIOGETMETADATA) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  AVAsset *asset = player.currentItem.asset;
  __block NSString *cTitle = @"";
  __block NSString *cArtist = @"";
  __block NSString *cAlbum = @"";

  for (AVMetadataItem *item in [asset commonMetadata]) {
    if ([item.commonKey isEqualToString:AVMetadataCommonKeyTitle])
      cTitle = item.stringValue;
    else if ([item.commonKey isEqualToString:AVMetadataCommonKeyArtist])
      cArtist = item.stringValue;
    else if ([item.commonKey isEqualToString:AVMetadataCommonKeyAlbumName])
      cAlbum = item.stringValue;
  }

  NSString *res = [NSString stringWithFormat:@"%@|%@|%@", cTitle ? cTitle : @"",
                                             cArtist ? cArtist : @"",
                                             cAlbum ? cAlbum : @""];

  hb_retc([res UTF8String]);
}

HB_FUNC(NATIVEAUDIOGETARTWORK) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  AVAsset *asset = player.currentItem.asset;

  for (AVMetadataItem *item in [asset commonMetadata]) {
    if ([item.commonKey isEqualToString:AVMetadataCommonKeyArtwork]) {
      NSData *data = (NSData *)item.value;
      NSImage *image = [[NSImage alloc] initWithData:data];
      hb_retnll((HB_LONGLONG)[image autorelease]);
      return;
    }
  }
  hb_retnll(0);
}
