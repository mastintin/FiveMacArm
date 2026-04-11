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

   METHOD Setup()

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
   METHOD InsertSnippet( cBody )
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
   METHOD AutoIndent()
   METHOD SetIndicators()
   METHOD SetIndent( nSize, lOn )
   METHOD GetFuncList()
   METHOD SetZoom( nZ )
   METHOD SetColourise( lOnOff )
   METHOD MarginClick( nMargen, nPos )
   METHOD HandleEvent( nMsg, uParam1, uParam2, uParam3 )
   METHOD Notify( nType, pScnNotification )

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

   /*
   METHOD InitEdt()
   METHOD IntelliSense( nChar )
   METHOD SetMBrace()
   METHOD HandleBraceMatch()
   METHOD SearchBackward( cText, nFlags )
   METHOD SearchForward( cText, nFlags )
   METHOD Replace()
   METHOD DlgOpen()
   METHOD DlgGotoLine()
   METHOD GetTextColor( cType )
   METHOD SetTextColor( cType, nRGBColor )
   METHOD SetViewSpace( lOn )
*/
   METHOD ReplaceSel( cText )       INLINE ::Send( SCI_REPLACESEL, 0, cText )
   METHOD SetSavePoint()            INLINE ::Send( SCI_SETSAVEPOINT )

      DATA cCKeyw1, cCKeyw2, cCKeyw3, cCKeyw4, cCKeyw5
      DATA cCComment, cCCommentLin, cCOperator, cCString, cCNumber, cCBraces, cCBraceBad, cCIdentif
   DATA nClrPane

   METHOD ValidChar( c ) INLINE  Lower( c ) $ "abcdefghijklmnopqrstuvwxyz1234567890ñ"

   
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

   ::Setup()
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

METHOD AutoIndent() CLASS TScintilla

   local nCurLine     := ::GetCurrentLineNumber()
   
   // MsgInfo( "AutoIndent Triggered" )
   local nPrevLine    := nCurLine - 1
   local nIndentation := ::GetLineIndentation( nPrevLine )
   local cPrevLine    := LTrim( ::GetLine( nPrevLine ) )
   local cToken
   local cCurline
   local nPos
   local aTockens
   local n
   local cUTocken
   // MsgInfo( "AutoIndent Triggered" )
   //MsgInfo( "AutoIndent: " + Str(nIndentation) )
   if nIndentation > 0
      ::InsertText( ::GetCurrentPos(), Space( nIndentation ) )
      ::GotoPos( ::GetCurrentPos() + nIndentation )
   endif

   cCurline    := LTrim( ::GetLine( nCurLine ) )

   // Smart: Increase Indentation
   if ! Empty(cCurline)
      //if ! Empty( cPrevLine )
      // Remove CRLF to ensure clean token parsing
      //cPrevLine := StrTran( cPrevLine, Chr( 10 ), "" )
      //cPrevLine := StrTran( cPrevLine, Chr( 13 ), "" )

      cCurLine := StrTran( cCurline, Chr( 10 ), "" )
      cCurline := StrTran( cCurLine, Chr( 13 ), "" )
           
      cToken := Lower( SubStr( cCurline, 1, AT( " ", cCurline + " " ) - 1 ) )
      
      nIndentation := ::GetLineIndentation( nPrevLine )
       
      if cToken $ "if try while for do switch case otherwise else elseif endif catch next end enddo endcase"
         
         // BLOCK OPENERS: Simple Indent +4
         if cToken $ "if try while for switch do "
            nIndentation += 4
            ::SetLineIndentation( nCurLine , nIndentation )
            ::GotoPos( ::GetCurrentPos() + nIndentation )
         endif

         // MIDDLE: Dedent Previous (-4), Indent Current (Stay +4)
         // Applied to: else, elseif, case, catch, otherwise
         if cToken == "else" .or. cToken == "elseif" .or. cToken == "case" .or. ;
               cToken == "catch" .or. cToken == "otherwise"
            
            nIndentation -= 4
            ::SetLineIndentation( nCurLine -1 , nIndentation )
            
            nIndentation += 4
            ::SetLineIndentation( nCurLine , nIndentation )
            ::GotoPos( ::GetCurrentPos() + nIndentation )
         endif

         // CLOSERS: Dedent Previous (-4), Current Line should match Previous (-4)
         // Applied to: endif, end, enddo, endcase, next
         // Note: If user types "endif<Enter>", PrevLine is "endif".
         // PrevLine should be dedented. Current Line should ALSO be dedented.
         if cToken == "endif" .or. cToken == "end" .or. cToken == "enddo" .or. ;
               cToken == "endcase" .or. cToken == "next"
            
            nIndentation -= 4
            ::SetLineIndentation( nCurLine -1 , nIndentation )
            ::SetLineIndentation( nCurLine , nIndentation )
            ::GotoPos( ::GetCurrentPos() + nIndentation )
         endif
                  
      endif
   endif
      
return nil


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
#define WM_COMMAND 1001

