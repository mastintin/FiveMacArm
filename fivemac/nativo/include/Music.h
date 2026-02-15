/*
 * Music.h
 * Scripting Bridge header for Music app (derived from iTunes.h)
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>

@class MusicPrintSettings, MusicApplication, MusicItem, MusicArtwork,
    MusicEncoder, MusicEQPreset, MusicPlaylist, MusicAudioCDPlaylist,
    MusicDevicePlaylist, MusicLibraryPlaylist, MusicRadioTunerPlaylist,
    MusicSource, MusicTrack, MusicAudioCDTrack, MusicDeviceTrack,
    MusicFileTrack, MusicSharedTrack, MusicURLTrack, MusicUserPlaylist,
    MusicFolderPlaylist, MusicVisual, MusicWindow, MusicBrowserWindow,
    MusicEQWindow, MusicPlaylistWindow;

// Enums from iTunes.h often map directly to Music app
enum MusicESrc {
  MusicESrcLibrary = 'kLib',
  MusicESrcIPod = 'kPod',
  MusicESrcAudioCD = 'kACD',
  MusicESrcMP3CD = 'kMCD',
  MusicESrcDevice = 'kDev',
  MusicESrcRadioTuner = 'kTun',
  MusicESrcSharedLibrary = 'kShd',
  MusicESrcUnknown = 'kUnk'
};
typedef enum MusicESrc MusicESrc;

enum MusicESpK {
  MusicESpKNone = 'kNon',
  MusicESpKBooks = 'kSpA',
  MusicESpKFolder = 'kSpF',
  MusicESpKGenius = 'kSpG',
  MusicESpKITunesU = 'kSpU',
  MusicESpKLibrary = 'kSpL',
  MusicESpKMovies = 'kSpI',
  MusicESpKMusic = 'kSpZ',
  MusicESpKPartyShuffle = 'kSpS',
  MusicESpKPodcasts = 'kSpP',
  MusicESpKPurchasedMusic = 'kSpM',
  MusicESpKTVShows = 'kSpT'
};
typedef enum MusicESpK MusicESpK;

enum MusicEPlS {
  MusicEPlSStopped = 'kPSS',
  MusicEPlSPlaying = 'kPSP',
  MusicEPlSPaused = 'kPSp',
  MusicEPlSFastForwarding = 'kPSF',
  MusicEPlSRewinding = 'kPSR'
};
typedef enum MusicEPlS MusicEPlS;

@interface MusicApplication : SBApplication
- (SBElementArray *)sources;
- (SBElementArray *)windows;
@property(copy, readonly) MusicTrack *currentTrack;
@property(readonly) MusicEPlS playerState;
@property NSInteger soundVolume;
@property(copy, readonly) NSString *name;
@property(copy, readonly) NSString *version;
- (void)run;
- (void)quit;
- (void)playOnce:(BOOL)once;
- (void)play;
- (void)stop;
- (void)pause;
- (void)playpause;
- (void)nextTrack;
- (void)previousTrack;
- (void)backTrack;
- (MusicTrack *)add:(NSArray *)x to:(SBObject *)to;
@end

@interface MusicItem : SBObject
@property(copy) NSString *name;
@property(copy, readonly) NSString *persistentID;
@end

@interface MusicTrack : MusicItem
- (SBElementArray *)artworks;
@property(copy) NSString *album;
@property(copy) NSString *artist;
@property(readonly) double duration;
@property NSInteger rating;
@property(copy) NSString *lyrics;
@end

@interface MusicArtwork : MusicItem
@property(copy) NSImage *data;
@end

@interface MusicSource : MusicItem
- (SBElementArray *)playlists;
@property(readonly) MusicESrc kind;
@end

@interface MusicPlaylist : MusicItem
- (SBElementArray *)tracks;
@property(readonly) MusicESpK specialKind;
@end

@interface MusicLibraryPlaylist : MusicPlaylist
@end
