#include "FiveMac.ch"
#include "Scintilla.ch"
#include "FiveMac.ch"

static lKeywordsLoaded := .F.
static oHbDocs

EXTERNAL SCISETGLOBALKEYWORDS
EXTERNAL SCISETGLOBALDOCS
EXTERNAL SCISETGLOBALSNIPPETS
#include "fmsgs.h"

//----------------------------------------------------------------------------//

CLASS TScintilla FROM TControl

   DATA hWnd
   DATA oSnippets
   
   DATA cFileName
   DATA cFilePath
   DATA aMarkerHand, aBookMarker
   DATA nManualAnchor
   DATA lLinTabs, lIndicators

   CLASSDATA cLineBuffer

   METHOD New( nTop, nLeft, nBottom, nRight, oWnd )
 
   METHOD AddText( cText )          INLINE ::Send( SCI_ADDTEXT, len( cText ), cText )
  
   METHOD Open( cFileName )

   METHOD Save()
   METHOD SaveAS( cFileName )

   METHOD Send( nMsg, nWParam, nLParam ) INLINE SCISEND( ::hWnd, nMsg, nWParam, nLParam )

   METHOD Stutteredpagedown()                 INLINE ::Send( SCI_STUTTEREDPAGEDOWN )
   METHOD StutteredpagedownextenD()           INLINE ::Send( SCI_STUTTEREDPAGEDOWNEXTEND )
   METHOD Stutteredpageup()                   INLINE ::Send( SCI_STUTTEREDPAGEUP )
   METHOD Stutteredpageupextend ()            INLINE ::Send( SCI_STUTTEREDPAGEUPEXTEND )
    
   METHOD StylereSetDefault()                 INLINE ::Send( SCI_STYLERESETDEFAULT, 0, 0 )

   METHOD Tab()                               INLINE ::Send( SCI_TAB )
   METHOD UnDo()                              INLINE ::Send( SCI_UNDO )
   METHOD Uppercase()                         INLINE ::Send( SCI_UPPERCASE )

   METHOD AutoCShow( nLen, cList )            INLINE ::Send( SCI_AUTOCSHOW, nLen, cList )
   METHOD AutoCShowKeywords()
   METHOD AutoCCancel()                       INLINE ::Send( SCI_AUTOCCANCEL )
   METHOD GetWordLeft()
  
   METHOD AutoCActive()                       INLINE ::Send( SCI_AUTOCACTIVE ) != 0
   METHOD AutoCPosStart()                     INLINE ::Send( SCI_AUTOCPOSSTART )
   METHOD AutoCComplete()                     INLINE ::Send( SCI_AUTOCCOMPLETE )
   METHOD AutoCStops( cChars )                INLINE ::Send( SCI_AUTOCSTOPS, 0, cChars )
   METHOD AutoCSetSeparator( nSep )           INLINE ::Send( SCI_AUTOCSETSEPARATOR, nSep, 0 )
   METHOD AutoCGetSeparator()                 INLINE ::Send( SCI_AUTOCGETSEPARATOR )
   METHOD AutoCSelect( cText )                INLINE ::Send( SCI_AUTOCSELECT, 0, cText )
   METHOD AutoCSetCancelAtStart( l )          INLINE ::Send( SCI_AUTOCSETCANCELATSTART, If( l, 1, 0 ), 0 )
   METHOD AutoCGetCancelAtStart()             INLINE ::Send( SCI_AUTOCGETCANCELATSTART )
   METHOD AutoCSetFillUps( cSet )             INLINE ::Send( SCI_AUTOCSETFILLUPS, 0, cSet )
   METHOD AutoCSetChooseSingle( l )           INLINE ::Send( SCI_AUTOCSETCHOOSESINGLE, If( l, 1, 0 ), 0 )
   METHOD AutoCGetChooseSingle()              INLINE ::Send( SCI_AUTOCGETCHOOSESINGLE )
   METHOD AutoCSetIgnoreCase( l )             INLINE ::Send( SCI_AUTOCSETIGNORECASE, If( l, 1, 0 ), 0 )
   METHOD AutoCGetIgnoreCase()                INLINE ::Send( SCI_AUTOCGETIGNORECASE )
   METHOD Vchome()                            INLINE ::Send( SCI_VCHOME )
   METHOD Vchomeextend()                      INLINE ::Send( SCI_VCHOMEEXTEND )
   METHOD Vchomerectextend()                  INLINE ::Send( SCI_VCHOMERECTEXTEND )
   METHOD Vchomewrap()                        INLINE ::Send( SCI_VCHOMEWRAP )
   METHOD Vchomewrapextend ()                 INLINE ::Send( SCI_VCHOMEWRAPEXTEND )

   METHOD Wordleft ()                         INLINE ::Send( SCI_WORDLEFT )
   METHOD Wordleftend ()                      INLINE ::Send( SCI_WORDLEFTEND )
   METHOD Wordleftendextend ()                INLINE ::Send( SCI_WORDLEFTENDEXTEND )
   METHOD Wordleftextend ()                   INLINE ::Send( SCI_WORDLEFTEXTEND )
   METHOD Wordpartleft ()                     INLINE ::Send( SCI_WORDPARTLEFT )
   METHOD Wordpartleftextend ()               INLINE ::Send( SCI_WORDPARTLEFTEXTEND )
   METHOD Wordpartright ()                    INLINE ::Send( SCI_WORDPARTRIGHT )
   METHOD Wordpartrightextend ()              INLINE ::Send( SCI_WORDPARTRIGHTEXTEND )
   METHOD Wordright ()                        INLINE ::Send( SCI_WORDRIGHT )
   METHOD Wordrightend ()                     INLINE ::Send( SCI_WORDRIGHTEND )
   METHOD Wordrightendextend ()               INLINE ::Send( SCI_WORDRIGHTENDEXTEND )
   METHOD Wordrightextend ()                  INLINE ::Send( SCI_WORDRIGHTEXTEND )

      
   METHOD MenuEdit( lPopup )
    
   METHOD GetModify()                 INLINE SciGetProp( ::hWnd, SCI_GETMODIFY ) == 1
   METHOD GetReadOnly()               INLINE ::Send( SCI_GETREADONLY ) != 0
    
   METHOD GetCurLine()
   METHOD GotoLineEnsureVisible( nLine )
   METHOD BookmarkClearAll()
   METHOD SetToggleMark()
   METHOD SetEOL( lOn )
   METHOD SetLinIndent( lOnOff, lSinc )
   METHOD GetCaretInLine()
   METHOD SetMargin( lOn )
   METHOD LineSep()
   METHOD SetIndicators()
   METHOD SetIndent( nSize, lOn )
   METHOD GetFuncList()
   METHOD SetZoom( nZ )
   METHOD SetColourise( lOnOff )
   METHOD MarginClick( nMargen, nPos )
   METHOD HandleEvent( nMsg, uParam1, uParam2, uParam3 )


   METHOD CallTipShow( nPos, cText )     INLINE ::Send( 2200, nPos, cText )
   METHOD CallTipCancel()                INLINE ::Send( 2201, 0, 0 )
   METHOD CallTipActive()                INLINE ::Send( 2202, 0, 0 )
   METHOD CallTipPosStart()              INLINE ::Send( 2203, 0, 0 )
   METHOD CallTipSetHlt( nStart, nEnd )  INLINE ::Send( 2204, nStart, nEnd )
   METHOD CallTipSetBack( nColor )       INLINE ::Send( 2205, nColor, 0 )

   METHOD GetIndent()       INLINE SciGetProp( ::hWnd, SCI_GETINDENT )
   // METHOD GetLexer()        INLINE SciGetProp( ::hWnd, SCI_GETLEXER )
   METHOD GetLine( nLine )  INLINE SCIGETLINE( ::hWnd, nLine )
   METHOD GetLineCount()    INLINE SciGetProp( ::hWnd, SCI_GETLINECOUNT )



   METHOD SetText( cText )          INLINE SCISETTEXT( ::hWnd, cText )
   METHOD GetText()                 INLINE SCIGETTEXT( ::hWnd )
   METHOD GetLength()               INLINE ::Send( SCI_GETTEXTLENGTH )
   METHOD GetCurrentPos()           INLINE ::Send( SCI_GETCURRENTPOS )
   METHOD GetCurrentLineNumber()    INLINE ::LineFromPosition( ::GetCurrentPos() )
   METHOD LineFromPosition( nPos )  INLINE ::Send( SCI_LINEFROMPOSITION, nPos )
   METHOD PositionFromLine( nLine ) INLINE ::Send( SCI_POSITIONFROMLINE, nLine )

   METHOD GetLineIndentation( nL )  INLINE ::Send( SCI_GETLINEINDENTATION, nL )
   METHOD SetLineIndentation( nL, nI ) INLINE ::Send( SCI_SETLINEINDENTATION, nL, nI )

   METHOD GetProp( nMsg, nW, nL )   INLINE SCIGETPROP( ::hWnd, nMsg, nW, nL )
   METHOD GetSelText()              INLINE SCIGETSELTEXT( ::hWnd )
   METHOD GetTextRange( nS, nE )    INLINE SCIGETTEXTRANGE( ::hWnd, nS, nE )
   METHOD InsertText( nPos, cT )    INLINE ::Send( SCI_INSERTTEXT, nPos, cT )
   METHOD GotoPos( nPos )           INLINE ::Send( SCI_GOTOPOS, nPos )
   METHOD GotoLine( nLine )         INLINE ::Send( SCI_GOTOLINE, nLine )
   METHOD SetSel( nS, nE )          INLINE ::Send( SCI_SETSEL, nS, nE )
   METHOD Clear()                   INLINE ::Send( SCI_CLEAR )
   METHOD Bracy()                   INLINE ::Send( SCI_BRACEMATCH, ::GetCurrentPos() )
   METHOD BraceMatch( nP )          INLINE ::Send( SCI_BRACEMATCH, nP )
   METHOD BraceHighlight( n1, n2 )  INLINE ::Send( SCI_BRACEHIGHLIGHT, n1, n2 )
   METHOD BraceBadLight( nP )       INLINE ::Send( SCI_BRACEBADLIGHT, nP )
   METHOD GetCharAt( nP )           INLINE ::Send( SCI_GETCHARAT, nP )

   METHOD DlgOpen()
   METHOD SearchBackward( cText, nFlags )
   METHOD SearchForward( cText, nFlags )
   METHOD FindNext() INLINE ::SearchForward()
   METHOD FindPrev() INLINE ::SearchBackward()
   METHOD FindText( cText, lForward ) INLINE  If( lForward, ::SearchForward( cText ), ::SearchBackward( cText ) )
   METHOD DlgGotoLine()

   METHOD SetMBrace( nClr1, nClr2, nClrBad1, nClrBad2 )    

   METHOD GetTextColor( cType )
   METHOD SetTextColor( cType, nRGBColor )
   METHOD Replace()


   METHOD SetViewSpace( lOn )  
   METHOD ReplaceSel( cText )       INLINE ::Send( SCI_REPLACESEL, 0, cText )
   METHOD SetSavePoint()            INLINE ::Send( SCI_SETSAVEPOINT )
   

   METHOD SetTheme( cTheme )
   METHOD SelectTheme()
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nBottom, nRight, oWnd , cLex ) CLASS TScintilla
    
   DEFAULT cLex :=  "flagship"
    
   ::hWnd := SCICREATE( nTop, nLeft, nBottom - nTop, nRight - nLeft, oWnd:hWnd, Self )
   ::oWnd = oWnd

   ::aMarkerHand := {}
   ::aBookMarker := {}
   ::lIndicators := .F.
   ::lLinTabs    := .F.
   ::nManualAnchor := 0

   oWnd:AddControl( Self )

   ::brclicked:= { ||  msginfo("rclick")    }

   if ! lKeywordsLoaded .and. ( File( ResPath() + "/hbdocs.json" ) .or. File( Path() + "/hbdocs.json" ) )
      oHbDocs := THbDocs():New()
      if oHbDocs:aDocs != nil
         SCISETGLOBALKEYWORDS( oHbDocs:GetAllSortedList() )
         SCISETGLOBALDOCS( oHbDocs:GetAllDocList() )
         lKeywordsLoaded := .T.
      endif
   endif
   
   if File( ResPath() + "/snippets.json" ) .or. File( Path() + "/snippets.json" )
      SCISETGLOBALSNIPPETS( hb_memoRead( if( File( ResPath() + "/snippets.json" ), ResPath() + "/snippets.json", Path() + "/snippets.json" ) ) )
   endif
     
   
