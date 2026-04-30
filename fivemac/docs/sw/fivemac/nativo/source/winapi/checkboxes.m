#include <fivemac.h>

HB_FUNC(CHKCREATE) {
  BOOL bSwitch = hb_parl(7);

  NSControl *control;

  if (bSwitch && NSClassFromString(@"NSSwitch")) {
    control = [[NSClassFromString(@"NSSwitch") alloc]
        initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3),
                                 hb_parnl(4))];
  } else {
    NSButton *button =
        [[NSButton alloc] initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1),
                                                   hb_parnl(3), hb_parnl(4))];
    [button setButtonType:NSButtonTypeSwitch];
    [button setTitle:hb_NSSTRING_par(5)];
    control = button;
  }

  NSWindow *window = (NSWindow *)hb_parnll(6);

  [GetView(window) addSubview:control];
  [control setAction:@selector(ChkClick:)];

  hb_retnll((HB_LONGLONG)control);
}

HB_FUNC(CHKRESCREATE) {
  NSWindow *window = (NSWindow *)hb_parnll(1);
  NSControl *checkbox = (NSControl *)[GetView(window) viewWithTag:hb_parnl(2)];

  [GetView(window) addSubview:checkbox];
  [checkbox setAction:@selector(ChkClick:)];

  hb_retnll((HB_LONGLONG)checkbox);
}

HB_FUNC(CHKSETSTATE) {
  NSControl *checkbox = (NSControl *)hb_parnll(1);

  [checkbox setIntValue:hb_parl(2)];
}

HB_FUNC(CHKGETSTATE) {
  NSControl *checkbox = (NSControl *)hb_parnll(1);

  hb_retl((BOOL)[checkbox intValue]);
}
