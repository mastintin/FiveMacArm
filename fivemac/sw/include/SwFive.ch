// swfive.ch - Modern SwiftFive Commands Header (Stable & Clean)
// (c) 2026 Modernizing FiveMac

#ifndef _SWFIVE_CH
#define _SWFIVE_CH

#include "hbclass.ch"

#ifndef DEFAULT
#xcommand DEFAULT <uVar1> := <uVal1> [, <uVarN> := <uValN> ] => ;
   <uVar1> := hb_defaultValue( <uVar1>, <uVal1> ) [; <uVarN> := hb_defaultValue( <uVarN>, <uValN> ) ]
#endif

#define SD    SWProxy("a")
#define SDS   SWProxy("s")
#define SDQ   SWProxy("q")
#define CRLF hb_OsNewLine()

#define SW_TYPE_APPMENU 110
#define SW_TYPE_QUICKLOOK 28

//----------------------------------------------------------------------------//
// COLORS.CH
//----------------------------------------------------------------------------//
#define CLR_BLACK             0
#define CLR_BLUE        8388608
#define CLR_GREEN         32768
#define CLR_CYAN        8421376
#define CLR_RED             128
#define CLR_MAGENTA     8388736
#define CLR_BROWN         32896
#define CLR_HGRAY      12632256
#define CLR_LIGHTGRAY  CLR_HGRAY
#define CLR_GRAY        8421504
#define CLR_HBLUE      16711680
#define CLR_HGREEN        65280
#define CLR_HCYAN      16776960
#define CLR_HRED            255
#define CLR_HMAGENTA   16711935
#define CLR_YELLOW        65535
#define CLR_WHITE      16777215

//----------------------------------------------------------------------------//
// ANCLAS.CH
//----------------------------------------------------------------------------//
#define NoMovil          0
#define AnclaRight       1
#define AnchoMovil       2
#define AnclaLeft        4
#define AnclaTop         8
#define AltoMovil       16
#define AnclaBottom     32
#define SW_RESIZE_WIDTH  AnchoMovil
#define SW_RESIZE_HEIGHT AltoMovil
 
//----------------------------------------------------------------------------//
// BUTTON ROLES
//----------------------------------------------------------------------------//
#define SW_ROLE_NORMAL        0
#define SW_ROLE_DESTRUCTIVE   1
#define SW_ROLE_CANCEL        2
 
//----------------------------------------------------------------------------//
// TOGGLE STYLES
//----------------------------------------------------------------------------//
#define SW_TOGGLE_CHECKBOX    0
#define SW_TOGGLE_SWITCH      1
#define SW_TOGGLE_BUTTON      2

//----------------------------------------------------------------------------//
// GAUGE STYLES
//----------------------------------------------------------------------------//
#define SW_GAUGE_CIRCULAR       0
#define SW_GAUGE_LINEAR         1
#define SW_GAUGE_CAPACITY       2

//----------------------------------------------------------------------------//
// CARD ACCENT SIDES
//----------------------------------------------------------------------------//
#define SW_ACCENT_NONE        0
#define SW_ACCENT_TOP         1
#define SW_ACCENT_BOTTOM      2
#define SW_ACCENT_LEFT        3
#define SW_ACCENT_RIGHT       4
#define SW_ACCENT_ALL         5

//----------------------------------------------------------------------------//
// BASIC COMMANDS
//----------------------------------------------------------------------------//

#xcommand DEFINE WINDOW <oWnd> ;
   [ TITLE <cTitle> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <of: OF, WINDOW, DIALOG> <oParent> ] ;
   => ;
   <oWnd> := TSwWindow():New( [<cTitle>], [<nWidth>], [<nHeight>], , [<oParent>] )

#xcommand DEFINE NAVWINDOW <oWnd> ;
   [ TITLE <cTitle> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <of: OF, WINDOW, DIALOG> <oParent> ] ;
   => ;
   <oWnd> := TSwNavWindow():New( [<cTitle>], [<nWidth>], [<nHeight>], , [<oParent>] )