METHOD HandleEvent( nMsg, uParam1, uParam2, uParam3 )  CLASS TScintilla

   local nLocation, nLine, nLevel

   do case

      case nMsg ==WM_RBUTTONDOWN
         NSLOG( "RB" )
      case nMsg == WM_COMMAND



      case nMsg == WM_LBUTTONDOWN
         NSLOG( "LB" )

         //Case nMsg == WM_CONTEXTMENU
         //  ::Send( SCI_USEPOPUP, 0 )
         //   ? "usepop"

         NSLOG( "CONTEXT" )
      case nMsg == WM_SCINOTIFY
         ::Notify( uParam1, uParam2 )

      case nMsg == 9995 // Manual Tab Key
         // MsgInfo( "Tab intercepted in FSCI. Forwarding..." )
         if ! Empty( ::bKeyDown )
            Eval( ::bKeyDown, 9 )
         endif
         return nil

      case nMsg == 9994 // Manual AutoComplete (Ctrl+Space)
         if ! Empty( ::bKeyDown )
            Eval( ::bKeyDown, -1 ) // Use -1 or special code for Manual Trigger
         endif
         return nil

      case nMsg == 9996 // Manual Auto-Indent (Enter Key)
         ::AutoIndent()

      case nMsg == 9997 // Manual Drag Handler (Selection Support)
         // Offset Logic: Universal +57 seems robust for text.
         // If left of text (Margin), +57 maps to internal margin/start-of-line.
         nLocation = ::Send( 2022, Max( 0, uParam1 + 57 ), uParam2 )
        
         // NUCLEAR OPTION: SCI_SETSEL (2160)
         // Sets selection from Anchor to New Pos and enforces Single Selection.
         ::Send( 2160, ::nManualAnchor, nLocation ) 

      case nMsg == 9999 // Manual Sidebar Handler (Offset Bug Fix)
        
         // Zone 1: Line Numbers (0-35)
         if uParam1 <= 35
            nLocation = ::Send( 2022, 0, uParam2 ) 
            ::Send( 2160, nLocation, nLocation ) // SEL = Pos (Empty)
            ::nManualAnchor = nLocation
           
            // Zone 2: Fold Margin (35-55)
         elseif uParam1 > 35 .and. uParam1 <= 55
            nLocation = ::Send( 2022, 0, uParam2 )
            nLine = ::Send( 2166, nLocation, 0 )
            nLevel = ::Send( 2223, nLine, 0 )
            if hb_BitAnd( nLevel, 8192 ) != 0
               ::Send( 2231, nLine, 0 ) // SCI_TOGGLEFOLD
               // Ensure we don't leave weird selection state
               ::Send( 2160, nLocation, nLocation )
               ::nManualAnchor = nLocation
            else
               ::Send( 2160, nLocation, nLocation ) // Select Line Start
               ::nManualAnchor = nLocation
            endif
 
            // Zone 3: Text Area (55+)
         else
            // OFFSET FIX (USER REQ FINAL 3): 57.
            nLocation = ::Send( 2022, uParam1 + 57, uParam2 ) 
            ::Send( 2160, nLocation, nLocation ) // SEL = Pos
            ::nManualAnchor = nLocation
         endif
        
         ::Send( 2400, 0, 0 ) // SCI_GRABFOCUS
         ::Send( 2233, 16, 0 ) 
         otherwise
         NSLOG ( "Super" )
         ::super:HandleEvent( nMsg, uParam1, uParam2,uParam3 )
   endcase

return nil



//----------------------------------------------------------------------------//

METHOD Notify( nType, pScnNotification ) CLASS TScintilla
   local nMargin,nPos,nLine

   local nCode := ScnCode( pScnNotification )
   
   // if nCode == 2022
   //    MsgInfo( "Notify Code: " + Str( nCode ) ) 
   // endif

   do case
      case nCode == 2022 // SCN_AUTOCSELECTION
         cText := SciGetNotifyText( pScnNotification )
        
         nPos  := At( "(", cText ) // Generalize for "Function(" and "Function (Lib)"
        
         if nPos > 0
            // Extract clean function name
            cName := RTrim( Left( cText, nPos - 1 ) )
           
            // Cancel default insertion and insert clean text
            ::AutoCCancel()
            ::ReplaceSel( cName )
           
            // Show full info as CallTip
            ::CallTipShow( ::GetCurrentPos(), cText )
         endif
 
      case nCode == SCN_CHARADDED
         ::CharAdded( ScnCh( pScnNotification ) )

      case nCode == SCN_UPDATEUI
         if ::nLastPos != ::GetCurrentPos()
            ::nLastPos := ::GetCurrentPos()
            ::HandleBraceMatch()
            if ::bChange != nil
               Eval( ::bChange, Self )
            endif
         endif

      case nCode == SCN_MARGINCLICK

         nPos = ScNPos( pScnNotification )
         nLine = ::LineFromPosition( nPos )
         nMargin := ScNMargin( pScnNotification )

         if nMargin < 0
            // ::Send(SCI_TOGGLEFOLD, nLine+1)
         endif

         if nMargin == 2
            ::Send( SCI_TOGGLEFOLD, nLine )
         endif
         if nMargin == 0
            ::GotoPos( nPos )
            ::SetToggleMark()
         endif


         // case nType == IBNCaretChanged
         //     if ::bChange != nil
         //        Eval( ::bChange, Self )
         //   endif
 
   endcase


return nil

//----------------------------------------------------------------------------//

