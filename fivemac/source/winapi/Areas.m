#include <fivemac.h>

// NSRECT_NEW( x, y, w, h ) -> pRect
HB_FUNC(NSRECTNEW) {
  NSRect *rect = (NSRect *)hb_xgrab(sizeof(NSRect));
  rect->origin.x = hb_parnl(1);
  rect->origin.y = hb_parnl(2);
  rect->size.width = hb_parnl(3);
  rect->size.height = hb_parnl(4);

  hb_retnll((HB_LONGLONG)rect);
}

// NSRECT_RELEASE( pRect )
HB_FUNC(NSRECTRELEASE) { hb_xfree((void *)hb_parnll(1)); }

// NSRECT_FROM_ARRAY( aRect ) -> pRect (allocates new structure)
// aRect should be { x, y, w, h }
HB_FUNC(NSRECTFROMARRAY) {
  NSRect *rect = (NSRect *)hb_xgrab(sizeof(NSRect));

  // hb_parvnl( iParam, iIndex )
  rect->origin.x = hb_parvnl(1, 1);
  rect->origin.y = hb_parvnl(1, 2);
  rect->size.width = hb_parvnl(1, 3);
  rect->size.height = hb_parvnl(1, 4);

  hb_retnll((HB_LONGLONG)rect);
}

// NSRECT_TO_ARRAY( pRect ) -> aRect { x, y, w, h }
HB_FUNC(NSRECTTOARRAY) {
  NSRect *rect = (NSRect *)hb_parnll(1);

  hb_reta(4);

  if (rect) {
    hb_storvnl((long)rect->origin.x, -1, 1);
    hb_storvnl((long)rect->origin.y, -1, 2);
    hb_storvnl((long)rect->size.width, -1, 3);
    hb_storvnl((long)rect->size.height, -1, 4);
  }
}

// NSPOINT_IN_RECT( nRow, nCol, pRect ) -> BOOL
HB_FUNC(NSPOINTINRECT) {
  NSPoint point;
  NSRect *rect = (NSRect *)hb_parnll(3);

  point.y = hb_parnl(1);
  point.x = hb_parnl(2);

  hb_retl(NSPointInRect(point, *rect));
}

// NSRECT_OFFSET( pRect, nOffY, nOffX, nWidth, nHeight ) -> pNewRect
HB_FUNC(NSRECTOFFSET) {
  NSRect *parent = (NSRect *)hb_parnll(1);
  NSRect *rect = (NSRect *)hb_xgrab(sizeof(NSRect));

  rect->origin.y = parent->origin.y + hb_parnl(2);
  rect->origin.x = parent->origin.x + hb_parnl(3);
  rect->size.width = hb_parnl(4);
  rect->size.height = hb_parnl(5);

  hb_retnll((HB_LONGLONG)rect);
}

// NSRECT_SET( pRect, nY, nX, nWidth, nHeight )
HB_FUNC(NSRECTSET) {
  NSRect *rect = (NSRect *)hb_parnll(1);

  if (rect) {
    if (!HB_ISNIL(3))
      rect->origin.x = hb_parnl(3);
    if (!HB_ISNIL(2))
      rect->origin.y = hb_parnl(2);
    if (!HB_ISNIL(4))
      rect->size.width = hb_parnl(4);
    if (!HB_ISNIL(5))
      rect->size.height = hb_parnl(5);
  }
}

HB_FUNC(NSRECTSETX) {
  NSRect *rect = (NSRect *)hb_parnll(1);
  if (rect)
    rect->origin.x = hb_parnl(2);
}

HB_FUNC(NSRECTSETY) {
  NSRect *rect = (NSRect *)hb_parnll(1);
  if (rect)
    rect->origin.y = hb_parnl(2);
}

HB_FUNC(NSRECTSETWIDTH) {
  NSRect *rect = (NSRect *)hb_parnll(1);
  if (rect)
    rect->size.width = hb_parnl(2);
}

HB_FUNC(NSRECTSETHEIGHT) {
  NSRect *rect = (NSRect *)hb_parnll(1);
  if (rect)
    rect->size.height = hb_parnl(2);
}

HB_FUNC(NSRECTGETX) {
  NSRect *rect = (NSRect *)hb_parnll(1);
  hb_retnl(rect ? rect->origin.x : 0);
}

HB_FUNC(NSRECTGETY) {
  NSRect *rect = (NSRect *)hb_parnll(1);
  hb_retnl(rect ? rect->origin.y : 0);
}

HB_FUNC(NSRECTGETWIDTH) {
  NSRect *rect = (NSRect *)hb_parnll(1);
  hb_retnl(rect ? rect->size.width : 0);
}

HB_FUNC(NSRECTGETHEIGHT) {
  NSRect *rect = (NSRect *)hb_parnll(1);
  hb_retnl(rect ? rect->size.height : 0);
}