#xcommand ACTIVATE WINDOW <oWnd> ;
   [ <center: CENTER, CENTERED> ] ;
   [ <modal: MODAL> ] ;
   => ;
   <oWnd>:Activate( <.modal.> )

#xcommand @ <nRow>, <nCol> SAY [ <oSay> PROMPT ] <cText> ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   => ;
   [ <oSay> := ] TSwLabel():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <cText>, <oWnd> )

#xcommand @ <nRow>, <nCol> PANEL [ <oPanel> ] ;
   [ TITLE <cTitle> ] ;
   [ SYMBOL <cSymbol> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHORS> <nRes> ] ;
   => ;
   [ <oPanel> := ] TSwPanel():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, , [<nRes>], [<cTitle>], [<cSymbol>] )

#xcommand @ <nRow>, <nCol> SIDEBAR [ <oSidebar> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHORS> <nRes> ] ;
   => ;
   [ <oSidebar> := ] TSwSidebar():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, , [<nRes>] )

#xcommand @ <nRow>, <nCol> SIDEBAR ITEM [ <oItem> ] ;
   [ PROMPT <cPrompt> ] ;
   [ SYMBOL <cSymbol> ] ;
   [ <of: OF, SIDEBAR> <oSidebar> ] ;
   [ ACTION <uAction> ] ;
   [ ID <cId> ] ;
   => ;
   [ <oItem> := ] TSwSidebarItem():New( <nRow>, <nCol>, <oSidebar>, <cPrompt>, <cSymbol>, [<cId>], [<{uAction}>] )

// --- Modern Block Syntax for Sidebars ---

#xcommand DEFINE SIDEBAR <oSbr> [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   => ;
   <oSbr> := TSwSidebar():New( 0, 0, 200, 500, <oWnd> )

#xcommand NAVSECTION <cTitle> [ <of: OF, SIDEBAR> <oSbr> ] ;
   => ;
   <oSbr>:AddSection( <cTitle> )

#xcommand NAVITEM <cPrompt> [ ICON <cIcon> ] [ ID <cId> ] [ <of: OF, SIDEBAR> <oSbr> ] ;
   [ ACTION <uAction> ] ;
   => ;
   <oSbr>:AddItem( <cPrompt>, [<cIcon>], [<cId>], [<{uAction}>] )

#xcommand END SECTION =>
#xcommand END SIDEBAR =>

#xcommand @ <nRow>, <nCol> VSTACK [ <oStack> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHORS> <nRes> ] ;
   => ;
   [ <oStack> := ] TSwVStack():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, , [<nRes>] )

#xcommand @ <nRow>, <nCol> HSTACK [ <oStack> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHORS> <nRes> ] ;
   => ;
   [ <oStack> := ] TSwHStack():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, , [<nRes>] )

#xcommand @ <nRow>, <nCol> ZSTACK [ <oStack> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHORS> <nRes> ] ;
   => ;
   [ <oStack> := ] TSwZStack():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, , [<nRes>] )

#xcommand @ <nRow>, <nCol> SPACER [ <oSpacer> ] ;
   [ <of: OF, WINDOW, DIALOG, VSTACK, HSTACK, CARD> <oParent> ] ;
   => ;
   [ <oSpacer> := ] TSwSpacer():New( [<oParent>] )



#xcommand @ <nRow>, <nCol> IMAGE [ <oImg> ] ;
   [ <p: PROMPT, SYMBOL> <cSymbol> ] ;
   [ FILE <cFile> ] ;
   [ URL <cUrl> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHORS> <nRes> ] ;
   => ;
   [ <oImg> := ] TSwImage():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], [<cSymbol>], <oWnd>, [<cFile>], [<cUrl>], , [<nRes>] )

#xcommand @ <nRow>, <nCol> BUTTON [ <oBtn> PROMPT ] <cPrompt> ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ACTION <uAction> ] ;
   [ <res: AUTORESIZE, ANCHORS> <nRes> ] ;
   => ;
   [ <oBtn> := ] TSwButton():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <cPrompt>, <oWnd>, [<{uAction}>], [<nRes>] )