METHOD CharAdded( nChar ) CLASS TScintilla

   if ! Empty( ::bCharAdded )
      Eval( ::bCharAdded, nChar, Self )
   endif

   // Trigger on NewLine (10=LF, 13=CR)
   if nChar == 10 .or. nChar == 13
      // ::AutoIndent() // HANDLED VIA EVENT MONITOR (Avoid Double Trigger)
   else
      ::IntelliSense( nChar )
   endif

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
   /*

METHOD InitEdt() CLASS TScintilla
    
   local oCrs
    
   //::nMargLeft     := 4
   ::nMargRight    := 4
   ::nSpacLin      := 2
    
   /*
    ::nWidthTab     := 3
    ::aHCopy        := {}
    ::aCopys        := {}
    ::aBookMarker   := {}
    ::aMarkerHand   := {}
    ::aPointBreak   := {}
    ::nMarker       := SC_MARK_SHORTARROW
    ::lVirtSpace    := .T.
    ::bViews        := { || .T. }
    ::bDoubleView   := { || .T. }
    ::cPlugIn       := ""
    ::lLinTabs      := .F.
    ::nMargen       := -1
    ::nPos64        := -1
    ::lTipFunc      := .T.
    ::nColorSelectionB  := ::nCaretBackColor
    ::aIndentChars  := { ;
        { "IF", 1 },;
        { "ENDIF", -1 },; //{ "ELSE", -1 },;
        { "FOR", 1 },;
        { "NEXT", -1 },;
        { "DO", 1 },;
        { "WITH", 1 },;
        { "END", -1 },;
        { "ENDDO", -1 },;
        { "FUNCTION", 0 },;
        { "RETURN", 0 },;
        { "METHOD", 0 },;
        { "CLASS", 0 },;
        { "HB_FUNC", 0 } ;
    }
    
    if ::lPtr
        ::GetDirecPointer()
    endif
    if ::lMultiView
        ::GetDocPointer()
    endif
*/

Return nil
///
//----------------------------------------------------------------------------//


//----------------------------------------------------------------------------//
METHOD IntelliSense( nChar ) CLASS TScintilla

   local cWord, cDoc

   do case
      // All logic moved to native C layer in scintillas.m
   endcase

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

//----------------------------------------------------------------------------//
/*
METHOD SetMBrace() CLASS TScintilla

   ::Send( SCI_STYLESETFORE, STYLE_BRACELIGHT, ::cCBraces[ 1 ] )
   ::Send( SCI_STYLESETBACK, STYLE_BRACELIGHT, ::cCBraces[ 2 ] )
   ::Send( SCI_STYLESETFORE, STYLE_BRACEBAD, ::cCBraceBad[ 1 ] )
   ::Send( SCI_STYLESETBACK, STYLE_BRACEBAD, ::cCBraceBad[ 2 ] )

Return nil

//----------------------------------------------------------------------------//

METHOD HandleBraceMatch() CLASS TScintilla

   local nPos, nMatchPos, cChar

   if ::hWnd == 0
      return nil
   endif

   nPos := ::GetCurrentPos()

   // Check character at cursor
   cChar := Chr( ::GetCharAt( nPos ) )
   if cChar $ "()[]{}" 
      nMatchPos := ::BraceMatch( nPos )
      if nMatchPos != -1
         ::BraceHighlight( nPos, nMatchPos )
         return nil
      else
         ::BraceBadLight( nPos )
         return nil
      endif
   endif

   // Check character before cursor
   if nPos > 0
      nPos--
      cChar := Chr( ::GetCharAt( nPos ) )
      if cChar $ "()[]{}" 
         nMatchPos := ::BraceMatch( nPos )
         if nMatchPos != -1
            ::BraceHighlight( nPos, nMatchPos )
            return nil
         else
            ::BraceBadLight( nPos )
            return nil
         endif
      endif
   endif

   ::BraceHighlight( -1, -1 )

return nil

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
*/
//----------------------------------------------------------------------------//


METHOD Setup() CLASS TScintilla
return nil