return Self

//----------------------------------------------------------------------------//

METHOD MenuEdit( lPopup ) CLASS TScintilla

   local oMnu
   DEFAULT lPopup  := .F.

   if !lPopup
      MENU oMnu
   endif

   MENUITEM "Undo" ACTION ::Undo()
   SEPARATOR
   MENUITEM  "Code &separator" ACTION ::LineSep()

   if !lPopup
      ENDMENU
   endif
Return oMnu

//----------------------------------------------------------------------------//
METHOD SetIndicators() CLASS TScintilla

   if ::lIndicators
      ::Send( SCI_INDICSETSTYLE, 10, INDIC_SQUIGGLE )
      ::Send( SCI_INDICSETSTYLE, 11, INDIC_TT )
      ::Send( SCI_INDICSETSTYLE, 12, INDIC_PLAIN )
      ::Send( SCI_INDICSETSTYLE, 13, INDIC_DOTBOX )
      ::Send( SCI_INDICSETSTYLE, 14, INDIC_DOTS )
      ::Send( SCI_INDICSETSTYLE, 15, INDIC_BOX )
      ::Send( SCI_INDICSETSTYLE, 16, INDIC_ROUNDBOX )
      ::Send( SCI_INDICSETSTYLE, 17, INDIC_STRAIGHTBOX )
      ::Send( SCI_INDICSETSTYLE, 18, INDIC_FULLBOX )
      ::Send( SCI_INDICSETSTYLE, 19, INDIC_DASH )
      ::Send( SCI_INDICSETSTYLE, 20, INDIC_TEXTFORE )
      ::Send( SCI_INDICSETSTYLE, 21, INDIC_HIDDEN )

      //::Send( SCI_BRACEHIGHLIGHTINDICATOR, 1, 15 )
      //::Send( SCI_BRACEBADLIGHTINDICATOR, 1, 18 )

   endif

