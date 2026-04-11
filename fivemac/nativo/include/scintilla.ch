#ifndef _SCINTILLA_CH
#define _SCINTILLA_CH

/* Scintilla Messages */
#define SCI_ADDTEXT                2001
#define SCI_SETTEXT                2181
#define SCI_GETTEXT                2182
#define SCI_GETTEXTLENGTH          2183
#define SCI_GOTOLINE               2024
#define SCI_GOTOPOS                2025
#define SCI_GETCURRENTPOS          2008
#define SCI_CHARADDED              2001

/* Style Constants */
#define STYLE_DEFAULT              32
#define STYLE_LINENUMBER           33
#define STYLE_BRACELIGHT           34
#define STYLE_BRACEBAD             35

/* Lexer Constants */
#define SC_CP_UTF8                 65001

/* Margins */
#define SC_MARGIN_NUMBER           1
#define SC_MARGIN_SYMBOL           0

/* Basic Editing & Navigation */
#define SCI_UNDO                   2176
#define SCI_REDO                   2011
#define SCI_SELECTALL              2013
#define SCI_TAB                    2327
#define SCI_UPPERCASE              2341
#define SCI_LOWERCASE              2340

/* Stuttered Movement */
#define SCI_STUTTEREDPAGEDOWN      2437
#define SCI_STUTTEREDPAGEDOWNEXTEND 2438
#define SCI_STUTTEREDPAGEUP        2435
#define SCI_STUTTEREDPAGEUPEXTEND  2436

/* VC Home Movement */
#define SCI_VCHOME                 2331
#define SCI_VCHOMEEXTEND           2332
#define SCI_VCHOMERECTEXTEND       2431
#define SCI_VCHOMEWRAP             2453
#define SCI_VCHOMEWRAPEXTEND       2454

/* Word Movement */
#define SCI_WORDLEFT               2308
#define SCI_WORDLEFTEXTEND         2309
#define SCI_WORDLEFTEND            2439
#define SCI_WORDLEFTENDEXTEND      2440
#define SCI_WORDRIGHT              2310
#define SCI_WORDRIGHTEXTEND        2311
#define SCI_WORDRIGHTEND           2441
#define SCI_WORDRIGHTENDEXTEND     2442

/* Word Part Movement */
#define SCI_WORDPARTLEFT           2390
#define SCI_WORDPARTLEFTEXTEND     2391
#define SCI_WORDPARTRIGHT          2392
#define SCI_WORDPARTRIGHTEXTEND    2393

/* Auto-completion */
#define SCI_AUTOCSHOW              2100
#define SCI_AUTOCCANCEL            2101
#define SCI_AUTOCACTIVE            2102
#define SCI_AUTOCPOSSTART          2103
#define SCI_AUTOCCOMPLETE          2104
#define SCI_AUTOCSTOPS             2105
#define SCI_AUTOCSETSEPARATOR      2106
#define SCI_AUTOCGETSEPARATOR      2107
#define SCI_AUTOCSELECT            2108
#define SCI_AUTOCSETCANCELATSTART  2110
#define SCI_AUTOCGETCANCELATSTART  2111
#define SCI_AUTOCSETFILLUPS        2112
#define SCI_AUTOCSETCHOOSESINGLE   2113
#define SCI_AUTOCGETCHOOSESINGLE   2114
#define SCI_AUTOCSETIGNORECASE     2115
#define SCI_AUTOCGETIGNORECASE     2116

/* Styles */
#define SCI_STYLERESETDEFAULT      2058
#define SCI_STYLESETFORE           2051
#define SCI_STYLESETBACK           2052
#define SCI_STYLECLEARALL          2050


