#import <AVFoundation/AVFoundation.h>
#import <Cocoa/Cocoa.h>
#include <fivemac.h>
#import <objc/runtime.h>

#ifndef NSEC_PER_SEC
#define NSEC_PER_SEC 1000000000ull
#endif

static char const *const FMMetadataDelegateKey = "FMMetadataDelegateKey";

//----------------------------------------------------------------------------//

@interface FMMetadataDelegate
    : NSObject <AVPlayerItemMetadataOutputPushDelegate>
@property(strong) NSMutableDictionary *metadata;
@end

@implementation FMMetadataDelegate

- (instancetype)init {
  self = [super init];
  if (self) {
    _metadata = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)metadataOutput:(AVPlayerItemMetadataOutput *)output
    didOutputTimedMetadataGroups:(NSArray<AVTimedMetadataGroup *> *)groups
             fromPlayerItemTrack:(AVPlayerItemTrack *)track {

  for (AVTimedMetadataGroup *group in groups) {
    for (AVMetadataItem *item in group.items) {
      NSString *key = [item commonKey];
      if (!key)
        key = [item.key description];

      if (item.value) {
        if ([key isEqualToString:AVMetadataCommonKeyTitle] ||
            [key isEqualToString:@"title"])
          [_metadata setObject:item.value forKey:@"title"];
        else if ([key isEqualToString:AVMetadataCommonKeyArtist] ||
                 [key isEqualToString:@"artist"])
          [_metadata setObject:item.value forKey:@"artist"];
      }
    }
  }
}

@end

//----------------------------------------------------------------------------//

HB_FUNC(MUSIC_SET_OBSERVER) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  if (player) {
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);

    id timeToken = [player
        addPeriodicTimeObserverForInterval:interval
                                     queue:dispatch_get_main_queue()
                                usingBlock:^(CMTime time) {
                                  PHB_DYNS pDynSym =
                                      hb_dynsymFindName("_FMAUDIO");
                                  if (pDynSym) {
                                    hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
                                    hb_vmPushNil();
                                    hb_vmPushNumInt((HB_LONGLONG)player);
                                    hb_vmPushLong(1);
                                    hb_vmDo(2);
                                  }
                                }];

    __block id endToken = nil;
    if (player.currentItem) {
      endToken = [[NSNotificationCenter defaultCenter]
          addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                      object:player.currentItem
                       queue:[NSOperationQueue mainQueue]
                  usingBlock:^(NSNotification *_Nonnull note) {
                    PHB_DYNS pDynSym = hb_dynsymFindName("_FMAUDIO");
                    if (pDynSym) {
                      hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
                      hb_vmPushNil();
                      hb_vmPushNumInt((HB_LONGLONG)player);
                      hb_vmPushLong(2);
                      hb_vmDo(2);
                    }
                  }];
    }

    PHB_ITEM pArray = hb_itemArrayNew(2);
    PHB_ITEM pToken1 = hb_itemPutNLL(NULL, (HB_LONGLONG)timeToken);
    PHB_ITEM pToken2 = hb_itemPutNLL(NULL, (HB_LONGLONG)endToken);
    hb_arraySet(pArray, 1, pToken1);
    hb_arraySet(pArray, 2, pToken2);
    hb_itemRelease(pToken1);
    hb_itemRelease(pToken2);

    hb_itemReturnRelease(pArray);
  }
}

HB_FUNC(MUSIC_REMOVE_OBSERVERS) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  id timeToken = (id)hb_parnll(2);
  id endToken = (id)hb_parnll(3);

  if (player && timeToken) {
    [player removeTimeObserver:timeToken];
  }
  if (endToken) {
    [[NSNotificationCenter defaultCenter] removeObserver:endToken];
  }
}

HB_FUNC(MUSIC_LOAD_STREAM) {
  NSString *szUrl = hb_NSSTRING_par(1);
  NSURL *url = [NSURL URLWithString:szUrl];

  AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
  AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];

  // Implementación moderna de metadatos
  AVPlayerItemMetadataOutput *metadataOutput =
      [[AVPlayerItemMetadataOutput alloc] initWithIdentifiers:nil];
  FMMetadataDelegate *delegate = [[FMMetadataDelegate alloc] init];
  [metadataOutput setDelegate:delegate queue:dispatch_get_main_queue()];
  [item addOutput:metadataOutput];

  AVPlayer *player = [[AVPlayer playerWithPlayerItem:item] retain];

  // Asociamos el delegado al player para que viva lo mismo que él
  objc_setAssociatedObject(player, FMMetadataDelegateKey, delegate,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [metadataOutput release];
  [delegate release];

  hb_retnll((HB_LONGLONG)player);
}

HB_FUNC(MUSIC_RELEASE) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  if (player) {
    [player release];
  }
}

HB_FUNC(NATIVEAUDIOCREATE) {
  NSString *cFile = hb_NSSTRING_par(1);
  NSURL *url = [NSURL fileURLWithPath:cFile];
  AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
  AVPlayer *player = [[AVPlayer playerWithPlayerItem:playerItem] retain];

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

HB_FUNC(NATIVEAUDIOISREADY) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  BOOL bReady = NO;
  if (player && player.currentItem) {
    bReady = (player.currentItem.status == AVPlayerItemStatusReadyToPlay);
  }
  hb_retl(bReady);
}

HB_FUNC(NATIVEAUDIOGETSTATUS) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  if (player) {
    if (player.currentItem) {
      hb_retni((int)player.currentItem.status);
    } else {
      hb_retni(-1);
    }
  } else {
    hb_retni(-2);
  }
}

HB_FUNC(MUSIC_GET_METADATA) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  NSMutableDictionary *metadataDict = [NSMutableDictionary dictionary];

  if (player) {
    FMMetadataDelegate *delegate =
        objc_getAssociatedObject(player, FMMetadataDelegateKey);
    if (delegate) {
      [metadataDict addEntriesFromDictionary:delegate.metadata];
    }

    if (player.currentItem) {
      for (AVMetadataItem *item in [player.currentItem.asset commonMetadata]) {
        NSString *key = [item commonKey];
        if (item.value) {
          if ([key isEqualToString:AVMetadataCommonKeyTitle])
            [metadataDict setObject:item.value forKey:@"title"];
          else if ([key isEqualToString:AVMetadataCommonKeyArtist])
            [metadataDict setObject:item.value forKey:@"artist"];
        }
      }
    }
  }

  NSString *artist = [metadataDict objectForKey:@"artist"];
  NSString *title = [metadataDict objectForKey:@"title"];

  if ((!artist || [artist isEqualToString:@""]) && title &&
      [title containsString:@" - "]) {
    NSArray *parts = [title componentsSeparatedByString:@" - "];
    artist =
        [parts[0] stringByTrimmingCharactersInSet:[NSCharacterSet
                                                      whitespaceCharacterSet]];
    title =
        [parts[1] stringByTrimmingCharactersInSet:[NSCharacterSet
                                                      whitespaceCharacterSet]];
  }

  NSString *result =
      [NSString stringWithFormat:@"%@ - %@", artist ? artist : @"Unknown",
                                 title ? title : @"Unknown"];
  hb_retc([result UTF8String]);
}

HB_FUNC(NATIVEAUDIOGETMETADATA) { HB_FUNC_EXEC(MUSIC_GET_METADATA); }

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

HB_FUNC(MUSIC_ISPLAYING) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  if (player) {
    hb_retl(player.rate != 0);
  } else {
    hb_retl(NO);
  }
}