Return nil

//----------------------------------------------------------------------------//
METHOD SetIndent( nSize, lOn ) CLASS TScintilla

   DEFAULT lOn := If( ::Send( SCI_GETINDENTATIONGUIDES, 0, 0 ) == 0, .T., .F. )

   if lOn
      ::Send( SCI_SETINDENTATIONGUIDES, SC_IV_LOOKBOTH )
   else
      ::Send( SCI_SETINDENTATIONGUIDES, SC_IV_NONE )
   endif

   if !Empty(nSize)
      ::Send( SCI_SETINDENT, nSize )
   endif

retu nil

//----------------------------------------------------------------------------//
METHOD GetFuncList() CLASS TScintilla

   local nLines := ::GetLineCount(), n
   local cToken, cLine, aFunLines := {}
   // local cCommands := ""

   for n = 1 to nLines
      cToken = Lower( Left( cLine := LTrim( ::GetLine( n ) ), 4 ) )
      if cToken $ "func,proc,clas,meth" .and. ;
            Lower( cFileExt( ::cFileName ) ) $ "prg,ch"
         AAdd( aFunLines, { cLine, n, n + 1 } )
      endif

      if Left( cLine, 12 ) == "static funct"
         AAdd( aFunLines, { cLine, n, n + 1 } )
      endif

      if Left( cLine, 6 ) == "#xcomm"
         if StrToken( cLine, 2 ) == "@"
            AAdd( aFunLines, { "@ ... " + StrToken( cLine, 5 ), n, n + 1 } )
         else
            AAdd( aFunLines, { StrToken( cLine, 2 ) + " " + ;
               StrToken( cLine, 3 ), n, n + 1 } )
         endif
      endif

      if Left( cLine, 7 ) == "HB_FUNC"
         AAdd( aFunLines, { cLine, n, n + 1 } )
      endif

      if cToken $ "retu" .or. Left( cToken, 1 ) == "}"
         if ATail( aFunLines ) != nil
            ATail( aFunLines )[ 3 ] = n
         endif
      endif
   next

   ASort( aFunLines,,, { | x, y | x[ 1 ] < y[ 1 ] } )

   // To generate docs automatically!
   // if Lower( cFileExt( ::cFileName ) ) == "ch"
   //    AEval( aFunLines, { | a | cCommands += a[ 1 ] + CRLF } )
   //    MemoWrit( "commands.txt", cCommands )
   // endif

