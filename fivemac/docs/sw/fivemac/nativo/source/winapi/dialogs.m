#include <fivemac.h>

HB_FUNC(DLGMODAL) // hWnd
{
  NSWindow *window = (NSWindow *)hb_parnll(1);

  [window setReleasedWhenClosed:FALSE]; // this fix the runModalCleanup GPF !!!

  hb_retnl([NSApp runModalForWindow:window]);

  [window release]; // destroy it now!
}