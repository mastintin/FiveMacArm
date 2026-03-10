#import "SwiftCommon.h"

static PHB_ITEM pOnTranscription = NULL;
static PHB_ITEM pOnMetrics = NULL;
static PHB_ITEM pOnError = NULL;

static void initManagerBlocks() {
  SwiftSpeechManager *manager = [SwiftSpeechManager shared];

  if (manager.onTranscription == nil) {
    manager.onTranscription = ^(NSString *text, BOOL isFinal) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (pOnTranscription) {
          hb_vmPushSymbol(hb_dynsymSymbol(hb_dynsymFindName("EVAL")));
          hb_vmPush(pOnTranscription);
          hb_vmPushString([text UTF8String], [text length]);
          hb_vmPushLogical(isFinal);
          hb_vmDo(2);
        }
      });
    };
  }

  if (manager.onVocalMetrics == nil) {
    manager.onVocalMetrics = ^(double pitch, double jitter, double shimmer) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (pOnMetrics) {
          hb_vmPushSymbol(hb_dynsymSymbol(hb_dynsymFindName("EVAL")));
          hb_vmPush(pOnMetrics);
          hb_vmPushDouble(pitch, 4);
          hb_vmPushDouble(jitter, 4);
          hb_vmPushDouble(shimmer, 4);
          hb_vmDo(3);
        }
      });
    };
  }

  if (manager.onError == nil) {
    manager.onError = ^(NSString *msg) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (pOnError) {
          hb_vmPushSymbol(hb_dynsymSymbol(hb_dynsymFindName("EVAL")));
          hb_vmPush(pOnError);
          hb_vmPushString([msg UTF8String], [msg length]);
          hb_vmDo(1);
        }
      });
    };
  }
}

HB_FUNC(SWIFTSPEECHSTART) {
  initManagerBlocks();
  [[SwiftSpeechManager shared] start];
}

HB_FUNC(SWIFTSPEECHSTOP) { [[SwiftSpeechManager shared] stop]; }

HB_FUNC(SWIFTSPEECHSETTRANSCRIPTIONCB) {
  if (pOnTranscription)
    hb_itemRelease(pOnTranscription);

  pOnTranscription = hb_itemNew(hb_param(1, HB_IT_ANY));
  initManagerBlocks();
}

HB_FUNC(SWIFTSPEECHSETMETRICSCB) {
  if (pOnMetrics)
    hb_itemRelease(pOnMetrics);

  pOnMetrics = hb_itemNew(hb_param(1, HB_IT_ANY));
  initManagerBlocks();
}

HB_FUNC(SWIFTSPEECHSETERRORCB) {
  if (pOnError)
    hb_itemRelease(pOnError);

  pOnError = hb_itemNew(hb_param(1, HB_IT_ANY));
  initManagerBlocks();
}

HB_FUNC(SWIFTSPEECHSETLOCALE) {
  NSString *localeId = hb_NSSTRING_par(1);
  [[SwiftSpeechManager shared] setLocale:localeId];
}

HB_FUNC(SWIFTSPEECHRECORDFILE) {
  NSString *path = hb_NSSTRING_par(1);
  [[SwiftSpeechManager shared] recordToFile:path];
}

HB_FUNC(SWIFTSPEECHSTOPRECORDING) {
  [[SwiftSpeechManager shared] stopRecording];
}

HB_FUNC(SWIFTSPEECHTRANSCRIBEFILE) {
  initManagerBlocks();
  NSString *path = hb_NSSTRING_par(1);
  [[SwiftSpeechManager shared] transcribeFile:path];
}
