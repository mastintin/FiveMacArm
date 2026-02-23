#import <AVFoundation/AVFoundation.h>
#import <Cocoa/Cocoa.h>
#include <fivemac.h>
#include <hbapi.h>
#include <hbapiitm.h>
#import <objc/runtime.h>

#ifndef NSEC_PER_SEC
#define NSEC_PER_SEC 1000000000ull
#endif

static char const *const FMMetadataDelegateKey = "FMMetadataDelegateKey";

//----------------------------------------------------------------------------//

@interface FMMetadataDelegate
    : NSObject <AVPlayerItemMetadataOutputPushDelegate>
@property(strong) NSMutableDictionary *metadata;
@property(assign) AVPlayer *player;
@property(strong) id timeToken;
@property(strong) id endToken;
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

  if (self.player) {
    PHB_DYNS pDynSym = hb_dynsymFindName("_FMAUDIO");
    if (pDynSym) {
      hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
      hb_vmPushNil();
      hb_vmPushNumInt((HB_LONGLONG)self.player);
      hb_vmPushLong(4); // nMsg == 4 for Metadata ready
      hb_vmDo(2);
    }
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"status"]) {
    AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];

    if (status == AVPlayerItemStatusReadyToPlay && context != NULL) {
      AVPlayer *player = (AVPlayer *)context;
      PHB_DYNS pDynSym = hb_dynsymFindName("_FMAUDIO");
      if (pDynSym) {
        hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
        hb_vmPushNil();
        hb_vmPushNumInt((HB_LONGLONG)player);
        hb_vmPushLong(3); // nMsg == 3 for ReadyToPlay
        hb_vmDo(2);
      }
    }
  } else if ([keyPath isEqualToString:@"timedMetadata"]) {
    NSArray<AVMetadataItem *> *metadata = change[NSKeyValueChangeNewKey];
    if ([metadata isKindOfClass:[NSArray class]]) {
      for (AVMetadataItem *item in metadata) {
        NSString *key = [item commonKey] ?: [item.key description];
        if (item.value) {
          if ([key isEqualToString:AVMetadataCommonKeyTitle] ||
              [key isEqualToString:@"title"])
            [_metadata setObject:item.value forKey:@"title"];
          else if ([key isEqualToString:AVMetadataCommonKeyArtist] ||
                   [key isEqualToString:@"artist"])
            [_metadata setObject:item.value forKey:@"artist"];
        }
      }
      if (context != NULL) {
        AVPlayer *player = (AVPlayer *)context;
        PHB_DYNS pDynSym = hb_dynsymFindName("_FMAUDIO");
        if (pDynSym) {
          hb_vmPushSymbol(hb_dynsymSymbol(pDynSym));
          hb_vmPushNil();
          hb_vmPushNumInt((HB_LONGLONG)player);
          hb_vmPushLong(4); // nMsg == 4 for Metadata ready
          hb_vmDo(2);
        }
      }
    }
  }
}

- (void)dealloc {
  [_metadata release];
  [_timeToken release];
  [_endToken release];
  [super dealloc];
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

    FMMetadataDelegate *delegate =
        objc_getAssociatedObject(player, FMMetadataDelegateKey);

    if (delegate) {
      delegate.timeToken = timeToken;
      delegate.endToken = endToken;
    }
  }
}

HB_FUNC(MUSIC_REMOVE_OBSERVERS) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);

  FMMetadataDelegate *delegate =
      objc_getAssociatedObject(player, FMMetadataDelegateKey);

  if (delegate) {
    if (player && delegate.timeToken) {
      [player removeTimeObserver:delegate.timeToken];
      delegate.timeToken = nil;
    }
    if (delegate.endToken) {
      [[NSNotificationCenter defaultCenter] removeObserver:delegate.endToken];
      delegate.endToken = nil;
    }
  }
}