return aFunLines

//----------------------------------------------------------------------------//
METHOD GetCurLine() CLASS TScintilla
    
   local nLine := ::GetCurrentLineNumber()
   local cText := ::GetLine( nLine + 1 )
    
RETURN cText

//----------------------------------------------------------------------------//

METHOD GotoLineEnsureVisible( nextline )  CLASS TScintilla

   ::Send( SCI_ENSUREVISIBLEENFORCEPOLICY, nextline )
   ::Send( SCI_GOTOLINE, nextline )

return nil

//----------------------------------------------------------------------------//

METHOD BookmarkClearAll() CLASS TScintilla

   ::Send( SCI_MARKERDELETEALL, markerBookmark )

retu nil

//----------------------------------------------------------------------------//

METHOD SetToggleMark() CLASS TScintilla
   Local lSw   := .F.
   Local nLine := ::GetCurrentLineNumber()
   Local nPos, nMask, nMarker := 4

   nMask := ::Send( SCI_MARKERGET, nLine )
   
   if ! hb_bitTest( nMask, nMarker )
      AAdd( ::aMarkerHand, ::Send( SCI_MARKERADD, nLine, nMarker ) )
      AAdd( ::aBookMarker, nLine + 1 )
      lSw := .T.
   else
      ::Send( SCI_MARKERDELETE, nLine, nMarker )
      nPos := AScan( ::aBookMarker, nLine + 1 )
      if nPos > 0
         ::Send( SCI_MARKERDELETEHANDLE, ::aMarkerHand[ nPos ] )
         ADel( ::aBookMarker, nPos )
         ASize( ::aBookMarker, Len( ::aBookMarker ) - 1 )
         ADel( ::aMarkerHand, nPos )
         ASize( ::aMarkerHand, Len( ::aMarkerHand ) - 1 )
      endif
   endif