#xcommand @ <nRow>, <nCol> SLIDER [ <oSld> ] [ <v: VAR, VALUE> <nValue> ] [ RANGE <nMin>, <nMax> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] [ SIZE <nWidth>, <nHeight> ] ;
   [ PROMPT <cPrompt> ] [ ICONMIN <cIconMin> ] [ ICONMAX <cIconMax> ] ;
   [ COLOR <cColor> ] [ STEP <nStep> ] [ <disabled: DISABLED> ] ;
   [ <show: SHOWVALUE> <lShowValue> ] ;
   [ ACTION <uAction> ] ;
   => ;
   [ <oSld> := ] TSwSlider():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], [<nValue>], [<nMin>], [<nMax>], <oWnd>, , [<{uAction}>], ;
                                  [<cPrompt>], [<cIconMin>], [<cIconMax>], [<cColor>], [<nStep>], <.disabled.>, , [<.lShowValue.>] )

#xcommand @ <nRow>, <nCol> TOGGLE [ <oTgl> ] ;
   [ <v: VAR, VALUE> <lValue> ] ;
   [ PROMPT <cPrompt> ] ;
   [ SUBTITLE <cSubtitle> ] ;
   [ ICON <cIcon> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ STYLE <nStyle> ] ;
   [ ACTION <uAction> ] ;
   => ;
   [ <oTgl> := ] TSwToggle():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], [<lValue>], [<cPrompt>], <oWnd>, , [<nStyle>], , [<{uAction}>], [<cSubtitle>], [<cIcon>] )

#xcommand @ <nRow>, <nCol> LIST <oList> ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ STYLE <nStyle> ] ;
   [ <anchor: ANCHOR, ANCHORS> <nAnchor> ] ;
   [ <search: SEARCH> ] ;
   => ;
   <oList> := TSwList():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, , [<nAnchor>], , [<nStyle>], <.search.> )

#xcommand @ <nRow>, <nCol> GRID [ <oGrid> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ COLUMNS <aCols> ] ;
   [ <anchor: ANCHOR, ANCHORS> <nAnchor> ] ;
   => ;
   [ <oGrid> := ] TSwGrid():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, , [<nAnchor>], [<aCols>] )

#xcommand @ <nRow>, <nCol> PICKER [ <oPkr> ] ;
   [ ITEMS <aItems> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ PROMPT <cPrompt> ] ;
   [ STYLE <nStyle> ] ;
   [ ON CHANGE <uChange> ] ;
   [ <anchor: ANCHOR, ANCHORS> <nAnchor> ] ;
   => ;
   [ <oPkr> := ] TSwPicker():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, [<aItems>], [<{uChange}>], , [<nAnchor>], [<cPrompt>], [<nStyle>] )

#xcommand DEFINE ROW <oRow> OF <oList> [ ID <cId> ] ;
   => ;
   <oRow> := <oList>:AddRow( [<cId>] )


//----------------------------------------------------------------------------//
// Modern SwGet (SwiftUI)
//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> GET [ <oGet> VAR ] <uVar> ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ PROMPT <cPrompt> ] ;
   [ PICTURE <cPicture> ] ;
   [ <password: PASSWORD> ] ;
   [ PLACEHOLDER <cPlaceholder> ] ;
   [ VALID <uValid> ] ;
   [ ACTION <uAction> ] ;
   => ;
   [ <oGet> := ] SwGet():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>],;
   <uVar>, <oWnd>, [\{|v| <uAction> \}], [<cPicture>], [<uValid>], <.password.>, [<cPlaceholder>], [<cPrompt>] )

//----------------------------------------------------------------------------//
// PROGRESS STYLES
//----------------------------------------------------------------------------//
#define SW_PROGRESS_LINEAR    0
#define SW_PROGRESS_CIRCULAR  1

