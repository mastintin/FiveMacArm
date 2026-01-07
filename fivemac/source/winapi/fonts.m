#include <fivemac.h>

HB_FUNC(CREATEFONT) {
  NSString *name = hb_NSSTRING_par(1);
  NSFont *font = [NSFont fontWithName:name size:hb_parnll(2)];

  hb_retnll((HB_LONGLONG)font);
}

HB_FUNC(FONTGETSYSTEM) {
  NSFont *font = [NSFont systemFontOfSize:hb_parnll(1)];

  hb_retnll((HB_LONGLONG)font);
}

HB_FUNC(FONTGETNAME) {
  NSFont *font = [NSFont systemFontOfSize:hb_parnll(1)];

  hb_retc([[font displayName] cStringUsingEncoding:NSUTF8StringEncoding]);
}

HB_FUNC(FONTISVERTICAL) {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
  NSFont *font = [NSFont systemFontOfSize:hb_parnll(1)];

  hb_retl([font isVertical]);
#else
  hb_retl(0);
#endif
}

HB_FUNC(FONTSETVERTICAL) {
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
  NSFont *font = [NSFont systemFontOfSize:hb_parnll(1)];
  NSFont *fontVertical = [font verticalFont];
  hb_retnll((HB_LONGLONG)fontVertical);
#endif
}

HB_FUNC(DRAWTEXT) // nRow, nCol, cText, hFont
{

  NSString *text = hb_NSSTRING_par(3);
  NSMutableDictionary *attr =
      [NSMutableDictionary dictionaryWithObject:(NSFont *)hb_parnll(4)
                                         forKey:NSFontAttributeName];

  if (hb_pcount() > 4)
    [attr setObject:(NSColor *)hb_parnll(5)
             forKey:NSForegroundColorAttributeName];

  [text drawAtPoint:NSMakePoint(hb_parnll(1), hb_parnll(2))
      withAttributes:attr];
}

HB_FUNC(FM_AVAILABLEFONTS) {
  NSArray *aFonts = [[NSFontManager sharedFontManager] availableFonts];
  int i;

  hb_reta([aFonts count]);

  for (i = 0; i < [aFonts count]; i++)
    hb_storvc([(NSString *)[aFonts objectAtIndex:i]
                  cStringUsingEncoding:NSUTF8StringEncoding],
              -1, i + 1);
}