Return lSw

//----------------------------------------------------------------------------//

METHOD SetEOL( lOn ) CLASS TScintilla

   DEFAULT lOn := If( ::Send( SCI_GETVIEWEOL ) == 0, .T., .F. )

   if lOn
      ::Send( SCI_SETVIEWEOL, 1 )
   else
      ::Send( SCI_SETVIEWEOL, 0 )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD SetLinIndent( lOnOff, lSinc )  CLASS TScintilla
   Local nOp  := 0
   DEFAULT lOnOff := .T.
   DEFAULT lSinc  := .F.
   nOp := IF( lOnOff, 1 , 0 )
   //::lLinTabs     := !lOnOff
   // Lineas verticales de Tabuladores
   if lOnOff //::lLinTabs
      ::Send( SCI_SETINDENTATIONGUIDES , 1, 0 )  //0,2,3
      if !Empty( nOp )
         ::Send( SCI_SETHIGHLIGHTGUIDE, 30, 0)
      endif
      ::lLinTabs := .F.
   else
      ::Send( SCI_SETINDENTATIONGUIDES , 0, 0 )  //0,2,3
      ::lLinTabs := .T.
   endif
   if lSinc
      ::Refresh()
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD GetCaretInLine() CLASS TScintilla
    
   local nCaret     := ::GetCurrentPos()
   local nLine      := ::LineFromPosition( nCaret )
   local nLineStart := ::PositionFromLine( nLine )
    
