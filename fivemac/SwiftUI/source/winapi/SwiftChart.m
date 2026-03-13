#import "SwiftCommon.h"
/*
HB_FUNC(SWIFTCHARTCREATE) {
  CGFloat nTop = (CGFloat)hb_parnd(1);
  CGFloat nLeft = (CGFloat)hb_parnd(2);
  CGFloat nWidth = (CGFloat)hb_parnd(3);
  CGFloat nHeight = (CGFloat)hb_parnd(4);
  NSWindow *window = (NSWindow *)hb_parnll(5);
  NSInteger nIndex = (NSInteger)hb_parnll(6);
  NSString *cId = hb_NSSTRING_par(7);
  NSString *cData = hb_NSSTRING_par(8);
  NSString *cType = hb_NSSTRING_par(9);

  NSView *chartView = [SwiftChartLoader makeChart:cId
                                             data:cData
                                             type:cType
                                            index:nIndex];

  if (chartView) {
    setupSwiftView(chartView, window, nTop, nLeft, nWidth, nHeight);
    hb_retnll((HB_LONGLONG)chartView);
  }
}

HB_FUNC(SWIFTCHARTSETDATA) {
  NSString *cData = hb_NSSTRING_par(1);
  NSString *cId = hb_NSSTRING_par(2);

  [SwiftChartLoader setData:cData id:cId];
}

HB_FUNC(SWIFTCHARTSETTYPE) {
  NSString *cType = hb_NSSTRING_par(1);
  NSString *cId = hb_NSSTRING_par(2);

  [SwiftChartLoader setType:cType id:cId];
}
HB_FUNC(SWIFTCHARTMAKESNAPSHOT) {
  NSString *cId = hb_NSSTRING_par(1);
  NSString *cPath = hb_NSSTRING_par(2);

  [SwiftChartLoader makeSnapshot:cId path:cPath];
}
*/