HB_FUNC(MUSIC_LOAD_STREAM) {
  NSString *szUrl = hb_NSSTRING_par(1);

  if (!szUrl || [szUrl length] == 0) {
    hb_retnll(0);
    return;
  }

  NSURL *url = [NSURL URLWithString:szUrl];
  if (!url) {
    hb_retnll(0);
    return;
  }

  AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
  AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];

  // Implementación moderna de metadatos
  AVPlayerItemMetadataOutput *metadataOutput =
      [[AVPlayerItemMetadataOutput alloc] initWithIdentifiers:nil];
  FMMetadataDelegate *delegate = [[FMMetadataDelegate alloc] init];
  [metadataOutput setDelegate:delegate queue:dispatch_get_main_queue()];
  [item addOutput:metadataOutput];

  AVPlayer *player = [[AVPlayer playerWithPlayerItem:item] retain];
  delegate.player = player;

  if (item) {
    @try {
      [item addObserver:delegate
             forKeyPath:@"status"
                options:NSKeyValueObservingOptionNew
                context:(void *)player];
      [item addObserver:delegate
             forKeyPath:@"timedMetadata"
                options:NSKeyValueObservingOptionNew
                context:(void *)player];
    } @catch (id ex) {
    }
  }

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
    FMMetadataDelegate *delegate =
        objc_getAssociatedObject(player, FMMetadataDelegateKey);
    if (delegate) {
      if (delegate.timeToken) {
        [player removeTimeObserver:delegate.timeToken];
        delegate.timeToken = nil;
      }
      if (delegate.endToken) {
        [[NSNotificationCenter defaultCenter] removeObserver:delegate.endToken];
        delegate.endToken = nil;
      }

      if (player.currentItem) {
        @try {
          [player.currentItem removeObserver:delegate forKeyPath:@"status"];
        } @catch (id ex) {
        } @
        try {
          [player.currentItem removeObserver:delegate
                                  forKeyPath:@"timedMetadata"];
        } @catch (id ex) {
        }
      }
    }
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
  if (player) {
    [player play];
  }
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
    AVPlayerItemStatus status = player.currentItem.status;
    bReady = (status == AVPlayerItemStatusReadyToPlay);
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

static NSString *ExtractMetadataFromPlayer(AVPlayer *player) {
  NSMutableDictionary *metadataDict = [NSMutableDictionary dictionary];

  if (player) {
    if (player.currentItem) {
      // 1. Check FMMetadataDelegate (asynchronous)
      FMMetadataDelegate *delegate =
          objc_getAssociatedObject(player, FMMetadataDelegateKey);
      if (delegate) {
        [metadataDict addEntriesFromDictionary:delegate.metadata];
      }

      // 2. Check currentItem.timedMetadata (active metadata)
      for (AVMetadataItem *item in player.currentItem.timedMetadata) {
        NSString *key =
            [item commonKey] ? [item commonKey] : [item.key description];
        NSString *valStr =
            item.stringValue ? item.stringValue : [item.value description];
        if (valStr) {
          if ([key isEqualToString:AVMetadataCommonKeyTitle] ||
              [key containsString:@"title"])
            [metadataDict setObject:valStr forKey:@"title"];
          else if ([key isEqualToString:AVMetadataCommonKeyArtist] ||
                   [key containsString:@"artist"])
            [metadataDict setObject:valStr forKey:@"artist"];
        }
      }

      // 3. Check asset commonMetadata (static metadata)
      for (AVMetadataItem *item in [player.currentItem.asset commonMetadata]) {
        NSString *key =
            [item commonKey] ? [item commonKey] : [item.key description];
        NSString *valStr =
            item.stringValue ? item.stringValue : [item.value description];
        if (valStr) {
          if ([key isEqualToString:AVMetadataCommonKeyTitle])
            [metadataDict setObject:valStr forKey:@"title"];
          else if ([key isEqualToString:AVMetadataCommonKeyArtist])
            [metadataDict setObject:valStr forKey:@"artist"];
          else if ([key isEqualToString:AVMetadataCommonKeyAlbumName])
            [metadataDict setObject:valStr forKey:@"album"];
        }
      }
    }
  }

  NSString *artist = [metadataDict objectForKey:@"artist"];
  NSString *title = [metadataDict objectForKey:@"title"];
  NSString *album = [metadataDict objectForKey:@"album"];

  if ((!artist || [artist isEqualToString:@""]) && title &&
      [title isKindOfClass:[NSString class]] && [title containsString:@" - "]) {
    NSArray *parts = [title componentsSeparatedByString:@" - "];
    artist =
        [parts[0] stringByTrimmingCharactersInSet:[NSCharacterSet
                                                      whitespaceCharacterSet]];
    title =
        [parts[1] stringByTrimmingCharactersInSet:[NSCharacterSet
                                                      whitespaceCharacterSet]];
  }

  return [NSString stringWithFormat:@"%@|%@|%@", title ? title : @"",
                                    artist ? artist : @"", album ? album : @""];
}

HB_FUNC(MUSIC_GET_METADATA) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  NSString *result = ExtractMetadataFromPlayer(player);
  hb_retc([result UTF8String]);
}

HB_FUNC(NATIVEAUDIOGETMETADATA) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  NSString *result = ExtractMetadataFromPlayer(player);
  hb_retc([result UTF8String]);
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

HB_FUNC(MUSIC_ISPLAYING) {
  AVPlayer *player = (AVPlayer *)hb_parnll(1);
  if (player) {
    hb_retl(player.rate != 0);
  } else {
    hb_retl(NO);
  }
}