#xcommand @ <nRow>, <nCol> PROGRESS [ <oProg> ] ;
   [ <v: VAR, VALUE> <nValue> ] [ RANGE <nMin>, <nMax> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ PROMPT <cPrompt> ] [ SUBTITLE <cSubtitle> ] ;
   [ ICON <cIcon> ] [ COLOR <cColor> ] ;
   [ <indet: INDETERMINATE> ] [ STYLE <nStyle> ] ;
   [ <showval: SHOWVALUE> ] ;
   => ;
   [ <oProg> := ] SwProgress():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, [<nValue>], [<nMin>], [<nMax>], ;
   [<cPrompt>], [<cSubtitle>], [<cIcon>], [<cColor>], <.indet.>, [<nStyle>], <.showval.> )

#xcommand @ <nRow>, <nCol> TABVIEW [ <oTabs> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ STYLE <nStyle> ] ;
   [ <res: AUTORESIZE, ANCHORS> <nRes> ] ;
   => ;
   [ <oTabs> := ] TSwTabView():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, , [<nRes>], [<nStyle>] )

#xcommand @ <nRow>, <nCol> WEBVIEW [ <oWv> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ URL <cUrl> ] ;
   [ <res: AUTORESIZE, ANCHORS> <nRes> ] ;
   => ;
   [ <oWv> := ] TSwWebView():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], [<cUrl>], <oWnd>, , [<nRes>] )

#xcommand @ <nRow>, <nCol> CONTROL MENU [ <oMenu> ] ;
   [ PROMPT <cPrompt> ] ;
   [ ICON <cIcon> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHORS> <nRes> ] ;
   => ;
   [ <oMenu> := ] TSwMenu():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], [<cPrompt>], <oWnd>, [<nRes>] )

#xcommand CONTROL MENUITEM [ <oItem> ] ;
   [ PROMPT <cPrompt> ] ;
   [ ICON <cIcon> ] ;
   [ <of: OF, MENU> <oMenu> ] ;
   [ ACTION <uAction> ] ;
   => ;
   [ <oItem> := ] TSwMenuItem():New( 0, 0, <oMenu>, [<cPrompt>], [<{uAction}>] )

// --- App Menu Commands ---

#xcommand MENU [ <oMenu> ] ;
   => ;
   [ <oMenu> := ] sw_MenuStart()

#xcommand ENDMENU ;
   => ;
   sw_MenuEnd()

#xcommand MENUITEM <cPrompt> ;
   [ ACTION <uAction> ] ;
   [ SHORTCUT <cShortcut> ] ;
   => ;
   sw_MenuItemStackFix( <cPrompt>, [<{uAction}>], [<cShortcut>] )

#xcommand MENUITEM [ <oItem> ] PROMPT <cPrompt> ;
   [ ACTION <uAction> ] ;
   [ SHORTCUT <cShortcut> ] ;
   => ;
   [ <oItem> := ] sw_MenuItemStackFix( <cPrompt>, [<{uAction}>], [<cShortcut>] )

#xcommand SEPARATOR ;
   => ;
   sw_MenuItemStackFix( "-" )

#xcommand SET MENU [ TO ] <oMenu> ;
   => ;
   <oMenu>:Activate()

#endif
 
#ifndef TSQLite
#define TSQLite TSwSqlite
#endif
 
#xcommand SQLITE CONNECT <cDb> [ <lCreate: CREATE> ] [ INTO <oDb> ] => ;
   [ <oDb> := ] If( <.lCreate.>, TSwSqlite():SqliteCreateDb( <cDb> ), TSwSqlite():SqliteUse( <cDb> ) )
 
#xcommand SQLITE USE <cTable> [ IN <oDb> ] [ ORDER <cOrder> ] => ;
   <oDb>:TableUse( <cTable> ) [; <oDb>:OrdSetFocus( <cOrder> ) ]
 
#xcommand SQLITE APPEND [ IN <oDb> ] => <oDb>:DbAppend()
 
#xcommand SQLITE REPLACE <cField> WITH <uVal> [ IN <oDb> ] => <oDb>:FieldPutName( <cField>, <uVal> )
 
#xcommand SQLITE DELETE [ IN <oDb> ] => <oDb>:DelRecord()
 
