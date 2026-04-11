import sys

with open("source/winapi/scintillas.m", "r") as f:
    lines = f.readlines()

new_lines = []
skip = False
for line in lines:
    # 1. Add headers
    if line.startswith("#include <fivemac.h>"):
        new_lines.append("#import <Foundation/Foundation.h>\n")
        new_lines.append("#import <AppKit/AppKit.h>\n")
        new_lines.append('#include "fivemac.h"\n')
        new_lines.append('#include "fmsgs.h"\n')
        continue
    if line.startswith("#include <scintilla.h>"):
        new_lines.append('#include "scintilla_headers/scintilla.h"\n')
        continue
        
    # 2. Skip structs we replaced
    if "struct Sci_CharacterRange {" in line:
        skip = True
    if skip and "TEXTTOFIND;" in line:
        new_lines.append("typedef struct {\n  struct Sci_CharacterRange chrg;\n  char *lpstrText;\n  struct Sci_CharacterRange chrgText;\n} TEXTTOFIND;\n")
        skip = False
        continue
    if skip:
        continue
        
    if "struct NotifyHeader // This matches" in line:
        skip = True
    if skip and "} SCNotification;" in line:
        new_lines.append("// SCNotification is already defined by modern scintilla.h\n")
        skip = False
        continue
    if skip:
        continue

    new_lines.append(line)

# Add the dialog code at the end
dialog = """
// -----------------------------------------------------------------------
// Editor Colors Dialog 
// -----------------------------------------------------------------------
#define SCIRGB(r,g,b) (((b) << 16) | ((g) << 8) | (r))
#define SCSTYLE_DEFAULT 32
#define SCSTYLE_LINENUMBER 33
#define SSCE_C_WORD 5
#define SSCE_C_WORD2 16
#define SSCE_C_COMMENT 1
#define SSCE_C_COMMENTLINE 2
#define SSCE_C_COMMENTDOC 3
#define SSCE_C_STRING 6
#define SSCE_C_CHARACTER 7
#define SSCE_C_NUMBER 4
#define SSCE_C_PREPROCESSOR 9
#define SSCE_C_OPERATOR 10
#define SSCE_C_IDENTIFIER 11

HB_FUNC( MAC_EDITORCOLORSDIALOG )
{
   ScintillaView * sv = (ScintillaView *)hb_parnll(1);
   if( !sv ) return;

   struct { const char * name; long bg, text, kw, cmd, comment, str, preproc, num, sel; } presets[] = {
      { "Dark",     SCIRGB(30,30,30),    SCIRGB(212,212,212), SCIRGB(86,156,214), SCIRGB(78,201,176),  SCIRGB(106,153,85),  SCIRGB(206,145,120), SCIRGB(197,134,192), SCIRGB(181,206,168), SCIRGB(38,79,120) },
      { "Light",    SCIRGB(255,255,255), SCIRGB(0,0,0),       SCIRGB(0,0,255),    SCIRGB(0,128,128),   SCIRGB(0,128,0),     SCIRGB(163,21,21),   SCIRGB(128,0,128),   SCIRGB(128,64,0),    SCIRGB(173,214,255) },
      { "Monokai",  SCIRGB(39,40,34),    SCIRGB(248,248,242), SCIRGB(249,38,114), SCIRGB(102,217,239), SCIRGB(117,113,94),  SCIRGB(230,219,116), SCIRGB(166,226,46),  SCIRGB(174,129,255), SCIRGB(73,72,62) },
      { "Solarized",SCIRGB(0,43,54),     SCIRGB(131,148,150), SCIRGB(181,137,0),  SCIRGB(42,161,152),  SCIRGB(88,110,117),  SCIRGB(42,161,152),  SCIRGB(203,75,22),   SCIRGB(211,54,130),  SCIRGB(7,54,66) }
   };

   NSAlert * alert = [[NSAlert alloc] init];
   [alert setMessageText:@"Editor Colors"];
   [alert setInformativeText:@"Choose a color theme for the code editor:"];
   for( int i = 0; i < 4; i++ )
      [alert addButtonWithTitle:[NSString stringWithUTF8String:presets[i].name]];
   [alert addButtonWithTitle:@"Cancel"];

   NSModalResponse resp = [alert runModal];
   int idx = (int)(resp - NSAlertFirstButtonReturn);
   if( idx < 0 || idx >= 4 ) return;

   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SCSTYLE_DEFAULT extra:presets[idx].text];
   [sv getGeneralProperty:SCI_STYLESETBACK parameter:SCSTYLE_DEFAULT extra:presets[idx].bg];
   [sv getGeneralProperty:SCI_STYLECLEARALL parameter:0 extra:0];

   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SCSTYLE_LINENUMBER extra:SCIRGB(133,133,133)];
   long gutterBg = (idx == 1) ? SCIRGB(240,240,240) : SCIRGB(37,37,38);
   [sv getGeneralProperty:SCI_STYLESETBACK parameter:SCSTYLE_LINENUMBER extra:gutterBg];

   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SSCE_C_WORD extra:presets[idx].kw];
   [sv getGeneralProperty:SCI_STYLESETBOLD parameter:SSCE_C_WORD extra:1];
   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SSCE_C_WORD2 extra:presets[idx].cmd];
   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SSCE_C_COMMENT extra:presets[idx].comment];
   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SSCE_C_COMMENTLINE extra:presets[idx].comment];
   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SSCE_C_COMMENTDOC extra:presets[idx].comment];
   [sv getGeneralProperty:SCI_STYLESETITALIC parameter:SSCE_C_COMMENT extra:1];
   [sv getGeneralProperty:SCI_STYLESETITALIC parameter:SSCE_C_COMMENTLINE extra:1];
   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SSCE_C_STRING extra:presets[idx].str];
   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SSCE_C_CHARACTER extra:presets[idx].str];
   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SSCE_C_NUMBER extra:presets[idx].num];
   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SSCE_C_PREPROCESSOR extra:presets[idx].preproc];
   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SSCE_C_OPERATOR extra:presets[idx].text];
   [sv getGeneralProperty:SCI_STYLESETFORE parameter:SSCE_C_IDENTIFIER extra:presets[idx].text];

   long caretClr = (idx == 1) ? SCIRGB(0,0,0) : SCIRGB(255,255,255);
   [sv getGeneralProperty:SCI_SETCARETFORE parameter:caretClr extra:0];
   [sv getGeneralProperty:SCI_SETSELBACK parameter:1 extra:presets[idx].sel];

   long foldFore = (idx == 1) ? SCIRGB(80,80,80) : SCIRGB(160,160,160);
   for( int m = 25; m <= 31; m++ ) {
      [sv getGeneralProperty:2041 parameter:m extra:foldFore];
      [sv getGeneralProperty:2042 parameter:m extra:gutterBg];
   }

   [sv setNeedsDisplay:YES];
}
"""
new_lines.append(dialog)

with open("source/winapi/scintillas.m", "w") as f:
    f.writelines(new_lines)
