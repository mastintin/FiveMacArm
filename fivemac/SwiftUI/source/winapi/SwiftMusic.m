#import "SwiftCommon.h"

HB_FUNC(SWIFTMUSICPLAY) { [SwiftMusicLoader play]; }

HB_FUNC(SWIFTMUSICPAUSE) { [SwiftMusicLoader pause]; }

HB_FUNC(SWIFTMUSICNEXT) { [SwiftMusicLoader next]; }

HB_FUNC(SWIFTMUSICPREV) { [SwiftMusicLoader previous]; }

HB_FUNC(SWIFTMUSICSTOP) { [SwiftMusicLoader stop]; }

HB_FUNC(SWIFTMUSICAUTH) { [SwiftMusicLoader requestAuth]; }

HB_FUNC(SWIFTMUSICSTATE) { hb_retni((int)[SwiftMusicLoader getState]); }

HB_FUNC(SWIFTMUSICMETADATA) {
  NSString *result = [SwiftMusicLoader getCurrentTrack];
  hb_retc(result ? [result UTF8String] : "{}");
}

HB_FUNC(SWIFTMUSICGETARTWORK) {
  NSString *result = [SwiftMusicLoader getArtworkPath];
  hb_retc(result ? [result UTF8String] : "");
}

HB_FUNC(SWIFTMUSICGETDURATION) { hb_retnd([SwiftMusicLoader getDuration]); }

HB_FUNC(SWIFTMUSICGETPOSITION) { hb_retnd([SwiftMusicLoader getPosition]); }

HB_FUNC(SWIFTMUSICSETPOSITION) {
  double seconds = hb_parnd(1);
  [SwiftMusicLoader setPositionWithSeconds:seconds];
}

HB_FUNC(SWIFTMUSICGETVOLUME) { hb_retni((int)[SwiftMusicLoader getVolume]); }

HB_FUNC(SWIFTMUSICSETVOLUME) {
  NSInteger vol = (NSInteger)hb_parni(1);
  [SwiftMusicLoader setVolumeWithVol:vol];
}

HB_FUNC(SWIFTMUSICGETPLAYLISTS) {
  NSString *result = [SwiftMusicLoader getPlaylists];
  hb_retc(result ? [result UTF8String] : "[]");
}

HB_FUNC(SWIFTMUSICPLAYPLAYLIST) {
  NSString *name = hb_NSSTRING_par(1);
  [SwiftMusicLoader playPlaylistWithName:name];
}

HB_FUNC(SWIFTMUSICPLAYFIRST) { [SwiftMusicLoader playFirstAvailablePlaylist]; }
