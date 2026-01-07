#include <fivemac.h>

HB_FUNC(CHKCREATE) {
  NSButton *checkbox =
      [[NSButton alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                 hb_parnl(3), hb_parnl(4))];
  NSString *string = hb_NSSTRING_par(5);

  NSWindow *window = (NSWindow *)hb_parnll(6);

  [checkbox setButtonType:NSButtonTypeSwitch];
  [checkbox setTitle:string];
  [GetView(window) addSubview:checkbox];
  [checkbox setAction:@selector(ChkClick:)];

  hb_retnll((HB_LONGLONG)checkbox);
}

HB_FUNC(CHKRESCREATE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSButton *checkbox = (NSButton *)[GetView(window) viewWithTag:hb_parnl(2)];

  [GetView(window) addSubview:checkbox];
  [checkbox setAction:@selector(ChkClick:)];

  hb_retnll((HB_LONGLONG)checkbox);
}

HB_FUNC(CHKSETSTATE) {
  NSButton *checkbox = (NSButton *)hb_parnll(1);

  [checkbox setState:hb_parl(2)];
}

HB_FUNC(CHKGETSTATE) {
  NSButton *checkbox = (NSButton *)hb_parnll(1);

  hb_retl((BOOL)[checkbox state]);
}