#xcommand SQLITE INSERT INTO <cTable> HASH <hData> [ IN <oDb> ] => <oDb>:Insert( <cTable>, <hData> )
 
#xcommand SQLITE CREATE TABLE <cTable> FROM <aStruct> [ IN <oDb> ] => <oDb>:CreateTable( <(cTable)>, <aStruct> )
 
#xcommand SQLITE DROP TABLE <cTable> [ IN <oDb> ] => <oDb>:DelTable( <(cTable)> )
 
#xcommand SQLITE CLOSE [ <oDb> ] => <oDb>:End()


#xcommand @ <nTop>, <nLeft> DATEPICKER <oDate> ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ OF <oWnd> ] ;
   [ DATE <dDate> ] ;
   [ STYLE <nStyle> ] ;
   => ;
   <oDate> := TSwDatePicker():New( <nTop>, <nLeft>, <nWidth>, <nHeight>, <oWnd>, <dDate>, <nStyle> )

#xcommand @ <nRow>, <nCol> SWBROWSE [ <oBrw> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   => ;
   [ <oBrw> := ] TSwBrowse():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd> )

#xcommand @ <nRow>, <nCol> CARD [ <oCard> ] ;
   [ TITLE <cTitle> ] ;
   [ SYMBOL <cSymbol> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHORS> <nRes> ] ;
   [ COLOR <cColor> ] ;
   => ;
   [ <oCard> := ] TSwCard():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, , [<nRes>], [<cTitle>], [<cSymbol>], [<cColor>] )

#xcommand @ <nRow>, <nCol> MAP [ <oMap> ] ;
   [ LAT <nLat> ] ;
   [ LON <nLon> ] ;
   [ ZOOM <nZoom> ] ;
   [ STYLE <nStyle> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   => ;
   [ <oMap> := ] TSwMap():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, [<nLat>], [<nLon>], [<nZoom>], [<nStyle>] )

#xcommand @ <nRow>, <nCol> QUICKLOOK [ <oQl> ] ;
   [ FILE <cFile> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <res: AUTORESIZE, ANCHORS> <nRes> ] ;
   => ;
   [ <oQl> := ] TSwQuickLook():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, [<cFile>], [<nRes>] )


#xcommand @ <nRow>, <nCol> STEPPER [ <oStp> ] ;
   [ <v: VAR, VALUE> <nValue> ] ;
   [ RANGE <nMin>, <nMax> ] ;
   [ STEP <nStep> ] ;
   [ PROMPT <cPrompt> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ACTION <uAction> ] ;
   => ;
   [ <oStp> := ] TSwStepper():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], [<nValue>], [<nMin>], [<nMax>], [<nStep>], [<cPrompt>], <oWnd>, [<{uAction}>] )

#xcommand @ <nRow>, <nCol> COLORPICKER [ <oCp> ] ;
   [ <v: VAR, VALUE> <cValue> ] ;
   [ PROMPT <cPrompt> ] ;
    [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ ACTION <uAction> ] ;
    => ;
    [ <oCp> := ] TSwColorPicker():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], [<cValue>], [<cPrompt>], <oWnd>, [<{uAction}>] )

//----------------------------------------------------------------------------//
// GAUGE
//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> GAUGE [ <oGauge> ] ;
    [ <v: VAR, VALUE> <nValue> ] [ RANGE <nMin>, <nMax> ] ;
    [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    [ PROMPT <cPrompt> ] [ SUBTITLE <cSubtitle> ] ;
    [ ICON <cIcon> ] [ COLOR <cColor> ] ;
    [ STYLE <nStyle> ] [ UNIT <cUnit> ] ;
    [ <disabled: DISABLED> ] ;
    [ <showval: SHOWVALUE> ] ;
    => ;
    [ <oGauge> := ] TSwGauge():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], [<nValue>], [<nMin>], [<nMax>], <oWnd>, , ;
                                    [<cPrompt>], [<cSubtitle>], [<cIcon>], [<cColor>], [<nStyle>], <.disabled.>, , [<.showval.>], [<cUnit>] )
