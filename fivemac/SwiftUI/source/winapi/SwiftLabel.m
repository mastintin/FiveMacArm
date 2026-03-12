#import "SwiftCommon.h"
/*
HB_FUNC(SWIFTLABELCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSString *cText = hb_NSSTRING_par(5);
  id parent = (id)hb_parnll(6);
  NSInteger nIndex = (NSInteger)hb_parnl(7);

  // Direct call to Swift instead of NSInvocation
  NSView *labelView = [SwiftLabelLoader makeLabelWithText:cText index:nIndex];

  if (labelView) {
    setupSwiftView(labelView, parent, nTop, nLeft, nWidth, nHeight);
    hb_retnll((HB_LONGLONG)labelView);
  }
}
*/
/*
HB_FUNC(SWIFTUPDATELABEL) {
  // Keeping this for legacy/compatibility if needed, but routing it to the new
  // bridge
  NSString *text = hb_NSSTRING_par(2);
  NSInteger nIndex = (NSInteger)hb_parnl(3);
  NSString *idx = [NSString stringWithFormat:@"%ld", (long)nIndex];

  SW_LBL_SET_TEXT((const int8_t *)[idx UTF8String],
                  (const int8_t *)[text UTF8String]);
}

HB_FUNC(SWIFTLABELSETFONT) {
  double nSize = hb_parnd(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);
  NSString *idx = [NSString stringWithFormat:@"%ld", (long)nIndex];
  NSString *val = [NSString stringWithFormat:@"%f", nSize];

  SW_LBL_SET_FONT((const int8_t *)[idx UTF8String],
                  (const int8_t *)[val UTF8String]);
}

HB_FUNC(SWIFTLABELSETCOLOR) {
  long nColor = hb_parnl(1);
  NSInteger nIndex = (NSInteger)hb_parni(2);

  int r = nColor & 0xFF;
  int g = (nColor >> 8) & 0xFF;
  int b = (nColor >> 16) & 0xFF;
  NSString *hexColor = [NSString stringWithFormat:@"%02X%02X%02X", r, g, b];
  NSString *idx = [NSString stringWithFormat:@"%ld", (long)nIndex];

  SW_LBL_SET_COLOR((const int8_t *)[idx UTF8String],
                   (const int8_t *)[hexColor UTF8String]);
}

HB_FUNC(LBL_SET_COLOR) {
  NSString *idx = hb_NSSTRING_par(1);
  NSString *hex = hb_NSSTRING_par(2);
  SW_LBL_SET_COLOR((const int8_t *)[idx UTF8String],
                   (const int8_t *)[hex UTF8String]);
}
*/