/* Indicators */
#define INDIC_PLAIN                0
#define INDIC_SQUIGGLE             1
#define INDIC_TT                   2
#define INDIC_DIAGONAL             3
#define INDIC_STRIKE               4
#define INDIC_HIDDEN               5
#define INDIC_BOX                  6
#define INDIC_ROUNDBOX             7
#define INDIC_STRAIGHTBOX          8
#define INDIC_DASH                 9
#define INDIC_DOTS                 10
#define INDIC_SQUIGGLELOW          11
#define INDIC_DOTBOX               12
#define INDIC_SQUIGGLEPIXMAP       13
#define INDIC_COMPOSITIONTHICK     14
#define INDIC_COMPOSITIONTHIN      15
#define INDIC_FULLBOX              16
#define INDIC_TEXTFORE             17
#define INDIC_POINT                18
#define INDIC_POINTCHARACTER       19

/* Indentation Guides */
#define SC_IV_NONE                 0
#define SC_IV_REAL                 1
#define SC_IV_LOOKFORWARD          2
#define SC_IV_LOOKBOTH             3

/* Messages */
#define SCI_INDICSETSTYLE          2080
#define SCI_INDICGETSTYLE          2081
#define SCI_INDICSETFORE           2082
#define SCI_INDICGETFORE           2083
#define SCI_INDICSETUNDER          2510
#define SCI_INDICGETUNDER          2511
#define SCI_SETINDENTATIONGUIDES   2132
#define SCI_GETINDENTATIONGUIDES   2133

#define SCI_MARKERADD              2043
#define SCI_MARKERDELETE           2044
#define SCI_MARKERDELETEALL        2045
#define SCI_MARKERGET              2046
#define SCI_MARKERNEXT             2047
#define SCI_MARKERPREVIOUS         2048
#define SCI_MARKERDEFINE           2040
#define SCI_MARKERSETFORE          2041
#define SCI_MARKERSETBACK          2042
#define SCI_MARKERSETBACKSELECTED  2292
#define SCI_MARKERENABLEFOREBACK   2447
#define SCI_MARKERDELETEHANDLE     2018

#define SCI_SETVIEWEOL             2356
#define SCI_GETVIEWEOL             2355
#define SCI_GETZOOM                2374
#define SCI_SETZOOM                2373
#define SCI_COLOURISE              4003


#define SCI_INSERTTEXT             2003
#define SCI_CLEAR                  2180
#define SCI_SETSEL                 2160
#define SCI_LINEFROMPOSITION       2166
#define SCI_POSITIONFROMLINE       2167
#define SCI_GETLINEINDENTATION     2127
#define SCI_SETLINEINDENTATION     2126
#define SCI_GETINDENT              2123
#define SCI_GETLEXER               4002
#define SCI_GETLINECOUNT           2154
#define SCI_GETLINE                2153

#define SCI_SETMARGINLEFT          2155
#define SCI_GETMARGINLEFT          2156
#define SCI_SETMARGINRIGHT         2157
#define SCI_GETMARGINRIGHT         2158
#define SCI_GETMODIFY              2159
#define SCI_GETREADONLY            2140


#define SCI_GETCHARAT              2007
#define SCI_BRACEHIGHLIGHT         2351
#define SCI_BRACEBADLIGHT          2352
#define SCI_BRACEMATCH             2353

#define SCI_REPLACESEL             2170
#define SCI_STYLEGETFORE           2481
#define SCI_GETVIEWWS              2020
#define SCI_SETVIEWWS              2021
#define SCWS_INVISIBLE             0
#define SCWS_VISIBLEALWAYS         1
#define SCWS_VISIBLEAFTERINDENT    2

#define SCI_SETSAVEPOINT           2014

#define SCI_SETFOCUS               2380
#define SCI_GETFOCUS               2381
#define SCI_SETFIRSTVISIBLELINE     2401
#define SCI_GETFIRSTVISIBLELINE     2402
#define SCI_SETXOFFSET             2403
#define SCI_GETXOFFSET             2404
#define SCI_SETYOFFSET             2405
#define SCI_GETYOFFSET             2406

#endif