RETURN nCaret - nLineStart

//----------------------------------------------------------------------------//

METHOD SetMargin( lOn ) CLASS TScintilla

   DEFAULT lOn := .T.

   if lOn
      ::Send( SCI_SETMARGINWIDTHN, 2, 14 )
   else
      ::Send( SCI_SETMARGINWIDTHN, 2, 0 )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD LineSep() CLASS TScintilla

   local nPos   := ::GetCurrentPos()
   ::InsertText( nPos, "//" + Replicate( "-", 76 ) + "//" + hb_eol() )
   ::GotoLine( ::GetCurrentLineNumber() + 2 )

Return nil

//----------------------------------------------------------------------------//

METHOD SetZoom( nZ ) CLASS TScintilla

   Local  nZoomFactor := ::GetProp( SCI_GETZOOM, 0, 0 )
   DEFAULT nZ  := 0
   if nZ > -11 .and. nZ < 21
      ::Send( SCI_SETZOOM, nZ, 0 )
   endif
   nZoomFactor := ::GetProp( SCI_GETZOOM, 0, 0 )

Return nZoomFactor

//----------------------------------------------------------------------------//

METHOD SetColourise( lOnOff ) CLASS TScintilla

   DEFAULT lOnOff := .T.
   if lOnOff
      ::Send( SCI_COLOURISE, 0, -1 )
   else
      ::Send( SCI_COLOURISE, 0, 1 )
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD MarginClick( nMargen, nPos ) CLASS TScintilla

   local nLine      := 0
   DEFAULT nMargen  := 0
   nLine    := ::Send( SCI_LINEFROMPOSITION, nPos, 0 ) + 1
   ::GotoPos( nPos )
   Do Case
      Case nMargen = 0
         ::GoToLine( nLine )
      Case nMargen = 1
         ::GoToLine( nLine )
         ::SetToggleMark()
      Case nMargen = 2
         ::Send( SCI_TOGGLEFOLD, nLine + 1 )
      Case nMargen = 3
      Case nMargen = 4
         ::GoToLine( nLine + 1 )
         Otherwise
   EndCase

Return nil

//----------------------------------------------------------------------------//

function _FSCI( hWnd, nMsg, hSender, uParam1, uParam2 )
   local aWindows:= GetAllWin()
   local oControl
   local nAt := AScan( aWindows, { | o | o:hWnd == hWnd } )

   if nAt != 0
      oControl := aWindows[ nAt ]:FindControl( hSender )
      if oControl != nil
         return oControl:HandleEvent( nMsg, uParam1, uParam2 )
      endif

   endif

return nil

//----------------------------------------------------------------------------//

METHOD HandleEvent( nMsg, uParam1, uParam2, uParam3 )  CLASS TScintilla

return nil

//----------------------------------------------------------------------------//

METHOD Close() CLASS TScintilla

   if ::GetModify()
      if MsgYesNo( "Save the changes ?", "File has changed" )
         ::Save()
      endif
   endif

   ::SetText( "" )
   ::cFileName = ""

return nil

//----------------------------------------------------------------------------//