/*
METHOD Setup() CLASS TScintilla


   local n

   //local KeyWords1  := CadComand()

   local cCad0 := ;
      "action activate adjust array as autocols autosort " + ; //aadd //ascan atail
      "bar begin bitmap bold bool bottom break brush button buttonbar byte " + ;
      "center centered century change checkbox checked " + ; //cfilenopath
      "click color colors columns colsizes controls " + ;
      "combobox constructor crlf cursor " + ;
      "default #define deleted design dialog " + ; //disable
      "#else #endif endini entry enum epoch explorer " + ;  //enable
      "filter folder folderex font footer " + ; //filename
      "get group " + ;
      "hbitmap header height hinds horizontal " + ;
      "icon id #ifdef #ifndef image #include ini init items " + ;
      "justify " + ;
      "keyboard " +;
      "left lib lines listbox local long lpstr lpwstr " + ;
      "margin maximized mdi mdichild memo " + ;  //memoline memoread memowrit
      "menuitem menupos message msgbar msgitem mru " + ;
      "new noborder " + ;
      "of on option " + ;
      "paint pascal pixel previous private prompt prompts public " + ;
      "radioitem radiomenu readonly recordset refresh resize resource right round " + ;
      "say section separator sequence set setfocus size spinner splitter " + ;
      "static style super struct " + ;
      "tab title to tooltip top transparent typedef " + ;
      "#undef update " + ;
      "valid var vertical " + ;
      "when width window " + ;
      "xbrowse " + ;
      "2007 2010 2013 2015"


   local cCad1 := " "

   local cCad2 := "function procedure return class method for while " + ;
      "iif if else elseif do with object begindump " + ;
      "hb_func func loop case otherwise switch menu void "

   local cCad3 := "endif endclass next from data classdata inline virtual "+;
      "setget endcase endobject endmenu return "+;
      "memvar enddo end endwhile endwith enddump endswitch hb_ret " + ;
      "hb_retc hb_retc_nul hb_retc_buf hb_retc_con hb_retclen " + ;
      "hb_retds hb_retd hb_retdl hb_rettd hb_rettdt hb_retl " + ;
      "hb_retnd hb_retni hb_retnl hb_retns hb_retnint hb_retnlen "+;
      "hb_retndlen hb_retnilen hb_retnllen hb_retnintle hb_reta " + ;
      "hb_retptr hb_retnll hb_retnlllen "

   local cCad4 := "$@\\&<>#(){}[]"

   local KeyWords0 := ""
   local KeyWords1 := ""
   local KeyWords2 := ""
   local KeyWords3 := ""
   local KeyWords4 := ""

   local aMarkers := { ;
      { SC_MARKNUM_FOLDEROPEN, SC_MARKNUM_FOLDER , SC_MARKNUM_FOLDERSUB, SC_MARKNUM_FOLDERTAIL, ;
      SC_MARKNUM_FOLDEREND , SC_MARKNUM_FOLDEROPENMID, SC_MARKNUM_FOLDERMIDTAIL },;
      { SC_MARK_MINUS        , SC_MARK_PLUS        , SC_MARK_EMPTY, SC_MARK_EMPTY, ;
      SC_MARK_EMPTY        , SC_MARK_EMPTY       , SC_MARK_EMPTY},;
      { SC_MARK_ARROWDOWN    , SC_MARK_ARROW       , SC_MARK_EMPTY, SC_MARK_EMPTY, ;
      SC_MARK_EMPTY        , SC_MARK_EMPTY       , SC_MARK_EMPTY},;
      { SC_MARK_CIRCLEMINUS  , SC_MARK_CIRCLEPLUS  , SC_MARK_VLINE, ;
      SC_MARK_LCORNERCURVE, ;
      SC_MARK_CIRCLEPLUSCONNECTED, SC_MARK_CIRCLEMINUSCONNECTED,;
      SC_MARK_TCORNERCURVE },;
      { SC_MARK_BOXMINUS,      SC_MARK_BOXPLUS,  SC_MARK_VLINE,   SC_MARK_LCORNER,;
      SC_MARK_BOXPLUSCONNECTED, SC_MARK_BOXMINUSCONNECTED, SC_MARK_TCORNER },;
      { SC_MARK_BOXMINUS,      SC_MARK_BOXPLUS,   SC_MARK_VLINE,   SC_MARK_LCORNER,;
      SC_MARK_TCORNER,             SC_MARK_VLINE,                SC_MARK_VLINE }, ;
      { SC_MARK_CIRCLEMINUS  , SC_MARK_CIRCLEPLUS  , SC_MARK_VLINE, ;
      SC_MARK_LCORNER, ;
      SC_MARK_CIRCLEPLUSCONNECTED, SC_MARK_CIRCLEMINUSCONNECTED,;
      SC_MARK_TCORNER };
      }


   ::nClrPane := ::nBackColor

   if !Empty( ::cListFuncs )
      KeyWords0  := lower( ::cListFuncs )
      KeyWords1  := cCad2 + cCad3
   else
      KeyWords0  := cCad2 + cCad3
      KeyWords1  := ""
   endif

   KeyWords2  := cCad0


    // Lexer type is flagship. Already set in C / SCICREATE
    // SCISETLEXER( ::hWnd, ::cLexer )
   //ScintillaDebugLog( "Lexer Name: " + ::cLexer + " Lexer ID: " + Str( ::GetLexer() ) )

   ::InitEdt()

   ::SetLinIndent( .t., .f. )

   // Number of styles we use with this lexer.
   ::Send( SCI_SETSTYLEBITS, SCIGETONEPROP(::hWnd, SCI_GETSTYLEBITSNEEDED  ))


   // Keywords to highlight. Indices are:
   // 0 - Major keywords (reserved keywords)
   // 1 - Normal keywords (everything not reserved but integral part of the language)
   // 2 - Database objects
   // 3 - Function keywords
   // 4 - System variable keywords
   // 5 - Procedure keywords (keywords used in procedures like "begin" and "end")
   // 6..8 - User keywords 1..3

   
//[mEditor setReferenceProperty: SCI_SETKEYWORDS parameter: 0 value: major_keywords];
//[mEditor setReferenceProperty: SCI_SETKEYWORDS parameter: 5 value: procedure_keywords];
//[mEditor setReferenceProperty: SCI_SETKEYWORDS parameter: 6 value: client_keywords];
//[mEditor setReferenceProperty: SCI_SETKEYWORDS parameter: 7 value: user_keywords];




   ::Send( SCI_SETKEYWORDS, 0, KeyWords0 )
   ::Send( SCI_SETKEYWORDS, 1, KeyWords1 )
   ::Send( SCI_SETKEYWORDS, 2, KeyWords2 )

   //::Send( SCI_SETKEYWORDS, 3, KeyWords3 )
   //::Send( SCI_SETKEYWORDS, 4, KeyWords4 )


   ::Send( SCI_COLOURISE, 0, -1 )
  
   ::Send( SCI_STYLESETFORE, STYLE_DEFAULT, ::nTextColor )  // texto gernerico
   ::Send( SCI_STYLESETBACK, STYLE_DEFAULT, ::nBackColor )  // Color fondo editor

   ::Send( SCI_STYLECLEARALL, 0, 0 )

   ::SetMBrace()
 
   ::Send( SCI_AUTOCSETIGNORECASE, 1, 0 )
   ::Send( SCI_AUTOCSETCASEINSENSITIVEBEHAVIOUR, SC_CASEINSENSITIVEBEHAVIOUR_IGNORECASE, 0 ) // -> 1
   ::Send( SCI_AUTOCSETMAXHEIGHT, 10, 0 )
  
   ::Send( SCI_SETEXTRAASCENT , Max( 1.6, ::nSpacLin ) )
   ::Send( SCI_SETEXTRADESCENT, Max( 1.6, ::nSpacLin ) )
   
   // FIX DEAD ZONE: DISABLE Left Padding (MarginLeft = 0) -> User requested Padding.
   // Setting to 8px for visual comfort.
   ::Send( SCI_SETMARGINLEFT, 0, 8 ) 
   
   ::Send( SCI_SETMARGINRIGHT, 0, ::nMargRight )

   ::Send(SCI_SETFOLDMARGINCOLOUR,1, rgb(210,210,210) )
   ::Send(SCI_SETFOLDMARGINHICOLOUR,1, rgb(210,210,210) )

   ::Send( SCI_MARKERSETFORE, 1, CLR_BLUE )

   // Margin 0: Line Numbers (35px)
   ::Send( SCI_SETMARGINWIDTHN, 0, 35 ) 
   ::Send( SCI_SETMARGINTYPEN, 0, SC_MARGIN_NUMBER )
    
   // Margin 1: Symbols (0px - Hidden)
   ::Send( SCI_SETMARGINWIDTHN, 1, 0 )
   ::Send( SCI_SETMARGINTYPEN,  1, SC_MARGIN_SYMBOL )
   ::Send( SCI_SETMARGINMASKN,  1, 0 ) 
    
   // Margin 2: Folding (20px - Matches Visual 55px total)
   ::Send( SCI_SETMARGINWIDTHN, 2, 20 )
   ::Send( SCI_SETMARGINTYPEN,  2, SC_MARGIN_SYMBOL )
   ::Send( SCI_SETMARGINMASKN,  2, SC_MASK_FOLDERS ) 
   ::Send( SCI_SETMARGINSENSITIVEN, 2, 1 )

   // FOLDING LINES
   // 16 = Draw line below if not expanded
   ::Send( 2233, 16, 0 ) 
   ::Send( SCI_COLOURISE, 0, -1 ) // Force redraw

   ::Send( SCI_SETPROPERTY, "fold", "1" )
   ::Send( SCI_SETPROPERTY, "fold.compact", "0" )
   ::Send( SCI_SETPROPERTY, "fold.comment", "1" )
   ::Send( SCI_SETPROPERTY, "fold.preprocessor", "1" )

   ::Send( SCI_MARKERDEFINE, SC_MARK_CIRCLEPLUS, SC_MARK_CIRCLEPLUS ) 
   ::Send( SCI_MARKERDEFINE, SC_MARK_CIRCLEMINUS, SC_MARK_CIRCLEMINUS ) 
   ::Send( SCI_MARKERDEFINE, SC_MARK_CIRCLEPLUSCONNECTED, SC_MARK_CIRCLEPLUSCONNECTED ) 
   ::Send( SCI_MARKERDEFINE, SC_MARK_CIRCLEMINUSCONNECTED, SC_MARK_CIRCLEMINUSCONNECTED ) 
   ::Send( SCI_MARKERDEFINE, SC_MARK_TCORNER, SC_MARK_TCORNER ) 
   ::Send( SCI_MARKERDEFINE, SC_MARK_VLINE, SC_MARK_VLINE ) 

   ::Send( SCI_MARKERDEFINE, 4, SC_MARK_BOOKMARK )

   ::Send( SCI_SETCARETLINEBACK, CLR_HCYAN )
   ::Send( SCI_SETCARETLINEVISIBLE, 1 )

   ::SetHighlightColors()

   // ----------------Line number style.  ---------------------------

   ::Send( SCI_SETMARGINTYPEN, 0, SC_MARGIN_NUMBER )
   ::Send( SCI_SETMARGINWIDTHN, 0, 35 )

   ::SetAStyle( SCE_FS_COMMENTDOCKEYWORD, CLR_YELLOW )
   ::SetAStyle( SCE_FS_COMMENTDOCKEYWORDERROR, CLR_YELLOW )

   //------------------ini foldering

   if  ::lFolding
      ::Send( SCI_SETAUTOMATICFOLD, SC_AUTOMATICFOLD_CLICK, 0 )
   endif


   ::Send( SCI_SETMARGINWIDTHN, 2, 18 )
   ::Send( SCI_SETMARGINMASKN , 2, SC_MASK_FOLDERS )

   ::Send( SCI_MARKERDEFINE, SC_MARKNUM_FOLDEROPEN, SC_MARK_BOXMINUS )
   ::Send( SCI_MARKERDEFINE, SC_MARKNUM_FOLDER ,SC_MARK_BOXPLUS )
   ::Send( SCI_MARKERDEFINE, SC_MARKNUM_FOLDERSUB , SC_MARK_EMPTY )
   ::Send( SCI_MARKERDEFINE, SC_MARKNUM_FOLDERTAIL ,SC_MARK_EMPTY )
   ::Send( SCI_MARKERDEFINE, SC_MARKNUM_FOLDEREND ,SC_MARK_EMPTY )
   ::Send( SCI_MARKERDEFINE, SC_MARKNUM_FOLDEROPENMID ,SC_MARK_BOXMINUS )
   ::Send( SCI_MARKERDEFINE, SC_MARKNUM_FOLDERMIDTAIL ,SC_MARK_EMPTY )



   ::Send(SCI_SETMARGINSENSITIVEN , 0 ,1 )
   ::Send(SCI_SETMARGINSENSITIVEN , 2 ,1 )


   ::Send( SCI_USEPOPUP,0,0 )


   for  n= 25 to 31 // Markers 25..31 are reserved for folding.

      ::Send( SCI_MARKERSETFORE, n, CLR_WHITE )  // color folder
      ::Send( SCI_MARKERSETBACK, n, CLR_BLACK )

   NEXT


   // Init markers & indicators for highlighting of syntax errors.

   ::Send( SCI_INDICSETFORE, 0, CLR_RED )
   ::Send( SCI_INDICSETUNDER, 0, 1 )
   ::Send( SCI_INDICSETSTYLE, 0, INDIC_SQUIGGLE )

   //::Send(SCI_MARKERSETFORE,SC_MARKNUM_FOLDEROPEN, 14215660 )
   //::Send(SCI_MARKERSETBACK,SC_MARKNUM_FOLDEROPEN, RGB(128, 128, 128) )
   //::Send(SCI_MARKERSETFORE,SC_MARKNUM_FOLDER, RGB(236, 233, 216) )
   //::Send(SCI_MARKERSETBACK,SC_MARKNUM_FOLDER, RGB(128, 128, 128) )
   //::Send(SCI_MARKERSETBACK,SC_MARKNUM_FOLDERSUB, RGB(128, 128, 128) )
   //::Send(SCI_MARKERSETBACK,SC_MARKNUM_FOLDERTAIL, RGB(128, 128, 128) )
   //::Send(SCI_MARKERSETFORE,SC_MARKNUM_FOLDEREND, RGB(236, 233, 216) )
   //::Send(SCI_MARKERSETBACK,SC_MARKNUM_FOLDEREND, RGB(128, 128, 128) )
   //::Send(SCI_MARKERSETFORE,SC_MARKNUM_FOLDEROPENMID, RGB(236, 233, 216) )
   //::Send(SCI_MARKERSETBACK,SC_MARKNUM_FOLDEROPENMID, RGB(128, 128, 128) )
   //::Send(SCI_MARKERSETBACK,SC_MARKNUM_FOLDERMIDTAIL, RGB(128, 128, 128) )


   //::Send( SCI_SETMARGINTYPEN, 0, SC_MARGIN_BACK)


   //Set autoindentation con 4 spaces
   ::Send( SCI_SETINDENT, 4, 0  )
   ::Send( SCI_SETTABINDENTS, 1, 0  )
   ::Send( SCI_SETBACKSPACEUNINDENTS, 1, 0 )


   ::setLexerProp( "fold","1")
   ::setLexerProp( "fold.compact","0")
   ::setLexerProp( "fold.comment","1")
   ::setLexerProp( "fold.preprocessor","1")


   //-------------------end

   ::SetEdgeColumn( 128 )
   ::SetEdgeMode( 1 )

   ::SetUseTabs( .F. )

return nil

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
*/
//----------------------------------------------------------------------------//

