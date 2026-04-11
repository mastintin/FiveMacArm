#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#include "fivemac.h"

// Define constants to avoid header issues
#define STYLE_DEFAULT 32
#define STYLE_LINENUMBER 33
#define SCI_STYLESETFORE 3352
#define SCI_STYLESETBACK 3353
#define SCI_STYLECLEARALL 3350
#define SCI_STYLESETBOLD 3355
#define SCI_STYLESETITALIC 3351
#define SCI_SETCARETFORE 2069
#define SCI_SETSELBACK 2068
#define SCI_SETLEXER 2001

#define SCE_C_WORD 5
#define SCE_C_WORD2 16
#define SCE_C_COMMENT 1
#define SCE_C_COMMENTLINE 2
#define SCE_C_COMMENTDOC 3
#define SCE_C_NUMBER 4
#define SCE_C_STRING 6
#define SCE_C_CHARACTER 7
#define SCE_C_PREPROCESSOR 9
#define SCE_C_OPERATOR 10
#define SCI_MARKERSETFORE 2041
#define SCI_MARKERSETBACK 2042

#define SCIRGB(r, g, b) (((unsigned int)(r)) | ((unsigned int)(g) << 8) | ((unsigned int)(b) << 16))

@interface ScintillaView : NSView
- (void)setGeneralProperty:(int)property parameter:(long)parameter value:(long)value;
@end

HB_FUNC( MAC_SETEDITORPRESET )
{
   ScintillaView * sv = (ScintillaView *) hb_parnll( 1 ); 
   int idx = hb_parni( 2 ) - 1; 

   if( !sv || idx < 0 || idx >= 4 ) return;

   struct { unsigned int bg, text, kw, cmd, comment, str, preproc, num, sel; } presets[] = {
      { SCIRGB(30,30,30),    SCIRGB(212,212,212), SCIRGB(86,156,214),
        SCIRGB(78,201,176),  SCIRGB(106,153,85),  SCIRGB(206,145,120),
        SCIRGB(197,134,192), SCIRGB(181,206,168), SCIRGB(38,79,120) },
      { SCIRGB(255,255,255), SCIRGB(0,0,0),       SCIRGB(0,0,255),
        SCIRGB(0,128,128),   SCIRGB(0,128,0),     SCIRGB(163,21,21),
        SCIRGB(128,0,128),   SCIRGB(128,64,0),    SCIRGB(173,214,255) },
      { SCIRGB(39,40,34),    SCIRGB(248,248,242), SCIRGB(249,38,114),
        SCIRGB(102,217,239), SCIRGB(117,113,94),  SCIRGB(230,219,116),
        SCIRGB(166,226,46),  SCIRGB(174,129,255), SCIRGB(73,72,62) },
      { SCIRGB(0,43,54),     SCIRGB(131,148,150), SCIRGB(181,137,0),
        SCIRGB(42,161,152),  SCIRGB(88,110,117),  SCIRGB(42,161,152),
        SCIRGB(203,75,22),   SCIRGB(211,54,130),  SCIRGB(7,54,66) },
   };

   unsigned int bg = presets[idx].bg;
   unsigned int fg = presets[idx].text;
   unsigned int sl = presets[idx].sel;

   [sv setGeneralProperty:SCI_SETLEXER parameter:0 value:0];
   [sv setGeneralProperty:SCI_STYLESETFORE parameter:STYLE_DEFAULT value:fg];
   [sv setGeneralProperty:SCI_STYLESETBACK parameter:STYLE_DEFAULT value:bg];
   [sv setGeneralProperty:SCI_STYLECLEARALL parameter:0 value:0];

   [sv setGeneralProperty:SCI_STYLESETFORE parameter:STYLE_LINENUMBER value:SCIRGB(128,128,128)];
   [sv setGeneralProperty:SCI_STYLESETBACK parameter:STYLE_LINENUMBER value:(idx==1?SCIRGB(240,240,240):SCIRGB(40,40,40))];

   [sv setGeneralProperty:SCI_SETLEXER parameter:3 value:0];

   [sv setGeneralProperty:SCI_STYLESETFORE parameter:SCE_C_WORD value:presets[idx].kw];
   [sv setGeneralProperty:SCI_STYLESETBOLD parameter:SCE_C_WORD value:1];
   [sv setGeneralProperty:SCI_STYLESETFORE parameter:SCE_C_WORD2 value:presets[idx].cmd];
   [sv setGeneralProperty:SCI_STYLESETFORE parameter:SCE_C_COMMENT value:presets[idx].comment];
   [sv setGeneralProperty:SCI_STYLESETFORE parameter:SCE_C_COMMENTLINE value:presets[idx].comment];
   [sv setGeneralProperty:SCI_STYLESETFORE parameter:SCE_C_STRING value:presets[idx].str];
   [sv setGeneralProperty:SCI_STYLESETFORE parameter:SCE_C_PREPROCESSOR value:presets[idx].preproc];

   unsigned int caretClr = (idx == 1) ? SCIRGB(0,0,0) : SCIRGB(255,255,255);
   [sv setGeneralProperty:SCI_SETCARETFORE parameter:caretClr value:0];
   [sv setGeneralProperty:SCI_SETSELBACK parameter:1 value:sl];

   [sv setNeedsDisplay:YES];
}