METHOD Open( cFileName ) CLASS TScintilla

   if File( cFileName )
      ::cFileName = cFileName
      ::cFilePath = cFilePath( ::cFileName )
      ::SetText( MemoRead( cFileName ) )
      ::SetSavePoint() // unmodified state
   endif

return nil

//----------------------------------------------------------------------------//

METHOD Save() CLASS TScintilla

   local hFile

   if Empty( ::cFileName )
      ::cFileName = SaveFile( "Save as...", "*.prg")
      ::cFilePath = cFilePath( ::cFileName )
   endif

   hFile = FCreate( ::cFileName, "w" )
   FWrite( hFile, ::GetText() )
   FClose( hFile )

   ::SetSavePoint() // unmodified state

return nil
//----------------------------------------------------------------------------//

METHOD SaveAS( cFileName ) CLASS TScintilla

   local hFile

   if Empty( cFileName )
      cFileName = SaveFile( "Save as...", "*.prg" )
   endif

   hFile = FCreate( cFileName, "w" )
   FWrite( hFile, ::GetText() )
   FClose( hFile )

   ::SetSavePoint() // unmodified state
   ::cFileName := cFileName
   ::cFilePath = cFilePath( ::cFileName )

return nil

METHOD SetMBrace( nClr1, nClr2, nClrBad1, nClrBad2 ) CLASS TScintilla
   
   DEFAULT nClr1    := CLR_YELLOW
   DEFAULT nClr2    := CLR_GRAY
   DEFAULT nClrBad1 := CLR_RED
   DEFAULT nClrBad2 := CLR_BLACK

   ::Send( SCI_STYLESETFORE, STYLE_BRACELIGHT, nClr1 )
   ::Send( SCI_STYLESETBACK, STYLE_BRACELIGHT, nClr2 )
   ::Send( SCI_STYLESETFORE, STYLE_BRACEBAD, nClrBad1 )
   ::Send( SCI_STYLESETBACK, STYLE_BRACEBAD, nClrBad2 )

Return nil

//----------------------------------------------------------------------------//

METHOD SearchBackward( cText, nFlags ) CLASS TScintilla

   DEFAULT cText := ::GetSelText()

return If( ! SciSearchBackward( ::hWnd, cText, nFlags ), MsgBeep(),  )

//----------------------------------------------------------------------------//

METHOD SearchForward( cText, nFlags ) CLASS TScintilla

   local lFound

   DEFAULT cText := ::GetSelText()
   DEFAULT nFlags := 0

   lFound := SciSearchForward( ::hWnd, cText, nFlags )

   if ! lFound
      MsgBeep()
   endif

return lFound

//----------------------------------------------------------------------------//

METHOD DlgGotoLine() CLASS TScintilla

   local cLine := Space( 20 )

   if MsgGet( "Goto Line", "Line:", @cLine )
      if Val( cLine ) != 0
         ::GotoLine( Val( cLine ) )
      endif
   endif

return nil

//----------------------------------------------------------------------------//

METHOD Replace() CLASS TScintilla

   local cFind := Space( 50 )
   local cRep  := Space( 50 )
   
   if ScintillaReplace( @cFind, @cRep )
      ::SearchForward( AllTrim( cFind ) )
      ::ReplaceSel( AllTrim( cRep ) )
   endif

return nil

//----------------------------------------------------------------------------//

Function ScintillaReplace( cFind, cRep )

   local oDlg, oGet1, oGet2
   local lOk := .f.

   DEFINE DIALOG oDlg TITLE "Replace" ;
      FROM 220, 350 TO 380, 750

   @ 10, 10 SAY "Find:" OF oDlg SIZE 80, 17

   @ 10, 100 GET oGet1 VAR cFind OF oDlg SIZE 200, 22

   @ 40, 10 SAY "Replace:" OF oDlg SIZE 80, 17

   @ 40, 100 GET oGet2 VAR cRep OF oDlg SIZE 200, 22

   @ 80, 100 BUTTON "Run" OF oDlg ;
      ACTION ( lOk := .t., oDlg:End() )

   @ 80, 200 BUTTON "Cancel" OF oDlg ACTION oDlg:End()

   ACTIVATE DIALOG oDlg CENTERED