/*
#define SCLEX_FLAGSHIP 73

METHOD SetHighlightColors() CLASS TScintilla
 
 
   if ::GetLexer() == SCLEX_FLAGSHIP
       
      ::SetAStyle( SCE_FS_COMMENTLINE,    ::cCCommentLin[ 1 ], ::nClrPane )
      ::SetAStyle( SCE_FS_COMMENTDOC,     ::cCComment[ 1 ]   , ::nClrPane )
      ::SetAStyle( SCE_FS_COMMENTLINEDOC, ::cCCommentLin[ 1 ], ::nClrPane )
      ::SetAStyle( SCE_FS_COMMENT,        ::cCComment[ 1 ]   , ::nClrPane )
      ::SetAStyle( SCE_FS_PREPROCESSOR ,  ::cCIdentif[ 1 ]   , ::nClrPane )
       
      ::StyleSet( SCE_FS_OPERATOR      ) ; ::StyleSetColor( ::cCOperator[ 1 ] )
      ::StyleSet( SCE_FS_STRING     )    ; ::StyleSetColor( ::cCString[ 1 ]  )
      ::StyleSet( SCE_FS_NUMBER     )    ; ::StyleSetColor( ::cCNumber[ 1 ] )
  
      ::StyleSet( SCE_FS_KEYWORD       ) ; ::StyleSetColor( ::cCKeyw1[ 1 ] )
      ::StyleSet( SCE_FS_KEYWORD4      ) ; ::StyleSetColor( ::cCKeyw4[ 1 ] )
      ::StyleSet( SCE_FS_KEYWORD2     )  ; ::StyleSetColor( ::cCKeyw2[ 1 ] )
      ::StyleSet( SCE_FS_KEYWORD3     )  ; ::StyleSetColor( ::cCKeyw3[ 1 ] )
    
      ::Send( SCI_STYLESETFORE, STYLE_LINENUMBER, ::nTColorLin )
      ::Send( SCI_STYLESETBACK, STYLE_LINENUMBER, ::nBColorLin )
    
      ::Send( SCI_STYLESETBACK, SCE_FS_STRING,       ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_COMMENTLINE,  ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_OPERATOR,     ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_NUMBER,       ::nClrPane )
    
      ::Send( SCI_STYLESETBACK, SCE_FS_KEYWORD,      ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_KEYWORD4,     ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_KEYWORD2,     ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_KEYWORD3,     ::nClrPane )
      
      //  if Upper( ::oFont:cFaceName ) <> Upper( "FixedSys" )
      //      ::Send( SCI_STYLESETITALIC, SCE_FS_COMMENTLINE, 1 )
      //  endif
      
   else
       
      ::SetAStyle( SCE_FS_COMMENTLINE,    ::cCCommentLin[ 1 ], ::nClrPane )
      ::SetAStyle( SCE_FS_COMMENTDOC,     ::cCComment[ 1 ]   , ::nClrPane )
      ::SetAStyle( SCE_FS_COMMENTLINEDOC, ::cCCommentLin[ 1 ], ::nClrPane )
      ::SetAStyle( SCE_FS_COMMENT,        ::cCComment[ 1 ]   , ::nClrPane  )
       
      ::Send( SCI_STYLESETFORE, STYLE_LINENUMBER, ::nTColorLin )
      ::Send( SCI_STYLESETBACK, STYLE_LINENUMBER, ::nBColorLin )
     
 
      ::Send( SCI_STYLESETFORE, SCE_FWH_OPERATOR, ::cCOperator[ 1 ] )
      ::Send( SCI_STYLESETFORE, SCE_FWH_STRING, ::cCString[ 1 ] )
      ::Send( SCI_STYLESETFORE, SCE_FWH_NUMBER, ::cCNumber[ 1 ] )
      ::Send( SCI_STYLESETFORE, SCE_FWH_BRACE, ::cCBraces[ 1 ] )
      ::Send( SCI_STYLESETFORE, SCE_FWH_IDENTIFIER, ::cCIdentif[ 1 ] )
       
      ::Send( SCI_STYLESETFORE, SCE_FWH_KEYWORD, ::cCKeyw1[ 1 ] )
      ::Send( SCI_STYLESETFORE, SCE_FWH_KEYWORD1, ::cCKeyw2[ 1 ] )
      ::Send( SCI_STYLESETFORE, SCE_FWH_KEYWORD2, ::cCKeyw3[ 1 ] )
      ::Send( SCI_STYLESETFORE, SCE_FWH_KEYWORD3, ::cCKeyw4[ 1 ] )
      ::Send( SCI_STYLESETFORE, SCE_FWH_KEYWORD4, ::cCKeyw5[ 1 ] )
      
      ::Send( SCI_STYLESETBACK, SCE_FWH_DEFAULT, ::nClrPane )
       
      ::Send( SCI_STYLESETBACK, SCE_FWH_OPERATOR, ::cCOperator[ 2 ] )
      ::Send( SCI_STYLESETBACK, SCE_FWH_STRING, ::cCString[ 2 ] )
      ::Send( SCI_STYLESETBACK, SCE_FWH_NUMBER, ::cCNumber[ 2 ] )
      ::Send( SCI_STYLESETBACK, SCE_FWH_BRACE, ::cCBraces[ 2 ] )
      ::Send( SCI_STYLESETBACK, SCE_FWH_IDENTIFIER, ::cCIdentif[ 2 ] )
   
      ::Send( SCI_STYLESETBACK, SCE_FWH_KEYWORD, ::cCKeyw1[ 2 ] )
      ::Send( SCI_STYLESETBACK, SCE_FWH_KEYWORD1, ::cCKeyw2[ 2 ] )
      ::Send( SCI_STYLESETBACK, SCE_FWH_KEYWORD2, ::cCKeyw3[ 2 ] )
      ::Send( SCI_STYLESETBACK, SCE_FWH_KEYWORD3, ::cCKeyw4[ 2 ] )
      ::Send( SCI_STYLESETBACK, SCE_FWH_KEYWORD4, ::cCKeyw5[ 2 ] )
     
      ::Send( SCI_STYLESETCASE, SCE_FWH_COMMENTDOC, ::cCComment[ 3 ] )
      ::Send( SCI_STYLESETCASE, SCE_FWH_COMMENT, ::cCComment[ 3 ] )
      ::Send( SCI_STYLESETCASE, SCE_FWH_COMMENTLINE, ::cCCommentLin[ 3 ] )
        
      ::Send( SCI_STYLESETCASE, SCE_FWH_OPERATOR, ::cCOperator[ 3 ] )
      ::Send( SCI_STYLESETCASE, SCE_FWH_STRING, ::cCString[ 3 ] )
      ::Send( SCI_STYLESETCASE, SCE_FWH_NUMBER, ::cCNumber[ 3 ] )
      ::Send( SCI_STYLESETCASE, SCE_FWH_BRACE, ::cCBraces[ 3 ] )
      ::Send( SCI_STYLESETCASE, SCE_FWH_IDENTIFIER, ::cCIdentif[ 3 ] )
  
      ::Send( SCI_STYLESETCASE, SCE_FWH_KEYWORD, ::cCKeyw1[ 3 ] )
      ::Send( SCI_STYLESETCASE, SCE_FWH_KEYWORD1, ::cCKeyw2[ 3 ] )
      ::Send( SCI_STYLESETCASE, SCE_FWH_KEYWORD2, ::cCKeyw3[ 3 ] )
      ::Send( SCI_STYLESETCASE, SCE_FWH_KEYWORD3, ::cCKeyw4[ 3 ] )
      ::Send( SCI_STYLESETCASE, SCE_FWH_KEYWORD4, ::cCKeyw5[ 3 ] )
        
     
        //::Send( SCI_STYLESETFONT, SCE_FWH_DEFAULT , ::oFont:cFaceName ) //::oFntLin:cFaceName )
        //::Send( SCI_STYLESETSIZE , SCE_FWH_DEFAULT, Abs( Int( ::oFont:nHeight ) * 1 ) )
        //::Send( SCI_STYLESETFONT, SCE_FWH_COMMENT, ::oFont:cFaceName ) //::oFntLin:cFaceName )
        //::Send( SCI_STYLESETSIZE , SCE_FWH_COMMENT, Abs( Int( ::oFont:nHeight ) * 1 ) )
        
       // if !Empty( ::oFont )
       //     if Upper( ::oFont:cFaceName ) <> Upper( "FixedSys" )
       //         ::Send( SCI_STYLESETITALIC, SCE_FWH_COMMENT, 1 )
       //         ::Send( SCI_STYLESETITALIC, SCE_FWH_COMMENTDOC, 1 )
       //         ::Send( SCI_STYLESETITALIC, SCE_FWH_COMMENTLINE, 1 )
       //     endif
       // endif
   
   endif
  
return nil
*/


