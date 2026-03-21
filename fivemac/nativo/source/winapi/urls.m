#include <fivemac.h>

HB_FUNC(CREATEURL) {
  NSString *string = hb_NSSTRING_par(1);
  NSURL *name = [[[NSURL alloc] initWithString:string] autorelease];

  hb_retnll((HB_LONGLONG)name);
}

HB_FUNC(CREATEURLFILE) {
  NSString *string = hb_NSSTRING_par(1);
  NSURL *name = [[[NSURL alloc] initFileURLWithPath:string] autorelease];

  hb_retnll((HB_LONGLONG)name);
}

HB_FUNC(URLPATH) {
  NSURL *name = (NSURL *)hb_parnll(1);
  NSString *source = [[name path] stringByRemovingPercentEncoding];

  hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(URLPATHEXTENSION) {
  NSURL *name = (NSURL *)hb_parnll(1);
  NSString *source = [name pathExtension];

  hb_retc([source cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(URLLOAD) {
  NSString *string = hb_NSSTRING_par(1);
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:string]];
}