return lOk

//----------------------------------------------------------------------------//

METHOD DlgOpen() CLASS TScintilla

   local cFileName := cGetfile( "Select a file", "prg,ch,c,m,h" )

   if ! Empty( cFileName ) .and. File( cFileName )
      ::Open( cFileName )
      return .T.
   else
      return .F.
   endif

return nil

//----------------------------------------------------------------------------//

METHOD GetTextColor( cType ) CLASS TScintilla

   cType = Lower( cType )

   do case
      case cType == "strings"
         return ::Send( SCI_STYLEGETFORE, SCE_FS_STRING )

      case cType == "numbers"
         return ::Send( SCI_STYLEGETFORE, SCE_FS_NUMBER )

         otherwise
         return CLR_WHITE
   endcase

return nil

//----------------------------------------------------------------------------//

METHOD SetTextColor( cType, nRGBColor ) CLASS TScintilla

   cType = Lower( cType )

   do case
      case cType == "strings"
         return ::Send( SCI_STYLESETFORE, SCE_FS_STRING, nRGBColor )

      case cType == "numbers"
         return ::Send( SCI_STYLESETFORE, SCE_FS_NUMBER, nRGBColor )

   endcase

return nil

//----------------------------------------------------------------------------//

METHOD SetViewSpace( lOn ) CLASS TScintilla

   DEFAULT lOn := If( ::Send( SCI_GETVIEWWS ) == 0, .T., .F. )

   if lOn

      ::Send( SCI_SETVIEWWS, SCWS_VISIBLEALWAYS )
   else

      ::Send( SCI_SETVIEWWS, SCWS_INVISIBLE )

   endif

return nil

//----------------------------------------------------------------------------//


METHOD GetWordLeft() CLASS TScintilla

   local nPos       := ::GetCurrentPos()
   local nLine      := ::LineFromPosition( nPos )
   local nLineStart := ::PositionFromLine( nLine )
   // Get text from start of line up to cursor
   local cText      := ::GetTextRange( nLineStart, nPos )
   local cWord      := ""
   local nLen       := Len( cText )
   local i, cChar

   for i := nLen to 1 step -1
      cChar := SubStr( cText, i, 1 )
      // Simple check: Allow A-Z, a-z, 0-9, _
      if ! ( ( cChar >= "A" .and. cChar <= "Z" ) .or. ;
            ( cChar >= "a" .and. cChar <= "z" ) .or. ;
            ( cChar >= "0" .and. cChar <= "9" ) .or. ;
            cChar == "_" )
         exit
      endif
      cWord := cChar + cWord
   next
   
return cWord

//----------------------------------------------------------------------------//

METHOD SetTheme( cTheme ) CLASS TScintilla
   local aThemes := { "Dark", "Light", "Monokai", "Solarized" }
   nSel := AScan( aThemes, cTheme )
   if nSel > 0
      SCINTILLA_SET_THEME( ::hWnd, nSel )
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD SelectTheme() CLASS TScintilla
   SelectScintillaTheme( self )
return nil

//----------------------------------------------------------------------------//

function SelectScintillaTheme( oSci )
   local aThemes := { "Dark", "Light", "Monokai", "Solarized" }
   local nSel := MSGSELECTFROMLIST( "Select Editor Theme", aThemes )

   if nSel > 0
      SCINTILLA_SET_THEME(oSci:hWnd, nSel )
   endif
return nil

//----------------------------------------------------------------------------//

METHOD AutoCShowKeywords() CLASS TScintilla

   if oHbDocs != nil
      ::AutoCShow( Len( ::GetWordLeft() ), oHbDocs:GetAllSortedList() )
   endif

   return nil

   //----------------------------------------------------------------------------//

return nil