//----------------------------------------------------------------------------//

Function CadWordFold( nOp )
   Local cCad2 := "function return procedure"

   Local cCad3 := "class endclass from data classdata method inline virtual setget "+;
      "super with object endobject"
   DEFAULT nOp  := 1
Return if( nOp = 1, cCad2, cCad3 )

//----------------------------------------------------------------------------//



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

METHOD InsertSnippet( cBody ) CLASS TScintilla

   local nPos      := ::GetCurrentPos()
   // Recalculate word start manually like in GetWordLeft because SCI_WORDSTARTPOSITION is failing
   local cWord     := ::GetWordLeft() 
   local nLen      := Len( cWord )
   local nStart    := nPos - nLen
   local nStartSeq, nEndSeq, cToken, cContent, cDefault
 
   // Remove the triggered keyword
   ::SetSel( nStart, nPos )
   ::Clear()
   
   // Basic Parser for VSCode Snippets
   cBody := StrTran( cBody, "$0", "" )
   cBody := StrTran( cBody, "$1", "" )
   cBody := StrTran( cBody, "$2", "" )
   cBody := StrTran( cBody, "$3", "" )
   
   // Replace ${n:default} with default
   do while "${" $ cBody
      nStartSeq := At( "${", cBody )
      // Find closing brace after start. 
      // Since At doesn't support offset, we substring or regex.
      // Easiest here: find "}" in the substring starting at nStartSeq
      nEndSeq   := At( "}", SubStr( cBody, nStartSeq ) )
      
      if nEndSeq > 0
         nEndSeq  := nStartSeq + nEndSeq - 1
         cToken   := SubStr( cBody, nStartSeq, nEndSeq - nStartSeq + 1 ) // ${1:label}
         
         // Safety check to avoid infinite loop if no } found properly
         if Empty( cToken )
            exit
         endif

         cContent := SubStr( cBody, nStartSeq + 2, nEndSeq - nStartSeq - 2 ) // 1:label
         
         if ":" $ cContent
            cDefault := SubStr( cContent, At( ":", cContent ) + 1 )
         else
            cDefault := "" // VSCode uses empty if no default.
         endif
         
         cBody := StrTran( cBody, cToken, cDefault )
      else
         exit // Error or malformed
      endif
   enddo
   
   ::InsertText( nStart, cBody )
   
