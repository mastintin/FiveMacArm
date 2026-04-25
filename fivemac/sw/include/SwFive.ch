// swfive.ch - Modern SwiftFive Commands Header (Stable & Clean)
// (c) 2026 Modernizing FiveMac

#ifndef _SWFIVE_CH
#define _SWFIVE_CH

#include "hbclass.ch"

#ifndef DEFAULT
#xcommand DEFAULT <uVar1> := <uVal1> [, <uVarN> := <uValN> ] => ;
   <uVar1> := hb_defaultValue( <uVar1>, <uVal1> ) [; <uVarN> := hb_defaultValue( <uVarN>, <uValN> ) ]
#endif

#define SD    Sw_GetProxy()
#define SDS   Sw_GetProxy():Sync()
#define SDQ   Sw_GetQueryProxy()
#define CRLF hb_OsNewLine()

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
// BASIC COMMANDS
//----------------------------------------------------------------------------//

#xcommand DEFINE WINDOW <oWnd> ;
   [ TITLE <cTitle> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <of: OF, WINDOW, DIALOG> <oParent> ] ;
   => ;
   <oWnd> := TSwWindow():New( [<cTitle>], [<nWidth>], [<nHeight>], , [<oParent>] )

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


#xcommand @ <nRow>, <nCol> IMAGE [ <oImg> <p: PROMPT, SYMBOL> ] <cSymbol> ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   => ;
   [ <oImg> := ] TSwImage():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <cSymbol>, <oWnd> )

#xcommand @ <nRow>, <nCol> BUTTON [ <oBtn> PROMPT ] <cPrompt> ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ACTION <uAction> ] ;
   => ;
   [ <oBtn> := ] TSwButton():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <cPrompt>, <oWnd>, [<{uAction}>] )

#xcommand @ <nRow>, <nCol> SLIDER [ <oSld> ] ;
   [ <v: VAR, VALUE> <nValue> ] ;
   [ RANGE <nMin>, <nMax> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ACTION <uAction> ] ;
   => ;
   [ <oSld> := ] TSwSlider():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], [<nValue>], [<nMin>], [<nMax>], <oWnd>, , [<{uAction}>] )

#xcommand @ <nRow>, <nCol> TOGGLE [ <oTgl> ] ;
   [ <v: VAR, VALUE> <lValue> ] ;
   [ PROMPT <cPrompt> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ACTION <uAction> ] ;
   => ;
   [ <oTgl> := ] TSwToggle():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], [<lValue>], [<cPrompt>], <oWnd>, , , , [<{uAction}>] )

#xcommand @ <nRow>, <nCol> LIST <oList> ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <anchor: ANCHOR, ANCHORS> <nAnchor> ] ;
   => ;
   <oList> := TSwList():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, , [<nAnchor>] )

#xcommand DEFINE ROW <oRow> OF <oList> [ ID <cId> ] ;
   => ;
   <oRow> := <oList>:AddRow( [<cId>] )


//----------------------------------------------------------------------------//
// Modern SwGet (SwiftUI)
//----------------------------------------------------------------------------//

#xcommand @ <nRow>, <nCol> GET [ <oGet> VAR ] <uVar> ;
   [ OF <oWnd> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ PICTURE <cPicture> ] ;
   [ <password: PASSWORD> ] ;
   [ ACTION <uAction> ] ;
   => ;
   [ <oGet> := ] SwGet():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>],;
   <uVar>, <oWnd>, [\{|v| <uAction> \}], [<cPicture>], , <.password.> )

#xcommand @ <nRow>, <nCol> PROGRESS [ <oProg> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ <of: OF, WINDOW, DIALOG> <oWnd> ] ;
   [ VALUE <nValue> ] ;
   => ;
   [ <oProg> := ] SwProgress():New( <nRow>, <nCol>, [<nWidth>], [<nHeight>], <oWnd>, [<nValue>] )

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

