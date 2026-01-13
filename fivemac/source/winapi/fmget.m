#include "formatters.h"
#include <fivemac.h>

static PHB_SYMB symFMH = NULL;

@interface FMGet : NSTextField <NSTextFieldDelegate> {
}
- (void)controlTextDidChange:(NSNotification *)aNotification;
- (void)controlTextDidEndEditing:(NSNotification *)aNotification;
@end

@implementation FMGet

- (void)controlTextDidChange:(NSNotification *)aNotification {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMO"));

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNumInt((HB_LONGLONG)[self window]);
  hb_vmPushLong(WM_GETCHANGED);
  hb_vmPushNumInt((HB_LONGLONG)self);
  hb_vmDo(3);
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
  if (symFMH == NULL)
    symFMH = hb_dynsymSymbol(hb_dynsymFindName("_FMO"));

  hb_vmPushSymbol(symFMH);
  hb_vmPushNil();
  hb_vmPushNumInt((HB_LONGLONG)[self window]);
  hb_vmPushLong(WM_GETVALID);
  hb_vmPushNumInt((HB_LONGLONG)self);
  hb_vmDo(3);
}

@end

HB_FUNC(FMGETCREATE) {
  FMGet *edit =
      [[FMGet alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                              hb_parnl(3), hb_parnl(4))];
  NSWindow *window = (NSWindow *)hb_parnll(5);

  [GetView(window) addSubview:edit];
  [edit setDelegate:edit];

  hb_retnll((HB_LONGLONG)edit);
}

HB_FUNC(FMGETSETTEXT) {
  NSTextField *get = (NSTextField *)hb_parnll(1);
  NSString *string = hb_NSSTRING_par(2);

  [get setStringValue:string];
}

HB_FUNC(FMGETGETTEXT) {
  NSTextField *get = (NSTextField *)hb_parnll(1);
  NSString *string = [get stringValue];

  hb_retc([string cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(FMGETSETFORMATTER) {
  NSTextField *control = (NSTextField *)hb_parnll(1);
  FMFormatter *formatter = [[[FMFormatter alloc] init] autorelease];

  formatter->control = control;

  [[control cell] setFormatter:formatter];
}

HB_FUNC(FMGETSETUPPER) {
  NSTextField *control = (NSTextField *)hb_parnll(1);
  FMUpperFormatter *formatter = [[[FMUpperFormatter alloc] init] autorelease];

  [[control cell] setFormatter:formatter];
}

HB_FUNC(FMGETSETALPHA) {
  NSTextField *control = (NSTextField *)hb_parnll(1);
  FMAlphaFormatter *formatter = [[[FMAlphaFormatter alloc] init] autorelease];

  [[control cell] setFormatter:formatter];
}

HB_FUNC(FMGETSETDATE) {
  NSTextField *control = (NSTextField *)hb_parnll(1);
  FMDateFormatter *formatter = [[[FMDateFormatter alloc] init] autorelease];

  [formatter setDateStyle:NSDateFormatterShortStyle];
  [formatter setTimeStyle:NSDateFormatterNoStyle];

  [[control cell] setFormatter:formatter];
}

HB_FUNC(FMGETSETPICTURE) {
  NSTextField *control = (NSTextField *)hb_parnll(1);
  NSString *str = hb_NSSTRING_par(2); // Picture string
  FMPictureFormatter *formatter =
      [[[FMPictureFormatter alloc] init] autorelease];

  formatter->picture = [str retain];

  [[control cell] setFormatter:formatter];
}

HB_FUNC(FMGETSETEURONUMBER) {
  NSTextField *control = (NSTextField *)hb_parnll(1);
  NSString *picture = hb_NSSTRING_par(2);

  FMEuroNumberFormatter *formatter =
      [[[FMEuroNumberFormatter alloc] init] autorelease];

  if (picture && [picture length] > 0) {
    // Parse picture "999.99"
    NSRange dotRange = [picture rangeOfString:@"."];
    if (dotRange.location != NSNotFound) {
      int decimals = [picture length] - dotRange.location - 1;
      [formatter setMinimumFractionDigits:0];
      [formatter setMaximumFractionDigits:decimals];

      // Calculate max integer digits: count '9's before dot
      NSString *intPart = [picture substringToIndex:dotRange.location];
      int nineCount = 0;
      for (int i = 0; i < [intPart length]; i++)
        if ([intPart characterAtIndex:i] == '9')
          nineCount++;

      formatter->maxIntegerDigits = nineCount;
    } else {
      [formatter setMinimumFractionDigits:0];
      [formatter setMaximumFractionDigits:0];

      // Count '9's in whole string
      int nineCount = 0;
      for (int i = 0; i < [picture length]; i++)
        if ([picture characterAtIndex:i] == '9')
          nineCount++;

      formatter->maxIntegerDigits = nineCount;
    }

    if ([picture rangeOfString:@","].location != NSNotFound)
      [formatter setUsesGroupingSeparator:YES];
    else
      [formatter setUsesGroupingSeparator:NO];
  }

  [[control cell] setFormatter:formatter];
}

HB_FUNC(FMGETSETEURODATE) {
  NSTextField *control = (NSTextField *)hb_parnll(1);
  FMEuroDateFormatter *formatter =
      [[[FMEuroDateFormatter alloc] init] autorelease];
  [[control cell] setFormatter:formatter];
}