return nil
//----------------------------------------------------------------------------//

//METHOD SetTheme( cTheme ) CLASS TScintilla
/*
   local nBg, nText, nKw, nCmd, nComment, nStr, nPre, nNum, nSel

   do case
      case cTheme == "Dark"
         nBg := RGB(30,30,30); nText := RGB(212,212,212); nKw := RGB(86,156,214)
         nCmd := RGB(78,201,176); nComment := RGB(106,153,85); nStr := RGB(206,145,120)
         nPre := RGB(197,134,192); nNum := RGB(181,206,168); nSel := RGB(38,79,120)

      case cTheme == "Light"
         nBg := RGB(255,255,255); nText := RGB(0,0,0); nKw := RGB(0,0,255)
         nCmd := RGB(0,128,128); nComment := RGB(0,128,0); nStr := RGB(163,21,21)
         nPre := RGB(128,0,128); nNum := RGB(128,64,0); nSel := RGB(173,214,255)

      case cTheme == "Monokai"
         nBg := RGB(39,40,34); nText := RGB(248,248,242); nKw := RGB(249,38,114)
         nCmd := RGB(102,217,239); nComment := RGB(117,113,94); nStr := RGB(230,219,116)
         nPre := RGB(166,226,46); nNum := RGB(174,129,255); nSel := RGB(73,72,62)

      case cTheme == "Solarized"
         nBg := RGB(0,43,54); nText := RGB(131,148,150); nKw := RGB(181,137,0)
         nCmd := RGB(42,161,152); nComment := RGB(88,110,117); nStr := RGB(42,161,152)
         nPre := RGB(203,75,22); nNum := RGB(211,54,130); nSel := RGB(7,54,66)
      
         otherwise
         return nil   
   endcase
*/
/* Apply to Scintilla */
/*
   ::Send( 3352, 32, nText ) // SCI_STYLESETFORE = 3352, STYLE_DEFAULT = 32
   ::Send( 3353, 32, nBg )   // SCI_STYLESETBACK = 3353
   ::Send( 3350, 0, 0 )      // SCI_STYLECLEARALL = 3350

   ::Send( 3352, 33, RGB(133,133,133) ) // STYLE_LINENUMBER = 33
   ::Send( 3353, 33, if( cTheme == "Light", RGB(240,240,240), RGB(37,37,38) ) )

   ::Send( 3352, 5, nKw ) // SCE_C_WORD = 5
   ::Send( 3355, 5, 1 )   // SCI_STYLESETBOLD = 3355
   ::Send( 3352, 16, nCmd ) // SCE_C_WORD2 = 16
   ::Send( 3352, 1, nComment ) // SCE_C_COMMENT = 1
   ::Send( 3352, 2, nComment ) // SCE_C_COMMENTLINE = 2
   ::Send( 3351, 1, 1 )        // SCI_STYLESETITALIC = 3351
   ::Send( 3352, 6, nStr )  // SCE_C_STRING = 6
   ::Send( 3352, 4, nNum )  // SCE_C_NUMBER = 4
   ::Send( 3352, 9, nPre )  // SCE_C_PREPROCESSOR = 9
   
   ::Send( 2069, if( cTheme == "Light", RGB(0,0,0), RGB(255,255,255) ), 0 ) // SCI_SETCARETFORE = 2069
   ::Send( 2068, 1, nSel ) // SCI_SETSELBACK = 2068
*/
//return nil

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
