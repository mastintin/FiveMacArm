#include <fivemac.h>

@interface FiveBox : NSBox {
@public
  BOOL bVibrancy;
}
- (BOOL)allowsVibrancy;
@end

@implementation FiveBox
- (BOOL)allowsVibrancy {
  return bVibrancy;
}
@end

HB_FUNC(BOXCREATE) {
  // Añadimos autorelease al final del alloc/init
  FiveBox *box = [[[FiveBox alloc]
      initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3),
                               hb_parnl(4))] autorelease];

  NSWindow *window = (NSWindow *)hb_parnll(5);
  NSString *string = hb_NSSTRING_par(6);

  [GetView(window) addSubview:box];
  [box setTitle:string];
  [box setBoxType:hb_parnl(7)];

  hb_retnll((HB_LONGLONG)box);
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXRELEASE) {
  NSBox *box = (NSBox *)hb_parnll(1);

  if (box) {
    [box removeFromSuperview];
    // En No-ARC, removeFromSuperview envía un 'release' interno al objeto.
    // Si usaste 'autorelease' al crearlo, esto suele ser suficiente para que se
    // destruya.
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXTITLE) {
  NSBox *box = (NSBox *)hb_parnll(1);
  NSString *title = [box title];

  if (title) {
    hb_retc([title UTF8String]); // UTF8String es más directo
  } else {
    hb_retc("");
  }
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXSETTITLE) {
  NSBox *box = (NSBox *)hb_parnll(1);
  [box setTitle:hb_NSSTRING_par(2)];
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXSETSTYLE) {
  NSBox *box = (NSBox *)hb_parnll(1);

  [box setBoxType:hb_parnl(2)];
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXGETSTYLE) {
  NSBox *box = (NSBox *)hb_parnll(1);

  hb_retnl([box boxType]);
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXSETBORDERWIDTH) {
  NSBox *box = (NSBox *)hb_parnll(1);

  [box setBorderWidth:hb_parnd(2)];
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXSETTITLEPOS) {
  NSBox *box = (NSBox *)hb_parnll(1);

  [box setTitlePosition:hb_parnl(2)];
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXSETBORDERTYPE) {
  /*.   -deprecated-
  NSBox * box = ( NSBox * ) hb_parnl( 1 );
  [ box setBorderType: hb_parnl( 2 ) ];
  */
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXISLINEBORDER) {
  /*.  -------deprecated-------
   NSBox * box = ( NSBox * ) hb_parnl( 1 );
   hb_retl( ( [box borderType]  == NSLineBorder ) );
*/
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXSETFILLCOLOR) {
  NSBox *box = (NSBox *)hb_parnll(1);
  NSColor *color = [NSColor colorWithSRGBRed:(hb_parnl(2) / 255.0)
                                             green:(hb_parnl(3) / 255.0)
                                              blue:(hb_parnl(4) / 255.0)
                                             alpha:(hb_parnl(5) / 100.0)];
  [box setFillColor:color];
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXSETBORDERCOLOR) {
  NSBox *box = (NSBox *)hb_parnll(1);
  NSColor *color = [NSColor colorWithSRGBRed:(hb_parnl(2) / 255.0)
                                             green:(hb_parnl(3) / 255.0)
                                              blue:(hb_parnl(4) / 255.0)
                                             alpha:(hb_parnl(5) / 100.0)];
  [box setBorderColor:color];
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXSETTRASPARENT) {
  NSBox *box = (NSBox *)hb_parnll(1);
  [box setTransparent:hb_parl(2)];
}

HB_FUNC(BOXISTRASPARENT) {
  NSBox *box = (NSBox *)hb_parnll(1);
  hb_retl((BOOL)[box isTransparent]);
}
HB_FUNC(BOXHIDE) {
  NSBox *box = (NSBox *)hb_parnll(1);

  [box setHidden:YES];
}

HB_FUNC(BOXSHOW) {
  NSBox *box = (NSBox *)hb_parnll(1);

  [box setHidden:NO];
}

HB_FUNC(BOXAUTOAJUST) {
  NSBox *box = (NSBox *)hb_parnll(1);

  [box setAutoresizingMask:hb_parnl(2)];
}

HB_FUNC(BOXSETCUSTOM) {
  NSBox *box = (NSBox *)hb_parnll(1);
  [box setBoxType:NSBoxCustom];
}

HB_FUNC(BOXISCUSTOM) {
  NSBox *box = (NSBox *)hb_parnll(1);
  hb_retl(([box boxType] == NSBoxCustom));
}

//--------------------------------------------------------------------------------//

HB_FUNC(SEPARATORH) {
  NSBox *box = [[[NSBox alloc]
      initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1), hb_parnl(3), 1.0)]
      autorelease];
  NSWindow *window = (NSWindow *)hb_parnll(4);
  [GetView(window) addSubview:box];
  [box setBoxType:NSBoxSeparator];

  hb_retnll((HB_LONGLONG)box);
}

//--------------------------------------------------------------------------------//

HB_FUNC(SEPARATORV) {
  NSBox *box = [[[NSBox alloc]
      initWithFrame:NSMakeRect(hb_parnl(2), hb_parnl(1), 1.0, hb_parnl(3))]
      autorelease];
  NSWindow *window = (NSWindow *)hb_parnll(4);

  [GetView(window) addSubview:box];
  [box setBoxType:NSBoxSeparator];

  hb_retnll((HB_LONGLONG)box);
}

//--------------------------------------------------------------------------------//

HB_FUNC(BOXALLOWVIBRANCY) {
  NSBox *box = (NSBox *)hb_parnll(1);
  if ([box isKindOfClass:[FiveBox class]]) {
    ((FiveBox *)box)->bVibrancy = hb_parl(2);
    [box setNeedsDisplay:YES];
  }
}
