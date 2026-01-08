//----------------------------------------------------------------------------//
//
// CLASS TScintila: Wrapper for Fivewin/(X)Harbour Source Code Editor
// Based in Scintilla.org ( (C) Neil Hodgson )
// Autor: Cristobal Navarro Lopez ( 2014 - 2016 )
// Date:  16/09/2016
//
//----------------------------------------------------------------------------//

#include "FiveWin.ch"
#include "Scintilla.ch"
#include "report.ch"
#include "mail.ch"
#include "colores.ch"

#define SC_CASE_CAMEL   3
#define COLOR_WINDOW    5

#define VK_CTRL_A       1
#define VK_CTRL_B       2
#define VK_CTRL_C       3
#define VK_CTRL_D       4
#define VK_CTRL_E       5
#define VK_CTRL_F       6
#define VK_CTRL_G       7
#define VK_CTRL_H       8
#define VK_CTRL_I       9
#define VK_CTRL_J      10
#define VK_CTRL_K      11
#define VK_CTRL_L      12
#define VK_CTRL_M      13
#define VK_CTRL_N      14
#define VK_CTRL_O      15
#define VK_CTRL_P      16
#define VK_CTRL_Q      17
#define VK_CTRL_R      18
#define VK_CTRL_S      19
#define VK_CTRL_T      20
#define VK_CTRL_U      21
#define VK_CTRL_V      22
#define VK_CTRL_W      23
#define VK_CTRL_X      24
#define VK_CTRL_Y      25
#define VK_CTRL_Z      26
#define VK_CTRL_DOT   190

#define SC_KEYMENU       0xF100 //61696
#define WM_NOTIFY        0x004E  //78
#define WM_ACTIVATE      0x0006
#define WM_SETTEXT       0x000C
#define MK_MBUTTON       0x0010

#ifdef __XHARBOUR__
   #define hb_CurDrive CurDrive
#endif

static oReport
Static aFHb   := {}
Static aFHb1  := {}
Static aFFw   := {}

//----------------------------------------------------------------------------//

#ifdef __XHARBOUR__
function HB_EOL()
return CRLF
#endif

//----------------------------------------------------------------------------//

CLASS TScintilla FROM TControl

   DATA aCopys
   DATA aKey             AS ARRAY INIT {}
   DATA cFileName
   DATA cFoundToken
   DATA cLastFind        INIT ""
   DATA cWritten         INIT ""
   DATA nCurrentPos
   DATA nSelStart        INIT 0
   DATA nSelEnd          INIT 0
   DATA nSetStyle
   DATA nTokenPos
   DATA oColItem
   DATA oRowItem

   DATA lMargLin
   DATA lMarking
   DATA lFolding
   DATA lMessage
   DATA lMargRun

   DATA nMargLines       INIT 0
   DATA nMargSymbol      INIT 0
   DATA nMargFold        INIT 0
   DATA nMargText        INIT 0
   DATA nMargBuild       INIT 0
   DATA nMarker

   DATA nMargLeft
   DATA nMargRight
   DATA nSpacLin
   DATA nWidthTab
   DATA lVirtSpace
   DATA nStyle           INIT 0

   DATA aBookMarker
   DATA aMarkerHand
   DATA aPointBreak
   DATA nTpMonitor
   DATA oModify
   DATA oUndo
   DATA oRedo
   DATA bViews
   DATA oFldEdt
   DATA oFntEdt
   DATA cPlugin
   DATA oAnota
   DATA lDebugEd         INIT .F.
   DATA lDebugSt         INIT .F.
   DATA cLexer
   DATA lLinTabs
   DATA nMargen
   DATA nPos64
   DATA lTipFunc
   DATA bTxtMarg
   DATA cUser            INIT ""
   DATA cFontS
   DATA nHFont
   DATA bESC             //INIT { || .T. }
   DATA lSaveBak         INIT .F.
   //DATA oFontU
   //DATA bDragFiles       INIT { || .T. }
   //
   DATA cLang
   DATA lUtf8            INIT .F.
   DATA lBom             INIT .F.
   DATA lUtf16           INIT .F.
   DATA lBig             INIT .F.
   DATA cFontInfo
   DATA cFontInfoU
   DATA nOrden           INIT 1
   DATA lIndicators      INIT .F.
   DATA oListFunc
   DATA oMarkPnel
   DATA oFindPnel
   DATA oFntLin
   DATA cTodosCar        INIT "_:.,;}{][*/+-><)(&%$#|@!Â¡?Â¿abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789Ã±Ã‘"
   DATA cChars           INIT "abcdefghijklmnopqrstuvwxyz1234567890Ã±"
   //
   DATA nCaretBackColor  INIT CLR_VSSEL
   DATA nColorSelection  INIT RGB( 0, 179, 179 )
   DATA nColorSelectionB INIT CLR_VSSEL
   DATA nColorLimitCol   INIT CLR_VSCAR

   DATA cCComment        INIT { CLR_GRAY, CLR_WHITE, SC_CASE_MIXED, } //HGRAY
   DATA cCCommentLin     INIT { CLR_GRAY, CLR_WHITE, SC_CASE_MIXED, }
   DATA cCString         INIT { CLR_HRED, CLR_WHITE, SC_CASE_MIXED, }
   DATA cCNumber         INIT { CLR_RED, CLR_WHITE, SC_CASE_MIXED, }
   DATA cCOperator       INIT { CLR_BLUE, CLR_WHITE, SC_CASE_MIXED, }
   DATA cCBraces         INIT { CLR_BLUE, CLR_YELLOW, SC_CASE_MIXED, }
   DATA cCBraceBad       INIT { CLR_HRED, CLR_YELLOW, SC_CASE_MIXED, }
   DATA cCIdentif        INIT { CLR_GREEN, CLR_WHITE, SC_CASE_MIXED, } //MAGENTA
   DATA cCKeyw1          INIT { METRO_ORANGE, CLR_WHITE, SC_CASE_MIXED, } //CYAN
   DATA cCKeyw2          INIT { METRO_ORANGE, CLR_WHITE, SC_CASE_MIXED, } // METRO_BROWN
   DATA cCKeyw3          INIT { METRO_BROWN, CLR_WHITE, SC_CASE_MIXED, }  // CLR_BLUE
   DATA cCKeyw4          INIT { CLR_BLUE, CLR_WHITE, SC_CASE_MIXED, } //METRO_CYAN
   DATA cCKeyw5          INIT { METRO_CYAN, CLR_WHITE, SC_CASE_MIXED, } //METRO_MAUVE   // STEEL

   DATA aIndentChars
   DATA nModeSave        INIT 1  //1 Normal (Default)-2 Ansi-3 Utf-4 Utf No bom
   DATA nModeLoad        INIT 1
   DATA nModeNew         INIT 1
   DATA lFoundToken      INIT .F.
   DATA cListUser1
   DATA cListAutoc
   DATA cListFuncs
   DATA lHistClip        INIT .F.
   DATA oHistClip
   DATA oMenuClip
   DATA aHCopy
   DATA bMnuClipB
   DATA uFlagFind        INIT 0
   DATA aHistFind        INIT {}
   DATA bSetup
   DATA lMnuMargen       INIT .T.
   DATA nWidthCursor     INIT 1
   DATA nOldPos          INIT 0
   DATA nTipCaret        INIT 1
   DATA nKey64           INIT 0
   DATA lPtr             INIT .F.
   DATA hPtr
   DATA pDoc
   DATA lMultiView       INIT .F.
   DATA nMnuStyle
   DATA nTColorLin       INIT CLR_BLUE
   DATA nBColorLin       INIT CLR_VSBAR
   DATA nTColorMar       INIT CLR_BLUE
   DATA nBColorMar       INIT CLR_BLUE
   DATA nTColorFol       INIT CLR_WHITE
   DATA nBColorFol       INIT CLR_VSBAR
   DATA nTColorRun       INIT CLR_BLUE
   DATA nBColorRun       INIT CLR_HGRAY
   DATA nTColorUsr       INIT CLR_BLUE
   DATA nBColorUsr       INIT CLR_HGRAY
   DATA bDoubleView
   DATA lAutoWords       INIT .F.
   DATA aFunLines        INIT {}
   DATA lModified        INIT .F.
   DATA bModified
   DATA cReplace
   DATA bSearch          INIT { || .T. }
   DATA oZoom
   DATA nMarkFold        INIT 4
   DATA lNeedUpdate      INIT .F.

   CLASSDATA lRegistered AS LOGICAL
   CLASSDATA hLib
   CLASSDATA nInst       AS NUMERIC INIT 0
   CLASSDATA aMrus       AS ARRAY   INIT {}
   CLASSDATA cLineBuffer
   CLASSDATA nPtr
   CLASSDATA nViews      AS NUMERIC INIT 0
   
   METHOD New( nRow, nCol, nWidth, nHeight, oWnd, nClrT, nClrP, cLex, cDll, bSetup, lLoad, cPathApli ) CONSTRUCTOR
   METHOD AddFile( lFin, lHome )
   METHOD AddRefDocument( pDoc )              INLINE ::Send( SCI_ADDREFDOCUMENT, 0, pDoc )
   METHOD AddText( cText )                    INLINE ::Send( SCI_ADDTEXT, Len( cText ), cText )
   METHOD AddKey( nKey, bAction )             INLINE AAdd( ::aKey, { nKey, bAction } )
   METHOD AddTextCRLF( cText )                INLINE ::Send( SCI_ADDTEXT, Len( cText ) + 2, cText + CRLF )
   METHOD AnotaActivas()                      INLINE ::Send( 2549, 0, 0 )
   METHOD AutoIndent()
   METHOD Backtab()                           INLINE ::Send( SCI_BACKTAB, 0, 0 )
   METHOD BookmarkClearAll( nM )
   METHOD BraceBadlight( nPos1, nPos2 )       INLINE ::Send( SCI_BRACEBADLIGHT, nPos1, nPos2 )
   METHOD BraceHighlight( nPos1, nPos2 )      INLINE ::Send( SCI_BRACEHIGHLIGHT, nPos1, nPos2 )
   METHOD BraceMatch( nPos )                  INLINE ::Send( SCI_BRACEMATCH, nPos )
   METHOD CalcWidthMargin()
   METHOD CallTipActive()                     INLINE ::Send( SCI_CALLTIPACTIVE, 0, 0 ) == 1
   METHOD CallTipCancel()                     INLINE ::Send( SCI_CALLTIPCANCEL )
   METHOD CallTipShow( nPosStart, cText )     INLINE ::Send( SCI_CALLTIPSHOW, nPosStart, cText )
   METHOD CanRedo()                           INLINE ::Send( SCI_CANREDO ) != 0
   METHOD CanUndo()                           INLINE ::Send( SCI_CANUNDO ) != 0
   METHOD Cancel()                            INLINE ::Send( SCI_CANCEL )
   METHOD CapMay()
   METHOD CaracterSet( nOp, lIni, nC )
   METHOD CharAdded( nPos, nLine, cChar )
   METHOD CharLeft()                          INLINE ::Send( SCI_CHARLEFT )
   METHOD CharLeftExtend()                    INLINE ::Send( SCI_CHARLEFTEXTEND )
   METHOD CharLeftrectExtend()                INLINE ::Send( SCI_CHARLEFTRECTEXTEND )
   METHOD CharRight()                         INLINE ::Send( SCI_CHARRIGHT )
   METHOD CharRightExtend()                   INLINE ::Send( SCI_CHARRIGHTEXTEND )
   METHOD CharRightRectextend()               INLINE ::Send( SCI_CHARRIGHTRECTEXTEND )
   METHOD ClearAll()                          INLINE ::Send( SCI_CLEARALL )
   METHOD ClearKeys()                         INLINE AsignKeys( ::hWnd )
   METHOD Close( lEnd )                       INLINE ::CloseF( lEnd )
   METHOD CloseF( lEnd )
   METHOD Copy()                              INLINE ::Send( SCI_COPY )
   METHOD CopyLine()                          INLINE ::Send( SCI_LINECOPY )
   METHOD CopyRange( nStart, nEnd )           INLINE ::Send( SCI_COPYRANGE, nStart, nEnd )
   METHOD CopyText( cCad )                    INLINE ::Send( SCI_COPYTEXT, Len( cCad ), cCad )
   METHOD CreateDocument()                    INLINE ( ::pDoc := ::Send( SCI_CREATEDOCUMENT, 0, 0 ) )
   METHOD Cut()                               INLINE ::Send( SCI_CUT )
   METHOD Deleteback()                        INLINE ::Send( SCI_DELETEBACK )
   METHOD Deletebacknotline()                 INLINE ::Send( SCI_DELETEBACKNOTLINE )
   METHOD DeleteRange( nPos, nLen )           INLINE ::Send( SCI_DELETERANGE, nPos, nLen )
   METHOD Dellineleft()                       INLINE ::Send( SCI_DELLINELEFT )
   METHOD Dellineright()                      INLINE ::Send( SCI_DELLINERIGHT )
   METHOD Delwordleft()                       INLINE ::Send( SCI_DELWORDLEFT )
   METHOD Delwordright()                      INLINE ::Send( SCI_DELWORDRIGHT )
   METHOD DlgChars( lEnd )
   METHOD DesComment( lMulti )
   METHOD DlgFindText( nR, nC, lDlg )
   METHOD DlgFindWiki( nR, nC, lDlg )
   METHOD DlgGoToLine()
   METHOD DlgInsChar( nLin1, nLin2, lEnd )
   METHOD DlgReplace()
   METHOD DocIsUtf8( cDoc, lUtf8 )
   METHOD Documentend()                       INLINE ::Send( SCI_DOCUMENTEND )
   METHOD Documentendextend()                 INLINE ::Send( SCI_DOCUMENTENDEXTEND )
   METHOD Documentstart()                     INLINE ::Send( SCI_DOCUMENTSTART )
   METHOD Documentstartextend()               INLINE ::Send( SCI_DOCUMENTSTARTEXTEND )
   //METHOD DrawItem( nId, pItem )              INLINE ::Super:DrawItem( nId, pItem )
   METHOD DrawItem( nId, pItem ) VIRTUAL
   METHOD Edittoggleovertype()                INLINE ::Send( SCI_EDITTOGGLEOVERTYPE )
   METHOD EmptyUndoBuffer()                   INLINE ::Send( EM_EMPTYUNDOBUFFER )
   METHOD End( nPos )
   METHOD ExecPlugIn( cPl )
   METHOD FindButton( cText, lForward, lSpacesL, oBtn )
   METHOD FindNext()                          INLINE ::FindText( If( ! Empty( ::GetSelText() ), ::GetSelText(), ::cLastFind ), .T. )
   METHOD FindPrev()                          INLINE ::FindText( If( ! Empty( ::GetSelText() ), ::GetSelText(), ::cLastFind ), .F. )
   METHOD FindText( cText, lForward )
   METHOD FindToken( nPos ) //cStart, lBack )
   METHOD FoldAllContract()                   INLINE ::Send( SCI_FOLDALL, SC_FOLDACTION_CONTRACT, 0 )
   METHOD FoldAllExpand()                     INLINE ::Send( SCI_FOLDALL, SC_FOLDACTION_EXPAND, 0 )
   METHOD FoldAllToggle()                     INLINE ::Send( SCI_FOLDALL, SC_FOLDACTION_TOGGLE, 0 )
   METHOD FoldLevelNumber()                   INLINE ::Send( SCI_SETFOLDFLAGS, SC_FOLDFLAG_LEVELNUMBERS, 0 )
   METHOD FoldLineNumber()                    INLINE ::Send( SCI_SETFOLDFLAGS, SC_FOLDFLAG_LINEAFTER_CONTRACTED, 0 )
   METHOD FoldLineSt()                        INLINE ::Send( SCI_SETFOLDFLAGS, 128, 0 )
   METHOD GetAnchor()                         INLINE ::Send( SCI_GETANCHOR )
   METHOD GetCaretLineBack()                  INLINE ::Send( SCI_GETCARETLINEBACK )
   METHOD GetCaretInLine()
   METHOD GetCharAt( nPos )                   INLINE ::Send( SCI_GETCHARAT, nPos )
   METHOD GetCurLine()
   METHOD GetCurrentLine()
   METHOD GetCurrentLineNumber()              INLINE ::Send( SCI_LINEFROMPOSITION, ::GetCurrentPos() )
   METHOD GetCurrentPos()                     INLINE ::Send( SCI_GETCURRENTPOS )
   METHOD GetCurrentStyle()
   METHOD GetCursor()                         INLINE ::Send( SCI_GETCURSOR, 0, 0 )
   METHOD GetDirecPointer()                   INLINE ( ::hPtr  := ::Send( SCI_GETDIRECTPOINTER, 0, 0 ) )
   METHOD GetDocPointer()                     INLINE ( ::pDoc  := ::Send( SCI_GETDOCPOINTER, 0, 0 ) )
   METHOD GetFirstVisible()                   INLINE ::Send( SCI_GETFIRSTVISIBLELINE, 0, 0 )
   METHOD GetLine( nLine )                    INLINE SciGetLine( ::hWnd, nLine )
   METHOD GetLineCount()                      INLINE ::Send( SCI_GETLINECOUNT )
   METHOD GetLineIndentation( nLine )         INLINE ::Send( SCI_GETLINEINDENTATION, nLine )
   METHOD GetModify()                         INLINE ( ::Send( SCI_GETMODIFY, 0, 0 ) <> 0 )
   METHOD GetReadOnly()                       INLINE ::Send( SCI_GETREADONLY ) != 0
   METHOD GetSelText()                        INLINE ;
                                              SciGetSelText( ::hWnd, ::GetSelectionEnd() - ;
                                                             ::GetSelectionStart() )
   METHOD GetSelectionEnd()                   INLINE ::Send( SCI_GETSELECTIONEND )
   METHOD GetSelectionStart()                 INLINE ::Send( SCI_GETSELECTIONSTART )
   METHOD GetStyleAt( nPos )                  INLINE ::Send( SCI_GETSTYLEAT, nPos, 0 )
   METHOD GetTargetEnd()                      INLINE ::Send( SCI_GETTARGETEND, 0, 0 )
   METHOD GetTargetStart()                    INLINE ::Send( SCI_GETTARGETSTART, 0, 0 )
   //METHOD GetTargetText()                     INLINE ::Send( SCI_GETTARGETTEXT, 0, @cText )
   METHOD GetText()                           INLINE SciGetText( ::hWnd )
   METHOD GetTextAt( nPos )                   INLINE SciGetTextAt( ::hWnd, nPos )
   METHOD GetTextRange( nLin0, nCol0, nLin1, nCol1 )
   METHOD GetTipCursor()                      INLINE ::Send( SCI_GETCARETSTYLE, 0, 0 )
   METHOD GetUniCode()                        INLINE (::Send( SCI_GETCODEPAGE, 0, 0 ) <> SC_CP_UTF8)
   METHOD GetWidthCursor()                    INLINE ::Send( SCI_GETCARETWIDTH, 0, 0 )
   METHOD GetWord( lTip, lMove, lCopy )
   METHOD GoAtEnd()                           INLINE ::Send( SCI_DOCUMENTEND, 0, 0 )
   METHOD GoDown()                            INLINE ::Send( SCI_LINEDOWN )
   METHOD GoEol()                             INLINE ::Send( SCI_LINEEND, 0, 0 )
   METHOD GoHome()                            INLINE ::Send( SCI_HOME )
   METHOD GoLeft()                            INLINE ::CharLeft()
   METHOD GoLine( nLine )                     INLINE ::Send( SCI_GOTOLINE, nLine - 1, 0 )
   METHOD GoLineEnsureVisible( nLine )
   METHOD GoRight()                           INLINE ::CharRight()
   METHOD GoUp()                              INLINE ::Send( SCI_LINEUP )
   METHOD GotFocus() INLINE If( ::GetCurrentPos() < ::nSelStart .or. ;
                                ::GetCurrentPos() > ::nSelEnd,;
                                ::SetSel( ::GetCurrentPos(), ::GetCurrentPos() ),;
                                ::SetSel( ::nSelStart, ::nSelEnd ) ), ::Super:GotFocus()
   METHOD GotoFirstVisible( nLine )           INLINE ::Send( SCI_SETFIRSTVISIBLELINE, nLine, 0 )
   METHOD GotoLine( nLine )                   INLINE ::PostMsg( SCI_GOTOLINE, nLine - 1, 0 )
   METHOD GotoLineEnsureVisible( nextline )
   METHOD GotoPos( nPos )                     INLINE ::Send( SCI_GOTOPOS, nPos, 0 )
   METHOD GotoOldPos()                        INLINE ::Send( SCI_GOTOPOS, ::nOldPos, 0 )
   METHOD HandleEvent( nMsg, nWParam, nLParam )
   METHOD HighlightWord( cText, nIndic )
   METHOD Home()                              INLINE ::Send( SCI_HOME )
   METHOD Homedisplay()                       INLINE ::Send( SCI_HOMEDISPLAY )
   METHOD Homedisplayextend()                 INLINE ::Send( SCI_HOMEDISPLAYEXTEND )
   METHOD Homeextend()                        INLINE ::Send( SCI_HOMEEXTEND )
   METHOD Homerectextend()                    INLINE ::Send( SCI_HOMERECTEXTEND )
   METHOD Homewrap()                          INLINE ::Send( SCI_HOMEWRAP )
   METHOD Homewrapextend()                    INLINE ::Send( SCI_HOMEWRAPEXTEND )
   METHOD InitEdt()
   METHOD InsertChars( cCad, uAction, lEnd, lSel )
   METHOD InsertTab( lSel )
   METHOD InsertText( nPos, cText )           INLINE ::Send( SCI_INSERTTEXT, nPos, cText)
   METHOD InvMinMay()
   METHOD IsReadOnly()                        INLINE SC_IsReadOnly( ::hWnd )
   METHOD KeyChar( nKey, nFlags )
   METHOD KeyDown( nKey, nFlags )
   METHOD LButtonDown( nRow, nCol, nKeyFlags, lTouch )
   METHOD LineFromPosition( nPos )            INLINE ::Send( SCI_LINEFROMPOSITION, nPos, 0 )
   METHOD LineLength( nLine )                 INLINE ::Send( SCI_LINELENGTH, nLine - 1, 0 )
   METHOD LineCopy()                          INLINE ::Send( SCI_LINECOPY )
   METHOD LineCut()                           INLINE ::Send( SCI_LINECUT )
   METHOD LineDelete()                        INLINE ::Send( SCI_LINEDELETE )
   METHOD LineDown()                          INLINE ::Send( SCI_LINEDOWN )
   METHOD LineDownextend()                    INLINE ::Send( SCI_LINEDOWNEXTEND )
   METHOD LineDownrectextend()                INLINE ::Send( SCI_LINEDOWNRECTEXTEND )
   METHOD LineDuplicate()                     INLINE ::Send( SCI_LINEDUPLICATE )
   METHOD LineEnd()                           INLINE ::Send( SCI_LINEEND )
   METHOD LineEnddisplay()                    INLINE ::Send( SCI_LINEENDDISPLAY )
   METHOD LineEnddisplayextend()              INLINE ::Send( SCI_LINEENDDISPLAYEXTEND )
   METHOD LineEndextend()                     INLINE ::Send( SCI_LINEENDEXTEND )
   METHOD LineEndrectextend()                 INLINE ::Send( SCI_LINEENDRECTEXTEND )
   METHOD LineEndwrap()                       INLINE ::Send( SCI_LINEENDWRAP )
   METHOD LineEndwrapextend()                 INLINE ::Send( SCI_LINEENDWRAPEXTEND )
   METHOD LinesScreen()                       INLINE ::Send( SCI_LINESONSCREEN )
   METHOD LineScrolldown()                    INLINE ::Send( SCI_LINESCROLLDOWN )
   METHOD LineScrollup()                      INLINE ::Send( SCI_LINESCROLLUP )
   METHOD LineSep()
   METHOD LineTranspose()                     INLINE ::Send( SCI_LINETRANSPOSE )
   METHOD LineUp()                            INLINE ::Send( SCI_LINEUP )
   METHOD LineUpExtend()                      INLINE ::Send( SCI_LINEUPEXTEND )
   METHOD LineUprectextend ()                 INLINE ::Send( SCI_LINEUPRECTEXTEND )
   METHOD LostFocus() INLINE ::nSelStart := ::GetSelectionStart(),;
                             ::nSelEnd := ::GetSelectionEnd(), ::Super:LostFocus()
   METHOD LowerCase()                         INLINE ::Send( SCI_LOWERCASE )
   METHOD MarkerAdd( nLine,  nMarkerNumber)   INLINE ::Send( SCI_MARKERADD, nLine, nMarkerNumber)
   METHOD MarginClick( nMargen, nPos )
   METHOD MayMin()
   METHOD MenuEdit( lPopup )
   METHOD MenuPrint( aBmps, nStyle )
   METHOD MinMay()
   METHOD MnuMargen( nRow, nCol, nKeyFlags, nMarg )
   METHOD MouseMove( nRow, nCol, nKeyFlags )
   METHOD MouseWheel( nKeys, nDelta, nXPos, nYPos )
   METHOD nCol()                              INLINE ::GetCurrentPos() - ::PositionFromLine( ::nLine() - 1 ) + 1
   METHOD NewLine()                           INLINE ::Send( SCI_NEWLINE )
   METHOD NextMarker( lVer )
   METHOD nLine()                             INLINE ::Send( SCI_LINEFROMPOSITION, ::GetCurrentPos(), 0 ) + 1
   METHOD nModColumn()
   METHOD Notify( nIdCtrl, nPtrNMHDR )
   METHOD NoImplemented()
   METHOD NumMargen( nRow, nCol, nKeyFlags )
   METHOD nPos( nNewVal )                     SETGET
   METHOD Open( oMru )
   METHOD OpenFile( cFileName, lOpen, lUtf8, lBom, lUni )
   METHOD OptionSetFont()
   METHOD Pagedown()                          INLINE ::Send( SCI_PAGEDOWN )
   METHOD Pagedownextend()                    INLINE ::Send( SCI_PAGEDOWNEXTEND )
   METHOD Pagedownrectextend()                INLINE ::Send( SCI_PAGEDOWNRECTEXTEND )
   METHOD Pageup()                            INLINE ::Send( SCI_PAGEUP )
   METHOD Pageupextend()                      INLINE ::Send( SCI_PAGEUPEXTEND )
   METHOD Pageuprectextend()                  INLINE ::Send( SCI_PAGEUPRECTEXTEND )
   METHOD Paradown()                          INLINE ::Send( SCI_PARADOWN )
   METHOD Paradownextend()                    INLINE ::Send( SCI_PARADOWNEXTEND )
   METHOD Paraup()                            INLINE ::Send( SCI_PARAUP )
   METHOD Paraupextend()                      INLINE ::Send( SCI_PARAUPEXTEND )
   METHOD Paste()                             INLINE ::Send( SCI_PASTE )
   METHOD PositionEndLine( nLine )            INLINE ::Send( SCI_GETLINEENDPOSITION, nLine, 0 )
   METHOD PositionFromLine( nLine )           INLINE ::Send( SCI_POSITIONFROMLINE, nLine, 0 )
   METHOD PrevMarker( lVer )
   METHOD Print( oFont, cDoc, lLine )
   //METHOD RButtonDown( nRow, nCol, nKeyFlags ) VIRTUAL
   METHOD Redo()                              INLINE ::Send( SCI_REDO )
   METHOD Refresh( lInit )                    INLINE ::SetUp( , lInit )
   METHOD RefreshZoom( nVar, oBtt, lPaint )
   //METHOD RegisterImage( n, pFunc )
   METHOD ReleaseDocument()                   INLINE ::Send( SCI_RELEASEDOCUMENT, 0, ::pDoc )
   METHOD ReplaceAll( cText, lForward, cWith, lAll, lAllSpaces )
   METHOD ReplaceButton( cText, lForward, cWith, lAll, lAllSpaces )
   METHOD ReplaceSel( cText )                 INLINE ::Send( SCI_REPLACESEL, 0, cText )
   METHOD Save( lBom, lUtf, lUni, lBig, lOpen )
   METHOD SayMemo( lLine )
   METHOD SearchNext( nFlags, cText )         INLINE ::Send( SCI_SEARCHNEXT, nFlags, cText )
   METHOD SearchPrev( nFlags, cText )         INLINE ::Send( SCI_SEARCHPREV, nFlags, cText )
   METHOD SelectAll()                         INLINE ::Send( SCI_SETSEL, 0, -1 )
   METHOD SelectLine( nLine )
   METHOD SelEntrePar( nTp )
   METHOD SelFont( oFont,  lUni )
   METHOD Send( nMsg, nWParam, nLParam )
   METHOD SendEditor( nMsg, wParam, lParam, lOpc )
   METHOD SendAsEmail( lAttach )
   METHOD SetAStyle( nStyle, nFore, nBack, nSize, cFace )
   METHOD SetCaretLineBack( nClr )            INLINE ::Send( SCI_SETCARETLINEBACK, nClr )
   METHOD SetColor( nClrText, nClrPane, lIni )
   METHOD SetColorCaret( nColor, lVisible )
   METHOD SetColorLimitCol( lIni )
   METHOD SetColorSelect( nClrTxt, nClrPane )
   METHOD SetColourise( lOnOff )
   METHOD SetCurrentPos( nPos )               INLINE ::Send( SCI_SETCURRENTPOS, nPos )
   METHOD SetCursor( nMode )                  INLINE ::Send( SCI_SETCURSOR, nMode, 0 )
   METHOD SetDocPointer( pDoc )               INLINE ::Send( SCI_SETDOCPOINTER, 0, pDoc )
   METHOD SetEOL( lOn )
   METHOD SetFixedFont()
   METHOD SetFocus()                          INLINE SetFocus( ::hWnd )  //::Send( SCI_SETFOCUS,1, 0 )
   METHOD SetFmtCode()
   METHOD SetFont( oFont, lIni )
   METHOD SetGetAnota( lChange )
   METHOD SetHighlightColors()
   METHOD SetIndent( lOn )
   METHOD SetIndicators()
   METHOD SetKeyWords( nKeys, cKeys )
   METHOD SetLineIndentation( nLine, nIndentation ) INLINE ;
                         ::Send( SCI_SETLINEINDENTATION, nLine, nIndentation )
   METHOD SetMargin( lOn )
   METHOD SetMBrace()
   METHOD SetMIndent( nSp )
   METHOD SetOldPos()                         INLINE ( ::nOldPos := ::GetCurrentPos() )
   METHOD SetReadOnly( lOn )                  INLINE ::Send( SCI_SETREADONLY, If( lOn, 1, 0 ), 0 )
   METHOD SetSavePoint()                      INLINE ::Send( SCI_SETSAVEPOINT, 0, 0 )
   METHOD SetSel( nStart, nEnd )              INLINE ::Send( SCI_SETSEL, nStart, nEnd )
   METHOD SetTargetEnd( nPos )                INLINE ::Send( SCI_SETTARGETEND, nPos, 0 )
   METHOD SetTargetFromSelection()            INLINE ::Send( SCI_TARGETFROMSELECTION, 0, 0 )
   METHOD SetTargetStart( nPos )              INLINE ::Send( SCI_SETTARGETSTART, nPos, 0 )
   METHOD SetTargetRange( nStart, nEnd )      INLINE ::Send( SCI_SETTARGETRANGE, nStart, nEnd )
   METHOD SetTargetWholeDocument()            INLINE ::Send( SCI_TARGETWHOLEDOCUMENT, 0, 0 )
   METHOD SetText( cText )                    INLINE ::Send( SCI_SETTEXT, 0, cText )
   METHOD SetTipCaret( nT )                   INLINE ::Send( SCI_SETCARETSTYLE, nT, 0 )
   METHOD SetToggleMark( nL, nAdd, nColor )
   METHOD SetUndoCollection()                 INLINE ::Send( SCI_SETUNDOCOLLECTION )
   METHOD SetUniCode()                        INLINE ::Send( SCI_SETCODEPAGE, SC_CP_UTF8, 0 )
   METHOD SetUp( nMark, lInit )
   METHOD SetUseTabs( lOnOff )                INLINE ::Send( SCI_SETUSETABS, If( lOnOff, 1, 0 ) )
   METHOD SetViewSpace( lOn )
   METHOD SetWidthCursor( nWidth )            INLINE ::Send( SCI_SETCARETWIDTH, nWidth, 0 )
   METHOD SetZoomBar( nZ )
   METHOD StartMacro()                        INLINE ::Send( SCI_STARTRECORD,,) 
   METHOD StopMacro()                         INLINE ::Send( SCI_STOPRECORD,,) 
   METHOD Stutteredpagedown()                 INLINE ::Send( SCI_STUTTEREDPAGEDOWN )
   METHOD StutteredpagedownextenD()           INLINE ::Send( SCI_STUTTEREDPAGEDOWNEXTEND )
   METHOD Stutteredpageup()                   INLINE ::Send( SCI_STUTTEREDPAGEUP )
   METHOD Stutteredpageupextend ()            INLINE ::Send( SCI_STUTTEREDPAGEUPEXTEND )
   METHOD StyleSet( nStyle )                  INLINE ( ::nSetStyle := nStyle )
   METHOD StyleSetBold( lBold )               INLINE ::Send( SCI_STYLESETBOLD,;
                                                 ::nSetStyle, If( lBold, 1, 0 ) )
   METHOD StyleSetColor( nClrFore, nClrBack ) INLINE (IF( Valtype( nClrFore ) == 'N',;
                                ::Send( SCI_STYLESETFORE, ::nSetStyle, nClrFore ),),;
                                If( Valtype( nClrBack ) == 'N',;
                                    ::Send( SCI_STYLESETBACK, ::nSetStyle, nClrBack ),), 0 )
   METHOD StyleSetFont( cFontName )          INLINE ::Send( SCI_STYLESETFONT, ::nSetStyle, cFontName )
   METHOD StyleSetItalic( lItalic )          INLINE ::Send( SCI_STYLESETITALIC,;
                                                 ::nSetStyle, If( lItalic, 1, 0 ) )
   METHOD StyleSetSize( nSize )                 INLINE ::Send( SCI_STYLESETSIZE, ::nSetStyle, nSize )
   METHOD StyleSetUnderline( lUnderline ) INLINE ::Send( SCI_STYLESETUNDERLINE,;
                                                 ::nSetStyle, if( lUnderline, 1, 0 ) )
   METHOD SysCommand( nType, nLoWord, nHiWord )
   METHOD Tab()                               INLINE ::Send( SCI_TAB )
   METHOD TexttoArray( cText, cDelim, lSelec, lWord, lSort )
   METHOD TipoMonitor()
   METHOD TipShow( cChar, nLine, nMod )
   METHOD Undo()                              INLINE ::Send( SCI_UNDO )
   METHOD UpdateUI()
   METHOD Uppercase()                         INLINE ::Send( SCI_UPPERCASE )
   METHOD Vchome()                            INLINE ::Send( SCI_VCHOME )
   METHOD Vchomeextend()                      INLINE ::Send( SCI_VCHOMEEXTEND )
   METHOD Vchomerectextend()                  INLINE ::Send( SCI_VCHOMERECTEXTEND )
   METHOD Vchomewrap()                        INLINE ::Send( SCI_VCHOMEWRAP )
   METHOD Vchomewrapextend()                  INLINE ::Send( SCI_VCHOMEWRAPEXTEND )
   METHOD Wordleft()                          INLINE ::Send( SCI_WORDLEFT )
   METHOD Wordleftend()                       INLINE ::Send( SCI_WORDLEFTEND )
   METHOD Wordleftendextend()                 INLINE ::Send( SCI_WORDLEFTENDEXTEND )
   METHOD Wordleftextend()                    INLINE ::Send( SCI_WORDLEFTEXTEND )
   METHOD Wordpartleft()                      INLINE ::Send( SCI_WORDPARTLEFT )
   METHOD Wordpartleftextend()                INLINE ::Send( SCI_WORDPARTLEFTEXTEND )
   METHOD Wordpartright()                     INLINE ::Send( SCI_WORDPARTRIGHT )
   METHOD Wordpartrightextend()               INLINE ::Send( SCI_WORDPARTRIGHTEXTEND )
   METHOD Wordright()                         INLINE ::Send( SCI_WORDRIGHT )
   METHOD Wordrightend()                      INLINE ::Send( SCI_WORDRIGHTEND )
   METHOD Wordrightendextend()                INLINE ::Send( SCI_WORDRIGHTENDEXTEND )
   METHOD Wordrightextend()                   INLINE ::Send( SCI_WORDRIGHTEXTEND )
   METHOD ValidChar( c ) INLINE  Lower( c ) $ "abcdefghijklmnopqrstuvwxyz1234567890Ã±"

ENDCLASS

//----------------------------------------------------------------------------//

METHOD AutoIndent() CLASS TScintilla

   local nPos         := ::GetCurrentPos()
   local nPrevLine    := ::GetCurrentLineNumber() - 1
   local nIndentation := ::Send( SCI_GETLINEINDENTATION, nPrevLine, 0 )

   ::Send( SCI_SETLINEINDENTATION, nPrevLine + 1, nIndentation )
   ::Send( SCI_GOTOPOS, nPos + nIndentation )

return ( nPos + nIndentation )

//----------------------------------------------------------------------------//

METHOD BookmarkClearAll( nM ) CLASS TScintilla

   DEFAULT nM      := 1    //::nMarker
   ::Send( SCI_MARKERDELETEALL, nM )
   if nM = 1
      ::aBookMarker   := {}
      ::aMarkerHand   := {}
   endif
   if nM < 0 .or. nM = 2
      ::aPointBreak   := {}
   endif

return nil

//----------------------------------------------------------------------------//

METHOD GotoLineEnsureVisible( nextline )  CLASS TScintilla

   ::Send( SCI_ENSUREVISIBLEENFORCEPOLICY, nextline )
   ::Send( SCI_GOTOLINE, nextline )

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

METHOD SetIndent( lOn ) CLASS TScintilla

   DEFAULT lOn := If( ::Send( SCI_GETINDENTATIONGUIDES, 0, 0 ) == 0, .T., .F. )

   if lOn
      ::Send( SCI_SETINDENTATIONGUIDES, SC_IV_LOOKBOTH )
   else
      ::Send( SCI_SETINDENTATIONGUIDES, SC_IV_NONE )
   endif

return nil

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

METHOD SetEOL( lOn ) CLASS TScintilla

   DEFAULT lOn := If( ::Send( SCI_GETVIEWEOL ) == 0, .T., .F. )

   if lOn
      ::Send( SCI_SETVIEWEOL, 1 )
   else
      ::Send( SCI_SETVIEWEOL, 0 )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD Send( nMsg, nWParam, nLParam ) CLASS TScintilla

   local nRet

   DEFAULT nWParam := 0
   DEFAULT nLParam := 0

   if !::lPtr
      //nRet  = ::Super:SendMsg( nMsg, nWParam, nLParam )
      nRet  := ::SendEditor( nMsg, nWParam, nLParam, .T. )
   else
      nRet  := ::SendEditor( nMsg, nWParam, nLParam, )
   endif
   
return nRet

//----------------------------------------------------------------------------//

METHOD SendEditor( nMsg, wParam, lParam, lOpc ) CLASS TScintilla
   
   DEFAULT wParam  := 0
   DEFAULT lParam  := 0
   DEFAULT lOpc    := .F.

Return SendMessage( if( lOpc, ::hWnd, ::hPtr ), nMsg, wParam, lParam )

//----------------------------------------------------------------------------//

METHOD End( nPos ) CLASS TScintilla

   DEFAULT nPos   := 0

   ::Send( SCI_CLEARREGISTEREDIMAGES, 0, 0 )
   ::CloseF( .T. )

   ::nInst--
   if ::nInst <= 0 //.or. nPos < 1
      if !Empty( ::hLib ) .or. ::hLib != Nil
         TRY
            FreeLibrary( ::hLib )
            ::hLib   := Nil
         CATCH
            MsgInfo( "No se puede cerrar la DLL", "Error" )
         END
      else
         ::nInst--
      endif
   else
      ::nInst--
   endif
   if !Empty( ::oFntEdt ) .and. ::oFntEdt:nCount > 0
      ::oFntEdt:End()
   endif
   if !Empty( ::oFntLin ) .and. ::oFntLin:nCount > 0
      ::oFntLin:End()
      ::oFntLin   := Nil
   endif

return ::Super:End()

//----------------------------------------------------------------------------//

METHOD nPos( nNewVal ) CLASS TScintilla

   if PCount() > 0
      ::GotoPos( nNewVal )
   endif

return ::GetCurrentPos()

//----------------------------------------------------------------------------//

METHOD New( nRow, nCol, nWidth, nHeight, oWnd, nClrT, nClrP, cLex, cDll, bSetup, lLoad, cPathApli ) CLASS TScintilla
   
   DEFAULT nRow    := 0
   DEFAULT nCol    := 0
   DEFAULT nWidth  := 100
   DEFAULT nHeight := 100
   DEFAULT oWnd    := GetWndDefault()
   DEFAULT nClrT   := CLR_BLUE
   DEFAULT nClrP   := RGB( 160, 160, 160 )
   DEFAULT cLex    := 0   //SCLEX_FLAGSHIP
   DEFAULT cDll    := if( IsExe64(), "SciLex64.Dll", "SciLexer.DLL" )
   DEFAULT bSetup  := { || .T. }
   DEFAULT lLoad   := .T.
   DEFAULT cPathApli := ".\"
   
   if Empty( cDLL )
      if ! IsExe64()
         cDLL = cPathApli + "SciLexer.dll"
      else
         cDLL = cPathApli + "SciLex64.dll"
      endif
   endif
   if IsExe64()
      if "scilexer.dll" $ Lower( cDll )
         cDll := cPathApli + "SciLex64.Dll"
      endif
   else
      if "scilex64.dll" $ Lower( cDll )
         cDll := cPathApli + "SciLexer.dll"
      endif
   endif
   ::lUniCode := FW_SetUnicode()
   ::nTop     := nRow
   ::nLeft    := nCol
   ::nBottom  := nRow + nHeight
   ::nRight   := nCol + nWidth
   ::oWnd     := oWnd
   //::nStyle   = nOR( WS_CHILD, WS_VISIBLE, WS_TABSTOP, WS_BORDER, WS_VSCROLL, WS_HSCROLL  )
   ::nStyle   := nOR( WS_CHILD, WS_VISIBLE, WS_TABSTOP, WS_VSCROLL, WS_HSCROLL  )
   ::nId      := ::GetNewId()
   ::nClrPane := nClrP
   ::nClrText := nClrT
   ::cLexer   := cLex
   ::bSetup   := bSetup
   ::TipoMonitor()

   ::cCComment     := { CLR_GRAY, ::nClrPane, SC_CASE_MIXED, }    //HGRAY
   ::cCCommentLin  := { CLR_GRAY, ::nClrPane, SC_CASE_MIXED, }
   ::cCString      := { CLR_HRED, ::nClrPane, SC_CASE_MIXED, }
   ::cCNumber      := { CLR_RED, ::nClrPane, SC_CASE_MIXED, }
   ::cCOperator    := { CLR_BLUE, ::nClrPane, SC_CASE_MIXED, }
   ::cCBraces      := { CLR_BLUE, CLR_YELLOW, SC_CASE_MIXED, }
   ::cCBraceBad    := { CLR_HRED, CLR_YELLOW, SC_CASE_MIXED, }
   ::cCIdentif     := { CLR_GREEN, ::nClrPane, SC_CASE_MIXED, }    //MAGENTA
   ::cCKeyw1       := { METRO_ORANGE, ::nClrPane, SC_CASE_MIXED, } //CYAN
   ::cCKeyw2       := { METRO_ORANGE, ::nClrPane, SC_CASE_MIXED, } // METRO_BROWN
   ::cCKeyw3       := { METRO_BROWN, ::nClrPane, SC_CASE_MIXED, }  // CLR_BLUE
   ::cCKeyw4       := { CLR_BLUE, ::nClrPane, SC_CASE_MIXED, }     //METRO_CYAN
   ::cCKeyw5       := { METRO_CYAN, ::nClrPane, SC_CASE_MIXED, }   //METRO_MAUVE   // STEEL
   
   if ::nInst = 0
      if lLoad
         ::hLib := LoadLibrary( cDll )
         ::nInst ++
      endif
   else
      ::nInst ++      
   endif
   
   if ! Empty( oWnd:hWnd )
      ::Create( "Scintilla" )
      ::Default()
      oWnd:AddControl( Self )
   else
      oWnd:DefControl( Self )
   endif
   ::lMargLin    := .F.
   ::lMarking    := .F.
   ::lFolding    := .F.
   ::lMessage    := .F.
   ::lMargRun    := .F.
   ::bTxtMarg    := { || "" }
   if Empty( cLex )
      ::lFolding  := .F.
      ::nMargFold := 0
   endif
   //? GetClassInfoW( GetInstance(), ::ClassName() )   
return Self

//----------------------------------------------------------------------------//

METHOD InitEdt() CLASS TScintilla

   /*
   local nSizeF   := -9
   local aFont    :=  { "Lucida Console", "FixedSys" }
   local aFont1   :=  { "Segoe UI Mono", "Fixedsys" }
   
   if !Empty( ::oFont ) 
      nSizeF  := ::oFont:nHeight
   endif
   if Empty( ::oFntLin )
      if !Empty( At( "WINDOWS 8", Upper( Os() ) ) )
         DEFINE FONT ::oFntLin NAME aFont1[ 1 ] SIZE 0, nSizeF //- ::nTpMonitor
      else
         DEFINE FONT ::oFntLin NAME aFont1[ 2 ] SIZE 0, nSizeF //- ::nTpMonitor
      endif
   endif
   */
   
   ::nMargLeft     := 4
   ::nMargRight    := 4
   ::nSpacLin      := 2
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

Return nil

//----------------------------------------------------------------------------//

METHOD CalcWidthMargin() CLASS TScintilla

   if ::lMargLin
      ::nMargLines  := IF( Empty( ::nMargLines ), 56, ::nMargLines )
   else
      ::nMargLines  := 0
   endif
   if ::lMarking
      ::nMargSymbol := IF( Empty( ::nMargSymbol ), 22, ::nMargSymbol )
   else
      ::nMargSymbol := 0
   endif
   if ::lFolding
      ::nMargFold   := IF( Empty( ::nMargFold ), 22, ::nMargFold )
   else
      ::nMargFold   := 0
   endif

   if ::lMessage
      if !Empty( Eval( ::bTxtMarg, Self ) )
         if Valtype( Eval( ::bTxtMarg, Self ) ) = "C"
            ::nMargText   := Max( ::nMargText, ;
                               ( Len( Eval( ::bTxtMarg, Self ) ) + 2 ) * 7 )
         else
            ::nMargText   := Max( ::nMargText, ;
                                Len( Str( Eval( ::bTxtMarg, Self ) ) ) + 2 )
         endif
      endif
   endif
   if ::lMargRun
      ::nMargBuild  := IF( Empty( ::nMargBuild ), 22, ::nMargBuild )
   else
      ::nMargBuild  := 0
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD GetCaretInLine() CLASS TScintilla

   local nCaret     := ::GetCurrentPos()
   local nLine      := ::LineFromPosition( nCaret )
   local nLineStart := ::PositionFromLine( nLine )

RETURN nCaret - nLineStart

//----------------------------------------------------------------------------//

METHOD GetCurLine() CLASS TScintilla

   local nLine := ::GetCurrentLineNumber()
   local cText := ::GetLine( nLine + 1 )

RETURN cText

//----------------------------------------------------------------------------//

METHOD Open( oMru ) CLASS TScintilla

   local lSw       := .F.
   local aVals     := { 0, 1, 2, 1001 }
   local nPos
   local aStatus   := { ;
                      { "0 No failures" }, ;  //SC_STATUS_OK
                      { "1 Generic failure" }, ; //SC_STATUS_FAILURE
                      { "2 Memory is exhausted" } ,; //SC_STATUS_BADALLOC
                      { "1001 Regular expression is invalid" } ; //SC_STATUS_WARN_REGEX
                      }
   local cFileName := cGetFile32( "Program file (*.prg) |*.prg|" + ;
                           "Header file (*.ch) |*.ch|" + ;
                           "Headers (*.h) |*.h|" + ;
                           "Resources (*.rc) |*.rc|" + ;
                           "Source Code C (*.c) |*.c|" + ;
                           "Source Code C++ (*.cpp) |*.cpp|" + ;
                           "C File (*.cxx) |*.cxx|" + ;
                           "Harbour files (*.hrb) |*.hrb|" + ;
                           "Templates (*.pvk) |*.pvk|" + ;
                           "Text file (*.txt) |*.txt|" + ;
                           "Configuration file (*.ini) |*.ini|" + ;
                           "XML file (*.xml) |*.xml|" + ;
                           "Open any file (*.*) |*.*|",;
                           "Select a file to open" )
   if File( cFileName )
      ::OpenFile( cFileName )
      ::oWnd:cTitle = cFileName
      if oMru != nil .and. ValType( oMru ) == "O"
         oMru:Save( cFileName )
      endif
      lSw  := .T.
   endif
   if ::Send( SCI_GETSTATUS, 0, 0 ) <> 0
      if !Empty( nPos := Ascan( aVals, ::Send( SCI_GETSTATUS, 0, 0 ) ) )
         MsgInfo( "Status Editor: " + aStatus[ nPos ], "Attention:" )
      endif
      lSw    := .F.
   endif

return lSw

//----------------------------------------------------------------------------//

METHOD FindText( cText, lForward ) CLASS TScintilla

   local   lSw
   DEFAULT lForward := .T.

   ::cLastFind := cText
   if lForward
      lSw := SearchForward( ::hWnd, cText, ::uFlagFind )
   else
      lSw := SearchBackward( ::hWnd, cText, ::uFlagFind )
   endif

return lSw

//----------------------------------------------------------------------------//

METHOD FindToken( nPos ) CLASS TScintilla

   local cLine    := ::GetCurLine()
   local nCurrent := ::GetCaretInLine()
   local nStart
   local cOut
   local cWord
   DEFAULT nPos   := 0
   
   /*
   if nPos < 0
      nPos := - Len( ::cWritten ) + nPos
      FWLOG Valtype( ::cFoundToken ), ::cWritten, nPos, nCurrent
      //if Valtype( ::cFoundToken ) = "C"
      //   FWLOG Len( ::cFoundToken )
      //   nCurrent       += ( - Len( ::cFoundToken ) + nPos )
      //else
   */
         nCurrent       += nPos
   /*
      //endif
   endif
   */
   
   nStart         := nCurrent
   While ( nStart > 0 .AND. ::ValidChar( SubStr( cLine, nStart, 1 ) ) )
      nStart--
   Enddo
   if nStart != nCurrent .OR. nStart == 0 .or. nPos < 0
      cWord := AllTrim( SubStr( cLine, nStart + 1, nCurrent - nStart ) )
      if ! Empty( cWord ) //.and. Len( cWord ) > 1
         cOut := FindAutocomplete( ::hWnd, AllTrim( cWord ) )
      endif
   endif
return cOut

//----------------------------------------------------------------------------//

METHOD Save( lBom, lUtf, lUni, lBig, lOpen ) CLASS TScintilla

   local hMani
   local cFile
   local cCad
   local lYes
   local cCad1    := Chr( 239 ) + Chr( 187 ) + Chr( 191 )
   local cCad2    := Chr( 255 ) + Chr( 254 )
   local cCad3    := Chr( 254 ) + Chr( 255 )

   DEFAULT lBom   := ::lBom
   DEFAULT lUtf   := ::lUTF8
   DEFAULT lUni   := ::lUtf16
   DEFAULT lBig   := ::lBig
   DEFAULT lOpen  := .T.

   if Empty( ::cFileName )
      cFile = cGetFile32( , FWString("Save as"), 0, ;
                          hb_CurDrive() + ":\" + CurDir(), .T., .T. )
      ::cFileName := cFile
   endif

   cCad    := ::GetText()

   if !lBom .and. Left( cCad, 3 ) == cCad1
      cCad  := Right( cCad, Len( cCad ) - 3 )
   endif
   if lBom .and. Left( cCad, 3 ) <> cCad1
      cCad  := cCad1 + cCad
   else
      if lUni
         if Left( cCad, 2 ) <> cCad2 .and. Left( cCad, 2 ) <> cCad3
            if !lBig
               cCad  := cCad2 + cCad
            else
               cCad  := cCad3 + cCad
            endif
         endif
      endif
   endif

   if File( ::cFileName )
      //if MsgYesNo( "File already exist", "Overwrite" )
         lYes  := .T.
      //endif
      if ::lSaveBak
         if File( ::cFileName + ".BAK" )
            // Posibilidad de crear historial de cambio aÃ±adiendo fecha+hora
            // FRename( ::cFileName, cFileBak ) // Entonces no borrar ni comprobar
            FErase( ::cFileName + ".BAK" )
         endif
         FRename( ::cFileName, Lower( ::cFileName + ".BAK" ) )
      endif
   else
      lYes   := .T.
   endif

   if lYes
      hMani   := Fcreate( ::cFileName )
      FWrite( hMani, cCad )
      FClose( hMani )
      ::oWnd:cTitle = ::cFileName

      ::SetSavePoint()
   endif
   
return lYes

//----------------------------------------------------------------------------//

METHOD OpenFile( cFileName, lOpen, lUtf8, lBom, lUni ) CLASS TScintilla

   local cStr        := ""
   local cCad1    := Chr( 239 ) + Chr( 187 ) + Chr( 191 )

   DEFAULT lOpen     := .T.
   DEFAULT lUtf8     := .F.
   DEFAULT lBom      := .F.
   DEFAULT lUni      := .F.

   if !Empty( cFileName )
      if File( cFileName ) .and. lOpen
         cStr := MemoRead( cFileName )
         ::DocIsUtf8( cStr, lUtf8 )
         if ::lUtf8
            if ::GetUniCode()
               ::SetUniCode()
               ::cLang   := 1
               if !Empty( ::cFontInfoU )
                  ::SetFont( ::oFont := FontFromText( ::cFontInfoU, .T. ), .T. ) // SetMiFont( ::cFontInfoU ), .T. )  //.F.
                  //::oFont:nHeight  -= ::nTpMonitor
               endif
               ::SetColor( ,, .F. )
            endif
         endif
         if !::lUtf16
            if ::lUtf8
               if Left( cStr, 3 ) == cCad1 .and. !::lBom
                  cStr := Right( cStr, Len( cStr ) - 3 )
               endif
            endif
            ::SetText( cStr )
         else
            ::SetText( Utf16toUtf8( cStr ) )
         endif

         // Y ahora quÃ©? Ponemos los valores por defecto?
         /*
         if lUtf8 .and. !::lUtf8
            ::lUtf8  := lUtf8
            if lBom .and. !::lBom
               ::lBom   := lBom
            endif
         else
            if lUni .and. !::lUtf16
               ::lUtf16 := lUni
               ::lBom   := .T.
            endif
         endif
         */

         ::cFilename = cFileName
         if AScan( ::aMrus, cFileName ) == 0 .and. !Empty( cFileName )
            AAdd( ::aMrus, cFileName )
         endif
      else

      endif
   else
      ::cFileName := ""
   endif
   ::Send( SCI_EMPTYUNDOBUFFER, 0, 0 )
   ::SetSavePoint()

return cStr

//----------------------------------------------------------------------------//

METHOD GetTextRange( nLin0, nCol0, nLin1, nCol1 ) CLASS TScintilla

   DEFAULT nLin0 := 1
   DEFAULT nCol0 := 1
   DEFAULT nLin1 := -1
   DEFAULT nCol1 := -1

// Method not defined Â¿?
return ::SC_GetTextRange( ::hWnd, nLin0, nCol0, nLin1, nCol1 )

//----------------------------------------------------------------------------//

#define CFACENAME 14
#define ALTURA    1
#define BOLD      5
#define ITALIC    6
#define UNDERLINE 7

//----------------------------------------------------------------------------//

METHOD OptionSetFont() CLASS TScintilla

   local oFont
   local lSw    := .T.

   DEFINE FONT oFont FROM USER

   if Abs( oFont:nInpHeight ) < 5
      lSw := .F.
   endif
   if lSw
   ::StyleSetFont( ::GetCurrentStyle(), oFont:cFaceName )
   ::StyleSetSize( ::GetCurrentStyle(), Abs( oFont:nSize ) ) //+ ::nTpMonitor )
   ::StyleSetBold( ::GetCurrentStyle(), oFont:lBold  )
   ::StyleSetItalic( ::GetCurrentStyle(), oFont:lItalic )
   ::StyleSetUnderline( ::GetCurrentStyle(), oFont:lUnderline )
   endif

   oFont:End()

return nil

//----------------------------------------------------------------------------//

METHOD GetCurrentStyle() CLASS TScintilla

   local nPos := ::Send( SCI_GETCURRENTPOS, 0, 0 )

return ::Send( SCI_GETSTYLEAT, nPos, 0 )

//----------------------------------------------------------------------------//

METHOD Print( oFont, cDoc, lLine ) CLASS TScintilla

   local o      := Self
   DEFAULT cDoc := "Text File Printout"
   if Empty( oFont )
      DEFINE FONT oFont NAME "Lucida Console" SIZE 0,-11   //-12
   endif
   REPORT oReport ;
          FONT oFont ;
          PREVIEW ;
          CAPTION cDoc      //;          TO PRINTER

   COLUMN DATA " " SIZE 76
   END REPORT

   oReport:nTitleUpLine = RPT_NOLINE
   oReport:nTitleDnLine = RPT_NOLINE
   oReport:Margin( .15, RPT_LEFT, RPT_INCHES)
   oReport:Margin( .25, RPT_TOP, RPT_INCHES)
   oReport:Margin( .25, RPT_BOTTOM, RPT_INCHES)

   ACTIVATE REPORT oReport ON INIT o:SayMemo( lLine )

   oFont:End()

return nil

//----------------------------------------------------------------------------//

METHOD SayMemo( lLine ) CLASS TScintilla

   local cText
   local cLine
   local nFor
   local nLines
   local nPageln

   DEFAULT lLine   := .T.

   cText   := ::GetText()
   nLines  := ::GetLineCount()
   nPageln := 0
   // oReport:BackLine(1)

   For nFor := 1 TO nLines

      cLine := ::GetLine( nFor )
      cLine := substr( cLine, 1, len( cLine ) -2 )
      cLine := strtran( cLine, chr(9),"   " )
      if lLine
         cLine := strtran( Str(nFor,5)," ","0") + "  " + cLine
      endif
      oReport:StartLine()
      oReport:Say( 1, cLine )
      oReport:EndLine()
      nPageln := nPageln + 1
      if nPageln = 60
         nFor := GetTop( cText, nFor, nLines )
         nPageln := 0
      endif

   Next

   // oReport:Newline()  // Only activate this line if you need to have the
                         // program eject another page upon completing printing.
return nil

//----------------------------------------------------------------------------//

static function GetTop( cText, nFor, nLines )

   local lTest := .T.
   local cLine

   while lTest .and. nFor <= nLines
      nFor   := nFor + 1
      cLine  := MemoLine( cText, 76, nFor )
      lTest  := Empty(cLine)
   end

   nFor = nFor - 1
   SysRefresh()   // Inserted to allow Windows to catch up with housekeeping
                  // that was held up during the "DO WHILE."
return nFor

//----------------------------------------------------------------------------//

METHOD CloseF( lEnd ) CLASS TScintilla

   DEFAULT lEnd   := .F.
   //if !Empty( ::GetText() ) .and. Len( ::GetText() ) > 4
      if ::lModified   //::GetModify()
         if MsgYesNo( FWString( "File has changed" )  + ": " + CRLF + CRLF + ;
                   Upper( ::cFileName ), ;
                   FWString( "Save the changes ?" ) )
            ::Save()
         endif
      endif

   //endif
   if ::nViews > 0
      ::nViews--
   endif
   if Valtype( lEnd ) = "N"
      ::SetText( "" )
      ::cFileName = ""
      ::SetSavePoint()
   else
      ::SetText( "" )
      ::cFileName = ""
      ::SetSavePoint()
   endif

return nil

//----------------------------------------------------------------------------//

METHOD DlgFindText( nR, nC, lDlg ) CLASS TScintilla

   local oDlg
   local oGet
   local lForward  := .T.
   local lSpacesL  := .T.
   local oBtnOk
   local cText     := ::GetSelText()
   local oThis     := Self
   local oFontF
   local cFontF    := "Verdana"
   local lMay      := .F.
   local lWord     := .F.
   local lPrev     := .F.
   local oProj
   local lProj     := .F.
   local oFOpen
   local lFOpen    := .F.
   local oFichs
   local lFichs    := .F.
   local lFold     := .F.
   local cSubd     := Space( 100 )
   local cCbxTipo  := "*.prg"
   local aCbxTipo  := { "*.prg", "*.ch", "*.h", "*.c", "*.cpp", "*.rc", "*.*" }
   local cFind

   DEFAULT lDlg    := .T.

   ( nR, nC )

   if Empty( cText )
      cText := If( Empty( ::cLastFind ), "", ::cLastFind )
   endif

   if MLcount( cText ) > 1
      cText := Trim( MemoLine( cText,, 1 ) )
   endif

   ::uFlagFind   := 0
   cText         := PadR( cText, 240 )
   cFind         := cText
   ::SetOldPos()

   if lDlg

   DEFINE FONT oFontF NAME cFontF SIZE 0, -11

   DEFINE DIALOG oDlg TITLE FWString( "Find" ) OF Self ;
    SIZE 315, 325 ;
    COLOR CLR_BLUE, CLR_WHITE FONT oFontF
   
   oDlg:lHelpIcon := .F.
   
   @ 2, 5 SAY "Text to Serch" + ":" OF oDlg PIXEL

   @ 14, 5 GET oGet VAR cText OF oDlg SIZE 145, 12 COLORS CLR_BLUE, CLR_WHITE PIXEL ;
      VALID ( cText := if( lSpacesL, Alltrim( cText ), RTrim( cText ) ), .T. )
      
   oGet:bGotFocus  := { || cText := PadR( cText, 240 ), oGet:Refresh() }

   @ 30, 5 COMBOBOX cFind ITEMS ::aHistFind OF oDlg ;
          SIZE 145, 140 PIXEL ;
          ON CHANGE ( Self, cText := if( lSpacesL, Alltrim( cFind ), RTrim( cFind ) ),;
                      oGet:Refresh() )

   @ 44, 5 CHECKBOX lForward PROMPT FWString( "Forward" ) ;
      OF oDlg SIZE 70, 15 PIXEL

   @ 44, 80 CHECKBOX lSpacesL PROMPT "Del Left Spaces " ;
      OF oDlg SIZE 70, 15 PIXEL
   //@ 2.5, 2.2 CHECKBOX lBack PROMPT FWString( "Back" ) ;

   @ 56, 5 CHECKBOX ::lIndicators PROMPT "Marks Indicators " ;
      OF oDlg SIZE 70, 15 PIXEL

   @ 56, 80 CHECKBOX lMay PROMPT "Match Upper/Lower " ;
      OF oDlg SIZE 70, 15 PIXEL ;
      ON CHANGE (::uFlagFind := nOr(::uFlagFind,if(lMay,SCFIND_MATCHCASE,0)))

   @ 68, 5 CHECKBOX lPrev PROMPT "Top Word " ;
      OF oDlg SIZE 70, 14 PIXEL ;
      ON CHANGE (::uFlagFind := nOr(::uFlagFind,if(lPrev,SCFIND_WORDSTART,0)))

   @ 68, 80 CHECKBOX lWord PROMPT "Word Complete " ;
      OF oDlg SIZE 70, 14 PIXEL ;
      ON CHANGE (::uFlagFind := nOr(::uFlagFind,if(lWord,SCFIND_WHOLEWORD,0)))

   @ 88, 5 SAY "Search in Files" + ":" OF oDlg PIXEL SIZE 60, 10
   
   @ 86, 80 COMBOBOX cCbxTipo ; // ON CHANGE ( oThis:lChangeCom := .T. ) ;
      OF oDlg SIZE 60, 10 PIXEL ;
      WHEN ( lProj .or. lFOpen .or. lFichs ) ;
      ITEMS aCbxTipo

   @ 98, 5 CHECKBOX oProj VAR lProj PROMPT "Project Active" ;
      OF oDlg SIZE 70, 14 PIXEL ;
      ON CHANGE ( lFichs := if( lFichs, if( lProj, .F., lFichs ), lFichs ), ;
                  lFOpen := if( lProj, .F., lFOpen ),;
                  oFichs:Refresh(), oFOpen:Refresh() )

   @ 98, 80 CHECKBOX oFOpen VAR lFOpen PROMPT "All Files Open" ;
      OF oDlg SIZE 70, 14 PIXEL ;
      ON CHANGE ( lFichs := if( lFichs, if( lFOpen, .F., lFichs ), lFichs ), ;
                  lProj  := if( lFOpen, .F., lProj ), ;
                  oFichs:Refresh(), oProj:Refresh() )

   @ 110, 5 CHECKBOX oFichs VAR lFichs PROMPT "Select Path" ;
      OF oDlg SIZE 70, 15 PIXEL ;
      ON CHANGE ( lProj := if( lProj, if( lFichs, .F., lProj ), lProj ), ;
                  lFOpen := if( lFOpen, if( lFichs, .F., lFOpen ), lFOpen ), ;
                  oProj:Refresh(), oFOpen:Refresh() )

   @ 110, 80 CHECKBOX lFold PROMPT "Recursive in Foders" ;
      OF oDlg SIZE 70, 15 PIXEL WHEN lFichs

   @ 128, 5 GET cSubd OF oDlg SIZE 145, 12 ;
      COLORS CLR_BLUE, CLR_WHITE PIXEL ;
      ACTION ( Self, cSubd := cGetDir( "Select Folder", CurDir() ) ) ;
      WHEN lFichs

   @ 146, 5 BUTTON oBtnOk PROMPT "&Ok" DEFAULT OF oDlg SIZE 45, 12 ;
      ACTION ( if( !Empty( cText ), ;
                ( if( Empty( Ascan( ::aHistFind, cText ) ), ;
                      AAdd( ::aHistFind, cText ), ), ;
                if( !lProj .and. !lFOpen .and. !lFichs, ;
                 if( !::FindButton( cText, lForward, lSpacesL, oBtnOk ), ;
                    oDlg:End(), ),;
                 ( Eval( ::bSearch, cText, lProj, lFOpen, lFichs, lFold, cSubd, cCbxTipo, lMay ) ) )) ,;
                  ( MsgInfo("Attention","String is Empty") ) ), oDlg:End() ) PIXEL
               //oDlg:End() ) )), ( MsgInfo("Attention","String is Empty"), oDlg:End() ) ) ) PIXEL

   @ 146, 105 BUTTON FWString( "&Cancel" ) OF oDlg SIZE 45, 12 ;
      ACTION ( ::nSelStart := ::GetSelectionStart(),;
               ::nSelEnd := ::GetSelectionEnd(),;
               oDlg:End() ) PIXEL

   ACTIVATE DIALOG oDlg CENTERED IN PARENT NOWAIT ;
      VALID ( Self,;
              oThis:nSelStart := oThis:GetSelectionStart(),;
              oThis:nSelEnd := oThis:GetSelectionEnd(), ;
              oFontF:End(), .T. )

   else
      if !Empty( cText )
         if Empty( Ascan( ::aHistFind, cText ) )
            AAdd( ::aHistFind, cText )
         endif
         ::FindButton( cText, lForward, lSpacesL, )
      endif
   endif

return nil

//----------------------------------------------------------------------------//

METHOD FindButton( cText, lForward, lSpacesL, oBtn ) CLASS TScintilla

   local lSw
   DEFAULT lForward  := .T.

   ( lSpacesL )

   cText  := AllTrim( cText )
   lSw    := ::FindText( cText, lForward )

   If !lSw
      ::nSelStart  := ::GetSelectionStart()
      ::nSelEnd    := ::GetSelectionEnd()
      MsgInfo( "Not Found", cText )
   else
      if !Empty( oBtn )
         oBtn:SetText( FWString( "&Next" ) )
      endif
      if ::lIndicators
         ::HighlightWord( cText, )
         lSw  := .F.
      endif
   endif

Return lSw

//----------------------------------------------------------------------------//

METHOD DlgFindWiki( nR, nC, lDlg ) CLASS TScintilla

   local oDlg
   local cText     := ::GetSelText()
   local oFontF
   local cFontF    := "Verdana"
   local oActiveX
   //::Send( SCI_SETLENGTHFORENCODE, -1, 0 )

   DEFAULT lDlg    := .T.

   ( nR, nC )

   if Empty( cText )
      cText := If( Empty( ::cLastFind ), "", ::cLastFind )
   endif
   cText := "http://wiki.fivetechsoft.com/doku.php" //+ cText   //?id=fivewin_

   //::SetOldPos()
   if lDlg

   DEFINE FONT oFontF NAME cFontF SIZE 0, -11
   DEFINE DIALOG oDlg TITLE "Wiki Find" OF Self ;
    SIZE ::nWidth + 280, ::nHeight ; //585, 485 ;
    COLOR CLR_BLUE, CLR_WHITE FONT oFontF
    oDlg:lHelpIcon := .F.

   @ 2, 5  SAY "Text" + ":" OF oDlg SIZE 35, 10 PIXEL
   @ 2, 45 SAY cText OF oDlg SIZE 240, 10 PIXEL
   @ 14, 5 ACTIVEX oActiveX OF oDlg PROGID "Shell.Explorer.2" SIZE 520, 204 
   
   @ 220, 310 BUTTON FWString( "&Cancel" ) OF oDlg SIZE 45, 12 ;
      ACTION ( oDlg:End() ) PIXEL

   ACTIVATE DIALOG oDlg CENTERED NOWAIT ;  //IN PARENT 
      ON INIT ( Self, ;
                oActiveX:Silent := .T., ;
                oActiveX:Do("Navigate2", cText ) ) ;  //oActiveX:Document():All:Item("id", 0):value := ::GetSelText() ) ;
      VALID ( Self, oFontF:End(), if( !Empty( oActiveX ), oActiveX:End(), ), .T. )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD DlgReplace() CLASS TScintilla

   local oDlg
   local oGet
   local lForward    := .T.
   local lSpacesL    := .T.
   local cText       := ::GetSelText()
   local cWith       := if( Empty( ::cReplace ), Space( 200 ), Padr( ::cReplace, 200) )
   local oFontF
   local cFontF      := "Verdana"
   local lMay        := .F.
   local lWord       := .F.
   local lPrev       := .F.
   local cFind       := ""
   local lAll        := .F.
   local lAllSpaces  := .F.

   if Empty( cText )
      cText = If( Empty( ::cLastFind ), "", ::cLastFind )
   endif

   if MLcount( cText ) > 1
      cText = Trim( MemoLine( cText,, 1 ) )
   endif

   ::uFlagFind := 0

   cText := PadR( cText, 200 )
   cFind := cText
   DEFINE FONT oFontF NAME cFontF SIZE 0, -11

   DEFINE DIALOG oDlg TITLE FWString( "Replace" ) + "[ ALT Gr + F3 ] for continue" ;
     SIZE 325, 340 OF Self FONT oFontF

   oDlg:lTruePixel := .f.

   @ 0.2, 1.4 SAY FWString( "This" ) + ":" OF oDlg

   @ 1,  1 GET oGet VAR cText OF oDlg SIZE 142, 11 COLORS CLR_BLUE, CLR_WHITE

   @ 2.2, 1 COMBOBOX cFind ITEMS ::aHistFind OF oDlg ;
          SIZE 142, 140 ;
          ON CHANGE ( Self, cText := if( lSpacesL, Alltrim( cFind ), RTrim( cFind ) ),;
                     oGet:Refresh() )

   @ 2.9, 1.4 SAY FWString( "With" ) + ":" OF oDlg

   @ 4,  1 GET cWith OF oDlg SIZE 142, 11 COLORS CLR_BLUE, CLR_WHITE ;
      VALID ( ::cReplace  := RTrim( cWith ), .T. )

   @ 5.2, 1.2 CHECKBOX lForward PROMPT FWString( "Forward" ) ;
      OF oDlg SIZE 80, 15

   @ 5.2, 12 CHECKBOX lSpacesL PROMPT "Del Left Spaces " ;
      OF oDlg SIZE 100, 15

   @ 6.4, 1.2 CHECKBOX ::lIndicators PROMPT "Marks Indicators " ;
      OF oDlg SIZE 90, 15

   @ 6.4, 12 CHECKBOX lMay PROMPT "Match Upper/Lower " ;
      OF oDlg SIZE 100, 15 ;
      ON CHANGE (::uFlagFind := nOr(::uFlagFind,if(lMay, SCFIND_MATCHCASE,0)))

   @ 7.6, 1.2 CHECKBOX lPrev PROMPT "Top Word " ;
      OF oDlg SIZE 80, 15 ;
      ON CHANGE (::uFlagFind := nOr(::uFlagFind,if(lPrev, SCFIND_WORDSTART,0)))

   @ 7.6, 12 CHECKBOX lWord PROMPT "Word Complete " ;
      OF oDlg SIZE 100, 15 ;
      ON CHANGE (::uFlagFind := nOr(::uFlagFind,if(lWord, SCFIND_WHOLEWORD,0)))

   @ 8.8, 1.2 CHECKBOX lAll PROMPT "Replace All " ;
      OF oDlg SIZE 70, 15

   @ 8.8, 12 CHECKBOX lAllSpaces PROMPT "Delete Spaces " ;
      OF oDlg SIZE 80, 15

   @ 8.4, 1.2 BUTTON "&Ok" OF oDlg SIZE 43, 13 ;
      ACTION ( if( lAll, ;
                   ::ReplaceAll( cText, lForward, cWith, lAll, lAllSpaces),),;
               if( !::ReplaceButton( cText, lForward, cWith, lAll, lAllSpaces ),;
                   MsgAlert( "Text not found" ), ), ;
               oDlg:End() )      
      
      /*
      if( !hb_IsNil( cText ), ;
                ( if( Empty( Ascan( ::aHistFind, cText ) ), ;
                      AAdd( ::aHistFind, cText ), ), ;
                If( ::FindText( AllTrim( cText ), lForward ),;
                  ( ::nSelStart := ::GetSelectionStart(),;
                   ::nSelEnd    := ::GetSelectionEnd(),;
                   ::ReplaceSel( AllTrim( cWith ) ),;
                   ::nSelStart  := ::nSelEnd := 0 ),;
                   MsgAlert( "Text not found" ) ) ), oDlg:End() ),;
                   oBtnOk:SetText( FWString( "&Next" ) ) )
       */
   
   @ 8.4, 18 BUTTON FWString( "&Cancel" ) OF oDlg SIZE 43, 13 ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg CENTERED IN PARENT NOWAIT

   oFontF:End()

return nil

//----------------------------------------------------------------------------//

METHOD ReplaceButton( cText, lForward, cWith, lAll, lAllSpaces ) CLASS TScintilla

   local lSw   := .F.

   if !hb_IsNil( cText )
      DEFAULT cWith       := ::cReplace
      DEFAULT lForward    := .T.
      DEFAULT lAll        := .F.
      DEFAULT lAllSpaces  := .F.
      cText := RTrim( cText )
      if Empty( Ascan( ::aHistFind, cText ) )
         AAdd( ::aHistFind, cText )
      endif
      ::GotoPos( ::GetSelectionStart() - 1 )
      If ::FindText( if( lAllSpaces, AllTrim( cText ), cText ), lForward )
         lSw         := .T.
         ::nSelStart := ::GetSelectionStart()
         ::nSelEnd   := ::GetSelectionEnd()
         ::ReplaceSel( if( !lAllSpaces, AllTrim( cWith ), cWith ) )
         //::nSelStart := ::nSelEnd := 0

         if lForward
           ::FindNext()
         else
           ::FindPrev()
         endif

      endif
   endif

Return lSw

//----------------------------------------------------------------------------//

METHOD ReplaceAll( cText, lForward, cWith, lAll, lAllSpaces ) CLASS TScintilla

   local lSw

   if !hb_IsNil( cText )
      lSw    := ::ReplaceButton( cText, lForward, cWith, lAll, lAllSpaces )
      Do While lSw
         lSw := ::ReplaceButton( cText, lForward, cWith, lAll, lAllSpaces )       
      Enddo
   endif
   
Return nil

//----------------------------------------------------------------------------//

METHOD DlgGoToLine() CLASS TScintilla

   local oDlg
   local nLine     := ::nLine()
   local aInfo      := GetFontInfo( GetFontMenu() )
   local oFontF
   local cFontF     := aInfo[4]

   ::SetOldPos()
   DEFINE FONT oFontF NAME cFontF SIZE 0, -11
   DEFINE DIALOG oDlg SIZE 250, 150 ;
      TITLE FWString( "Goto line" )
   oDlg:lTruePixel := .f.

   @ 1.5, 5.5 SAY FWString( "Number" ) + ":" OF oDlg SIZE 20, 8

   @ 1.7, 7.2 GET nLine OF oDlg PICTURE "99999" SIZE 30, 11 ;
     COLORS CLR_BLUE, CLR_WHITE

   @ 3, 2.4 BUTTON FWString( "&Ok" ) DEFAULT OF oDlg SIZE 43, 13 ;
      ACTION ( ::GotoLine( nLine ), oDlg:End() ) //::GoLineEnsureVisible( nLine )

   @ 3, 11 BUTTON FWString( "&Cancel" ) OF oDlg SIZE 43, 13 ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg CENTERED

   oFontF:End()

return nLine

//----------------------------------------------------------------------------//

METHOD DlgInsChar( nLin1, nLin2, lEnd ) CLASS TScintilla

   local aLine
   local cCad        := ""
   local cCad2       := ""
   local cCadSel     := ::GetSelText()
   local nStart      := ::Send( SCI_GETSELECTIONSTART, 0, 0 )
   local nEnd        := ::Send( SCI_GETSELECTIONEND, 0, 0 )
   local x
   DEFAULT nLin1     := ::Send( SCI_LINEFROMPOSITION, nStart, 0 ) + 1
   DEFAULT nLin2     := ::Send( SCI_LINEFROMPOSITION, nEnd, 0 ) + 1
   DEFAULT lEnd      := .F.

   aLine := ::DlgChars( lEnd )
   if !Empty( aLine[ 1 ] )
      cCad := RTrim( aLine[ 1 ] ) //+ " "
   else
      if Len( aLine[ 1 ] ) > 0
         cCad := aLine[ 1 ]
      endif
   endif
   if lEnd
      if !Empty( aLine[ 2 ] )
         cCad2 := RTrim( aLine[ 2 ] ) //+ " "
      else
         if Len( aLine[ 2 ] ) > 0
            cCad2 := aLine[ 2 ]
         endif
      endif
   endif
   if !Empty( cCad ) .or. Len( cCad ) > 0
      if !Empty( cCadSel )
         For x = nLin1 to nLin2
            ::GoLine( x )
            if lEnd
               ::GoHome()
               ::InsertChars( cCad , 0, .F., .F. )
               ::LineEnd()
               ::InsertChars( cCad2, 0, .F., .F. )
            else
               ::InsertChars( cCad , 0, .F., .F. )
            endif
         Next x
      else
         ::GoHome()
         ::InsertChars( cCad , 0, .F., .F. )
      endif
   endif
   ::SetFocus()

Return cCad

//----------------------------------------------------------------------------//

METHOD DlgChars( lEnd ) CLASS TScintilla

   local oDlg
   local cCad1   := Space( 50 )
   local cCad2   := Space( 50 )
   local nSpac   := 0

   DEFAULT lEnd  := .F.

   DEFINE DIALOG oDlg TITLE " Insert Text: " ;
           SIZE 360, 200 OF ::oWnd PIXEL

   @ 10, 6  SAY "String Top: " OF oDlg SIZE 40, 10 PIXEL
   @ 20, 6  GET cCad1 PICTURE "@X" OF oDlg SIZE 170, 12 PIXEL
   @ 36, 6  SAY "String Bottom: " OF oDlg SIZE 40, 10 PIXEL
   @ 46, 6  GET cCad2 PICTURE "@X" OF oDlg SIZE 170, 12 PIXEL ;
     WHEN lEnd
   @ 66, 6  SAY "Insert Spaces Top: " OF oDlg SIZE 60, 10 PIXEL
   @ 60, 60 GET nSpac OF oDlg SPINNER ;
     SIZE 10, 10 PICTURE "99" PIXEL RIGHT ;
     VALID ( if( nSpac > 0, ( cCad1 := Space( nSpac ), cCad2 := "" ), ), .T. )

   @ 80, 8   BUTTON "Cancel" OF oDlg SIZE 45, 13 PIXEL ;
     ACTION ( cCad1 := "", cCad2 := "", oDlg:End() )
   @ 80, 128 BUTTON "Insert" OF oDlg SIZE 45, 13 PIXEL ;
     ACTION ( oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED

Return { cCad1, cCad2 }

//----------------------------------------------------------------------------//

METHOD KeyChar( nKey, nFlags ) CLASS TScintilla

   local lControl := GetKeyState( VK_CONTROL )
   
   ::SetCursor( -1 )
   if lControl
      do case
         case nKey == VK_CTRL_B

         case nKey == VK_CTRL_C
              ::Copy()

         case nKey == VK_CTRL_F

         case nKey == VK_CTRL_I
              ::DlgInsChar( , , .T. )
              return 0

         case nKey == VK_CTRL_P

         case nKey == VK_CTRL_U
              ::DlgInsChar( , , )
              return 1

         case nKey == VK_CTRL_V
              ::Paste()

         case nKey == VK_CTRL_X
              ::Cut()

         case nKey == 112 //.and. lControl
         
      endcase
   else
      ::nKey64      := nKey
      Do Case
         Case nKey = 27     //  "Esc"
         if !Empty( ::oListFunc )
            if !Empty( ::bESC )
               if Valtype( ::bESC ) == "B"
                  Eval( ::bESC, Self, ::oListFunc )
               endif
            endif
            ::oListFunc:Seek("")
            ::oListFunc:SetFocus()
         endif

         Case nKey = 9
            ::cWritten  := ""
            Return nil
         /*
         Case nKey = 13
            ::cWritten  := ""
            if ::CallTipActive()
               Return nil
            endif
         */
      EndCase
      if IsExe64()
         Return 1
      endif
   endif

return ::Super:KeyChar( nKey, nFlags )

//----------------------------------------------------------------------------//

METHOD KeyDown( nKey, nFlags ) CLASS TScintilla

   local lControl := GetKeyState( VK_CONTROL )
   local lShift   := GetKeyState( VK_SHIFT )
   local lMenu    := GetKeyState( VK_MENU )
   local nLine    := ::nLine()
   local cText    := Space( 140 )
   local lSw      := .F.

   ::SetCursor( -1 )
   if ::lMessage
      if ValType( ::bTxtMarg ) = "B"
         ::cUser := Eval( ::bTxtMarg, Self )
         if !Empty( ::cUser ) .and. ValType( ::cUser ) = "C"
            if  ( nKey = 46 .or. nKey = 8 )
               ::Send( SCI_MARGINSETSTYLE, nLine-1, STYLE_LINENUMBER )
               ::Send( SCI_MARGINSETTEXT, nLine-1, ::cUser ) //+" "+Left(Time(),5) ) //

            else
               if ( nKey >= 65 .and. nKey <= 122 ) .or. nKey = 13
                  ::Send( SCI_MARGINSETSTYLE, nLine-1, STYLE_LINENUMBER )
                  ::Send( SCI_MARGINSETTEXT, nLine-1, ::cUser ) //+" "+Left(Time(),5) ) //
               endif

            endif
         endif
      endif
   endif

   if lControl .and. !lMenu
    do case
      Case nKey == VK_F7
           ::lIndicators      := !::lIndicators

      Case nKey == 48
           ::lMargLin         := .F.  //!::lMargLin
           ::lMarking         := .F.  //!::lMarking
           ::lFolding         := .F.  //!::lFolding
           ::lMessage         := .F.  //!::lMessage
           ::lMargRun         := .F.  //!::lMargRun
           ::Refresh( .F. )

      Case nKey == 49
           ::lMargLin         := !::lMargLin
           ::Refresh( .F. )


      Case nKey == 50
           ::lMarking         := !::lMarking
           ::Refresh( .F. )

      Case nKey == 51
           ::lFolding         := !::lFolding
           ::Refresh( .F. )

      Case nKey == 52
           ::lMessage         := !::lMessage
           ::Refresh( .F. )

      Case nKey == 53
           ::lMargRun         := !::lMargRun
           ::Refresh( .F. )

      Case nKey == 54
           ::SelectLine()

      Case nKey == 55

      Case nKey == 56

      Case nKey == 57

      Case ( nKey == 65 .or. nKey == 97 )  //a
           //::SelectAll()

      Case ( nKey == 66 .or. nKey == 98 )  //b
      Case ( nKey == 67 .or. nKey == 99 )  //c
      Case ( nKey == 68 .or. nKey == 100 ) //d
      Case ( nKey == 69 .or. nKey == 101 ) //e
      Case ( nKey == 70 .or. nKey == 102 ) //f
      Case ( nKey == 71 .or. nKey == 103 ) //g
      Case ( nKey == 72 .or. nKey == 104 ) //h
      Case ( nKey == 73 .or. nKey == 105 ) //i
      Case ( nKey == 74 .or. nKey == 106 ) //j
      Case ( nKey == 75 .or. nKey == 107 ) //k
      Case ( nKey == 76 .or. nKey == 108 ) //l
      Case ( nKey == 77 .or. nKey == 109 ) //m
      Case ( nKey == 78 .or. nKey == 110 ) //n
      Case ( nKey == 79 .or. nKey == 111 ) //o
      Case ( nKey == 80 .or. nKey == 112 ) //p
           //::Print( ::oFntEdt, ::cFileName, .T. )
           //::SetFocus()
      Case ( nKey == 81 .or. nKey == 113 ) //q
           //::DlgInsChar( , , )
      Case ( nKey == 82 .or. nKey == 114 ) //r
      Case ( nKey == 83 .or. nKey == 115 ) //s
      Case ( nKey == 84 .or. nKey == 116 ) //t
      Case ( nKey == 85 .or. nKey == 117 ) //u
           //::DlgInsChar( , , )
      Case ( nKey == 86 .or. nKey == 118 ) //v
      Case ( nKey == 87 .or. nKey == 119 ) //w
      Case ( nKey == 88 .or. nKey == 120 ) //x
      Case ( nKey == 89 .or. nKey == 121 ) //y
           ::LineDelete()
      Case ( nKey == 90 .or. nKey == 122 ) //z
      Otherwise
            //? nKey
    endcase
    ::SetFocus()
    return 0 //nil
   else
    do case
       /*
       case nKey == 8
          if ! Empty( ::cWritten )
             ::cWritten = Left( ::cWritten, Len( ::cWritten ) - 1 )
          endif
          if ::lFoundToken
             if ! Empty( ::cWritten )
                if ! Empty( ::cWritten ) .and. ;
                   ! Empty( ::cFoundToken := ::FindToken( ::cWritten, .T. ) )
                   ::nTokenPos := ::GetCurrentPos()
                   ::CallTipShow( ::nTokenPos, ::cFoundToken )
                endif
             endif
          endif
      */
      
      case nKey == VK_TAB
         ::cWritten  := ""
         return nil
      /*
      Case nKey = 13
         ::cWritten  := ""
         if ::CallTipActive()
            Return nil
         endif
      */
      /*
      case nKey == VK_RETURN
         if ::lFoundToken
            if ::CallTipActive()
               nCurrent = ::GetCurrentPos() - 1
               WHILE ::ValidChar( cChar := ::GetTextAt( nCurrent ) )
                  nCurrent--
               END
               ::SetSel( nCurrent+1, ::GetCurrentPos() )
               ::ReplaceSel( ::cFoundToken )
               ::CallTipCancel()
            endif
         endif
         ::cWritten  := ""
         Return 1
      */
      /*
      case nKey == VK_F2
           //::LineSep()
      */

      case nKey == VK_F3
         if !lControl .and. !lShift
            if Empty( ::GetSelText() ) .and. Empty( ::cLastFind )
               ::DlgFindText()
            else
               ::FindNext()
            endif
         else
            if lShift
               ::FindPrev()
            else
               if lMenu
                  if !Empty( ::GetSelText() )
                     cText := ::GetSelText()
                     ::GotoPos( ::GetSelectionStart() - 2 )
                     //::ReplaceButton( cText, lForward, cWith, lAll, lAllSpaces )
                     ::ReplaceButton( cText, , , .F., )
                  else
                     ::DlgReplace()
                  endif
               endif
            endif
         endif

      case nKey == VK_F7
          if lControl
             ::lIndicators  := !::lIndicators
          else
           ::Send( SCI_INDICATORCLEARRANGE, 0, ::Send( SCI_GETTEXTLENGTH, 0, 0 ) )
          endif
      case nKey == VK_F8
           ::SetToggleMark()

      case nKey == VK_F9
         if !lControl .and. !lShift
           if Empty( ::Send( SCI_ANNOTATIONGETVISIBLE, 0, 0 ) )
              ::Send( SCI_ANNOTATIONSETVISIBLE, 2, 0 )
           endif
           ::Send( SCI_ANNOTATIONGETTEXT, ::nLine()-1, @cText )
           if MsgGet( "Anotacion: "+Str( ::nLine() ), "Texto: ", @cText )
              ::Send( SCI_ANNOTATIONSETTEXT, ::nLine()-1, RTrim( cText ) )
           endif
         endif

      case nKey == VK_F11
           ::NextMarker()

      case nKey == VK_F12
           ::PrevMarker()

      case nKey == VK_LEFT
           ::cWritten = ""

      case nKey == VK_RIGHT
           ::cWritten = ""

      case nKey == VK_UP
           ::cWritten = ""

      case nKey == VK_DOWN
           ::cWritten = ""

    endcase
   endif
   ::Send( SCI_BRACEHIGHLIGHT, -1, 0 )
   ::Send( SCI_BRACEBADLIGHT, -1, 0 )

return IF( lSw, 1, ::Super:KeyDown( nKey, nFlags ) )

//----------------------------------------------------------------------------//

METHOD SelFont( oFont, lUni ) CLASS TScintilla
   
   DEFAULT lUni      := .F.
   DEFAULT oFont     := ::oFont
   ::Super:SelFont( ::nClrText )          // cColor

   if !Empty( oFont )
      ::Send( SCI_STYLESETFONT, STYLE_DEFAULT, ::oFont:cFaceName )
      ::Send( SCI_STYLESETSIZE, STYLE_DEFAULT, Abs( ::oFont:nHeight ) )
   endif

   //::Send( SCI_STYLECLEARALL, 0, 0 )
   ::SetColourise( .T. )
   ::SetFont( ::oFont )
   ::SetHighlightColors()
   ::SetColorLimitCol()

return nil

//----------------------------------------------------------------------------//

METHOD SendAsEmail( lAttach ) CLASS TScintilla

   local oMail

   DEFAULT lAttach := .F.

   if lAttach
      DEFINE MAIL oMail ;
         SUBJECT "Send File" ;
         TEXT ::cFileName ;
         FILES ::cFileName,::cFileName ;
         FROM USER ;
         RECEIPT
   else
      DEFINE MAIL oMail ;
         SUBJECT "Send File" ;
         TEXT ::GetText() ;
         FROM USER ;
         RECEIPT
   endif

   ACTIVATE MAIL oMail

return nil

//----------------------------------------------------------------------------//

METHOD SetColorSelect( nClrTxt, nClrPane ) CLASS TScintilla

   //DEFAULT nClrTxt   := ::nColorSelectionB
   DEFAULT nClrPane  := ::nColorSelection
   if !Empty( nClrTxt )
      ::Send( SCI_SETSELFORE, 1, nClrTxt ) //::nClrPane - CLR_WHITE
   endif
   if !Empty( nClrPane )
      ::Send( SCI_SETSELBACK, 1, nClrPane ) //RGB( 240, 240, 240 ) )
   endif

return nil

//----------------------------------------------------------------------------//

METHOD SetColorLimitCol( lIni ) CLASS TScintilla

   DEFAULT lIni   := .T.
   //FWLOG nCol, ::oFont:nWidth, ::oFont:nHeight
   if ::lUtf8
      ::Send( SCI_SETEDGECOLUMN , Int( 79 * 1 ) )
      ::Send( SCI_SETEDGEMODE, EDGE_BACKGROUND ) //0 EDGE_NONE, 1 EDGE_LINE
      ::Send( SCI_SETEDGECOLOUR , ::nColorLimitCol )  //Solo funciona en modo 2?
   else
      ::Send( SCI_SETEDGECOLUMN , Int( 79 * 1 ) ) //   // * nCol
      ::Send( SCI_SETEDGEMODE, EDGE_LINE ) //0 EDGE_NONE, 1, 2 EDGE_BACKGROUND
      ::Send( SCI_SETEDGECOLOUR , ::nColorLimitCol )  //Solo funciona en modo 2?
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD SetColor( nClrText, nClrPane, lIni ) CLASS TScintilla

   DEFAULT nClrText  := ::nClrText
   DEFAULT nClrPane  := ::nClrPane
   DEFAULT lIni      := .F.

   ::nClrText = nClrText
   ::nClrPane = nClrPane
   if lIni
      ::Send( SCI_STYLERESETDEFAULT, 0, 0 )
      //::Send( SCI_STYLECLEARALL, 0 , 0 )
   endif
   ::Send( SCI_STYLESETFORE, STYLE_DEFAULT, ::nClrText )
   ::Send( SCI_STYLESETBACK, STYLE_DEFAULT, ::nClrPane )

   ::SetColorCaret(,)
   ::SetMBrace()
   ::SetHighlightColors()
   ::SetColorLimitCol( lIni )
   //::SetViewSpace( .F. )
   //::Send( SCI_SETWHITESPACEFORE, 0, ::nClrText )
   //::Send( SCI_SETWHITESPACEBACK, 0, ::nClrPane )

   //Color seleccion del texto
   ::SetColorSelect(  ,  )

return nil

//----------------------------------------------------------------------------//

METHOD SetHighlightColors() CLASS TScintilla

   if ::Send( SCI_GETLEXER, 0, 0 ) = SCLEX_FLAGSHIP
      ::StyleSet( SCE_FS_COMMENTLINE   ) ; ::StyleSetColor( ::cCCommentLin[ 1 ] )
      ::StyleSet( SCE_FS_OPERATOR      ) ; ::StyleSetColor( ::cCOperator[ 1 ] )
      ::StyleSet( SCE_FS_STRING     )    ; ::StyleSetColor( ::cCString[ 1 ]  )
      ::StyleSet( SCE_FS_PREPROCESSOR  ) ; ::StyleSetColor( ::cCIdentif[ 1 ] )
      ::StyleSet( SCE_FS_NUMBER     )    ; ::StyleSetColor( ::cCNumber[ 1 ] )
      ::StyleSet( SCE_FS_KEYWORD       ) ; ::StyleSetColor( ::cCKeyw1[ 1 ] )
      ::StyleSet( SCE_FS_KEYWORD4      ) ; ::StyleSetColor( ::cCKeyw4[ 1 ] )
      ::StyleSet( SCE_FS_KEYWORD2     )  ; ::StyleSetColor( ::cCKeyw2[ 1 ] )
      ::StyleSet( SCE_FS_KEYWORD3     )  ; ::StyleSetColor( ::cCKeyw3[ 1 ] )
   
      ::Send( SCI_SETSELFORE, 1, nRGB( 240, 240, 240 ) ) //CLR_WHITE )
      ::Send( SCI_SETSELBACK, 1, CLR_BLUE )
      ::Send( SCI_STYLESETBACK, SCE_FS_PREPROCESSOR, ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_STRING,       ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_COMMENTLINE,  ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_OPERATOR,     ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_NUMBER,       ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_KEYWORD,      ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_KEYWORD4,     ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_KEYWORD2,     ::nClrPane )
      ::Send( SCI_STYLESETBACK, SCE_FS_KEYWORD3,     ::nClrPane )
      if Upper( ::oFont:cFaceName ) <> Upper( "FixedSys" )
         ::Send( SCI_STYLESETITALIC, SCE_FS_COMMENTLINE, 1 )
      endif
   
   else
      ::Send( SCI_STYLESETFORE, SCE_FWH_DEFAULT, ::nClrText )
      ::Send( SCI_STYLESETFORE, SCE_FWH_COMMENTDOC, ::cCComment[ 1 ] )
      ::Send( SCI_STYLESETFORE, SCE_FWH_COMMENT, ::cCComment[ 1 ] )
      ::Send( SCI_STYLESETFORE, SCE_FWH_COMMENTLINE, ::cCCommentLin[ 1 ] )
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
      ::Send( SCI_STYLESETBACK, SCE_FWH_COMMENTDOC, ::cCComment[ 2 ] )
      ::Send( SCI_STYLESETBACK, SCE_FWH_COMMENT, ::cCComment[ 2 ] )
      ::Send( SCI_STYLESETBACK, SCE_FWH_COMMENTLINE, ::cCCommentLin[ 2 ] )
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
   
      //::Send( SCI_STYLESETCASE, SCE_FWH_KEYWORD, SC_CASE_UPPER )
      //SC_CASE_UPPER = 1 SC_CASE_LOWER = 2 SC_CASE_MIXED = 0 SC_CASE_CAMEL = 3
      //::Send( SCI_STYLESETCASE, SCE_FWH_DEFAULT, ::nClrPane )
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
   
      if !Empty( ::oFont )
         if Upper( ::oFont:cFaceName ) <> Upper( "FixedSys" )
            ::Send( SCI_STYLESETITALIC, SCE_FWH_COMMENT, 1 )
            ::Send( SCI_STYLESETITALIC, SCE_FWH_COMMENTDOC, 1 )
            ::Send( SCI_STYLESETITALIC, SCE_FWH_COMMENTLINE, 1 )
         endif
      endif
   endif

return nil

//----------------------------------------------------------------------------//

METHOD SetAStyle( nStyle, nFore, nBack, nSize, cFace ) CLASS TScintilla

   DEFAULT nSize := 0
   DEFAULT cFace := ""
   DEFAULT nBack := CLR_WHITE

   ::Send( SCI_STYLESETFORE, nStyle, nFore )
   ::Send( SCI_STYLESETBACK, nStyle, nBack )

     if nSize >= 1
         ::Send( SCI_STYLESETSIZE, nStyle, nSize )
     endif
     if ! Empty( cFace )
         ::Send( SCI_STYLESETFONT, nStyle, cFace )
     endif

return nil

//----------------------------------------------------------------------------//

METHOD SetFixedFont() CLASS TScintilla

   if Empty( ::oFont )
      ::StyleSetFont( ::GetCurrentStyle(), "FixedSys" )
      ::StyleSetSize( ::GetCurrentStyle(), 12 ) //+ ::nTpMonitor ) )
   else
      ::StyleSetFont( ::GetCurrentStyle(), ::oFont:cFaceName )
      ::StyleSetSize( ::GetCurrentStyle(), Abs( ::oFont:nHeigth ) ) //+ ::nTpMonitor ) )
   endif

   ::StyleSetBold( ::GetCurrentStyle(), .F.  )
   ::StyleSetItalic( ::GetCurrentStyle(), .F. )
   ::StyleSetUnderline( ::GetCurrentStyle(), .F. )

return nil

//----------------------------------------------------------------------------//


METHOD SetFont( oFont, lIni ) CLASS TScintilla

   local x
   local nSizeF   := -9
   local aFont1   :=  { "Segoe UI Mono", "Fixedsys" }
   
   DEFAULT lIni    := .F.
   DEFAULT oFont   := ::oFont

   ::Super:SetFont( oFont )
   if lIni
      ::Send( SCI_STYLECLEARALL, 0, 0 )
      if !Empty( ::oFont ) 
         //nSizeF  := ::oFont:nHeight
      endif
      if Empty( ::oFntLin )
         if !Empty( At( "WINDOWS 8", Upper( Os() ) ) )
            DEFINE FONT ::oFntLin NAME aFont1[ 1 ] SIZE 0, nSizeF //- ::nTpMonitor
         else
            DEFINE FONT ::oFntLin NAME aFont1[ 2 ] SIZE 0, nSizeF //- ::nTpMonitor
         endif
      endif
   endif

   For x = 0 to 255
      if x <> 33
         /*
         if !Empty( ::cLang )
            ::Send( SCI_STYLESETCHARACTERSET, x, ::cLang ) //DEFAULT //OEM
         else
            ::Send( SCI_STYLESETCHARACTERSET, x, SC_CHARSET_DEFAULT ) //ANSI //OEM
         endif
         */
         ::Send( SCI_STYLESETFONT, x, oFont:cFaceName )
         ::Send( SCI_STYLESETSIZE, x, Max( 10, Round( Abs( oFont:nHeight ), 0 ) ) ) // + ::nTpMonitor ) )
         ::Send( SCI_STYLESETFORE, x, ::nClrText )
         ::Send( SCI_STYLESETBACK, x, ::nClrPane )
         ::Send( SCI_STYLESETBOLD, x, If( oFont:lBold, 1, 0 ) )
         ::Send( SCI_STYLESETITALIC, x, If( oFont:lItalic, 1, 0 ) )
         ::Send( SCI_STYLESETUNDERLINE, x, If( oFont:lUnderline, 1, 0 ) )
         ::Send( SCI_STYLESETWEIGHT, x, SC_WEIGHT_NORMAL )
      endif
   Next x

   if Empty( ::cLang )
      ::cLang  := SC_CHARSET_DEFAULT
   endif
      //::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_DEFAULT, ::cLang )
      ::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_COMMENTDOC, ::cLang )
      ::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_COMMENT, ::cLang )
      ::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_COMMENTLINE, ::cLang )
      //::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_OPERATOR, ::cLang )
      ::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_STRING, ::cLang )
      //::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_NUMBER, ::cLang )
      //::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_BRACE, ::cLang )
      //::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_IDENTIFIER, ::cLang )
      //::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_KEYWORD, ::cLang )
      //::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_KEYWORD1, ::cLang )
      //::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_KEYWORD2, ::cLang )
      //::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_KEYWORD3, ::cLang )
      //::Send( SCI_STYLESETCHARACTERSET, SCE_FWH_KEYWORD4, ::cLang )
   //endif

return nil

//----------------------------------------------------------------------------//

METHOD SetKeyWords( nKeys, cKeys ) CLASS TScintilla

   if !Empty( cKeys )
      ::Send( SCI_SETKEYWORDS, nKeys, cKeys )
   endif

return nil

//----------------------------------------------------------------------------//


METHOD Setup( nMark, lInit ) CLASS TScintilla

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

   local KeyWords0
   local KeyWords1
   local KeyWords2
   local KeyWords3
   local KeyWords4
   local nBits

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

   local nMarg     := 0
   local x
   local oFnt

   DEFAULT nMark   := ::nMarkFold //4
   DEFAULT lInit   := .T.

   if lInit
      if Empty( aFHb )
         LoadFHb()
      endif
      if Empty( aFHb1 )
         aFHb1 := ReadFuncHb()
      endif
      if Empty( aFFw )
         aFFw  := ReadFuncFw() + ReadFuncFwC()
      endif

      //if ::cLexer = 517 .or. ::cLexer = 518 .or. ::cLexer = 519
      // KeyWords0  := cCad2
      // KeyWords1  := cCad3
      // KeyWords2  := aFHb1
      // KeyWords3  := aFFw
      if !Empty( ::cListFuncs )
         KeyWords0  := lower( ::cListFuncs )
         KeyWords1  := cCad2 + cCad3
      else
         KeyWords0  := cCad2
         KeyWords1  := cCad3
      endif
      KeyWords2  := cCad0
      KeyWords3  := aFFw
      KeyWords4  := aFHb1
      //endif

      //::Send( SCI_SETPHASESDRAW, 0, 0 )
      // ? ::Send( SCI_GETPHASESDRAW, 0, 0 )
      //SCI_SETLAYOUTCACHE   // Investigar
      ::Send( SCI_STYLERESETDEFAULT, 0, 0 )
      ::Send( SCI_STYLECLEARALL, 0 , 0 )
      //::Send( SCI_BEGINUNDOACTION, 0, 0 )
      ::Send( SCI_EMPTYUNDOBUFFER, 0, 0 )

      ::ClearKeys()
      nBits  := ::Send( SCI_GETSTYLEBITSNEEDED, 0, 0 )  // 8
      ::Send( SCI_SETSTYLEBITS, Max( 5, nBits ) )
      ::Send( SCI_SETLEXER, ::cLexer, 0 )
      ::SetColourise( .T. )
      //::Send( SCI_USEPOPUP, 1, 0 )
      //::Send( SCI_SETMOUSEDOWNCAPTURES, 0, 0 )

      //if lInit
      ::InitEdt()
      //endif

      if ::lUtf8 .and. !::lUtf16
         if ::GetUniCode()
            ::SetUniCode()
         endif
         ::cLang       := 1    //SC_CHARSET_EASTEUROPE //SC_CHARSET_THAI
      else
         if !::lUtf16
            ::cLang    := SC_CHARSET_ANSI
            ::Send( SCI_SETCODEPAGE, ::cLang, 0 ) //SC_CHARSET_DEFAULT, 0 )
         else
            ::cLang    := 1
            ::Send( SCI_SETCODEPAGE, ::cLang, 0 ) //SC_CHARSET_DEFAULT, 0 )
            ::SetUniCode()
         endif
      endif
      if ::lUtf8
         if !Empty( ::oFont )
            ::oFont:End()
            ::oFont   := Nil
         endif
         if Empty( ::oFont )
            if !Empty( ::cFontInfoU )
               ::SetFont( ::oFont := FontFromText( ::cFontInfoU, .T. ), .T. ) //SetMiFont( ::cFontInfoU ) ) //
            else
               DEFINE FONT oFnt NAME "Lucida Console" SIZE 0, -12 //- ::nTpMonitor )  //"Segoe UI Symbol" -11
            endif
         endif
      else
         if Empty( ::oFont )
            if !Empty( ::cFontInfo )
               ::SetFont( ::oFont := FontFromText( ::cFontInfo, .T. ), .T. ) //SetMiFont( ::cFontInfo ) ) //
            else                      
               DEFINE FONT oFnt NAME "FixedSys" SIZE 0, -12 //- ::nTpMonitor )  //Consolas
            endif
         endif
      endif
      
      if !Empty( oFnt )
         //oFnt:nHeight   -= ::nTpMonitor
         ::SetFont( oFnt, .T. )
      else
         //::oFont:nHeight   -= ::nTpMonitor
      endif

      if ::lFolding
         PonFold( ::hWnd , "fold" , "1" )
         PonFoldCompact( ::hWnd , "fold.compact" , "1" )   //"fold.fwhc.compact"  Â¿?
         ::Send( SCI_SETAUTOMATICFOLD, SC_AUTOMATICFOLD_CLICK, 0 )
         //SC_AUTOMATICFOLD_SHOW 1  //SC_AUTOMATICFOLD_CHANGE  4
      endif
      ::Send( SCI_SETWORDCHARS, 0, ::cTodosCar )
      /*
      if ::Send( SCI_GETLEXER, 0, 0 ) = 517 .or. ;
         ::Send( SCI_GETLEXER, 0, 0 ) = 518 .or. ;
         ::Send( SCI_GETLEXER, 0, 0 ) = 519 .or. ;
         ::Send( SCI_GETLEXER, 0, 0 ) = 73
      */
      ::Send( SCI_SETKEYWORDS, 0, KeyWords0 )
      ::Send( SCI_SETKEYWORDS, 1, KeyWords1 )
      ::Send( SCI_SETKEYWORDS, 2, KeyWords2 )
      ::Send( SCI_SETKEYWORDS, 3, KeyWords3 )
      ::Send( SCI_SETKEYWORDS, 4, KeyWords4 )
      //endif

      ::Send( SCI_SETEXTRAASCENT , Max( 1.6, ::nSpacLin ) )
      ::Send( SCI_SETEXTRADESCENT, Max( 1.6, ::nSpacLin ) )
      ::SetColor( ,, .F. )
      ::Send( SCI_SETMARGINLEFT, 0, ::nMargLeft )
      ::Send( SCI_SETMARGINRIGHT, 0, ::nMargRight )
   endif
   
   ::CalcWidthMargin()
   // Show lines numbers
   if ::nMargLines > 0
      ::Send( SCI_SETMARGINTYPEN, nMarg, SC_MARGIN_NUMBER )
      if ::lDebugEd .or. ::lDebugSt
         ::Send( SCI_SETMARGINWIDTHN, nMarg, ::nMargLines + 12 )
      else
         ::Send( SCI_SETMARGINWIDTHN, nMarg, ::nMargLines )
      endif
      ::Send( SCI_SETMARGINSENSITIVEN, nMarg, 1)
      ::Send( SCI_STYLESETBACK , STYLE_LINENUMBER , ::nBColorLin ) //CLR_VSBAR )
      ::Send( SCI_STYLESETFORE , STYLE_LINENUMBER , ::nTColorLin ) //CLR_BLUE )
      ::Send( SCI_STYLESETFONT , STYLE_LINENUMBER , ::oFntLin:cFaceName )
      ::Send( SCI_STYLESETSIZE , STYLE_LINENUMBER , Abs( Int( ::oFntLin:nHeight ) ) ) //+ ::nTpMonitor )
        //Abs( Int( ::oFont:nHeight ) * 0.95 ) )
   else
      ::Send( SCI_SETMARGINWIDTHN, nMarg, 0 )
   endif

   if ::nMargSymbol > 0
      nMarg++
      ::Send( SCI_SETMARGINWIDTHN, nMarg, ::nMargSymbol )
      ::Send( SCI_SETMARGINTYPEN, nMarg, SC_MARGIN_SYMBOL )
      ::Send( SCI_MARKERSETALPHA, nMarg, 100 ) //255 Opaque - 0 Transparente
      
      ::Send( SCI_MARKERDEFINE, nMarg, SC_MARK_SHORTARROW ) //BOOKMARK )    // Break Point
      ::Send( SCI_MARKERSETFORE, nMarg, CLR_RED )
      ::Send( SCI_MARKERSETBACK, nMarg, CLR_RED )

      ::Send( SCI_MARKERDEFINE, nMarg, SC_MARK_SHORTARROW )
      ::Send( SCI_MARKERSETFORE, nMarg, ::nTColorMar ) //CLR_BLUE )
      ::Send( SCI_MARKERSETBACK, nMarg, ::nBColorMar ) //CLR_BLUE )
      ::Send( SCI_SETMARGINSENSITIVEN, nMarg, 1 )
      ::Send( SCI_SETMARGINTYPEN, nMarg, SC_MARGIN_BACK )
   else
      ::Send( SCI_SETMARGINWIDTHN, nMarg, 0 )
   endif

   if ::nMargFold > 0  .and. ::lFolding
      nMarg++
      ::Send( SCI_SETMARGINTYPEN, nMarg, SC_MARGIN_SYMBOL )
      ::Send( SCI_SETMARGINWIDTHN, nMarg, ::nMargFold )
      ::Send( SCI_SETMARGINMASKN , nMarg, SC_MASK_FOLDERS )
      ::Send( SCI_SETMARGINSENSITIVEN, nMarg, 1 )
      ::Send( SCI_SETFOLDMARGINCOLOUR, nMarg, ::nBColorFol ) //CLR_VSBAR )
      if ::lDebugEd
         ::FoldLevelNumber()
      else
         if ::lDebugSt
            ::FoldLineSt()
         else
            ::FoldLineNumber()   //::Send( SCI_SETFOLDFLAGS, SC_FOLDFLAG_LINEAFTER_CONTRACTED, 1 )
            //::Send( SCI_SETFOLDFLAGS, SC_FOLDFLAG_LINEBEFORE_CONTRACTED, 1 )
         endif
      endif
      For x = 1 to Len( aMarkers[ 1 ] )
         ::Send( SCI_MARKERDEFINE , aMarkers[ 1 ][ x ], aMarkers[ nMark + 1 ][ x ] )
         ::Send( SCI_MARKERSETFORE, aMarkers[ 1 ][ x ], ::nTColorFol ) //CLR_WHITE )
         ::Send( SCI_MARKERSETBACK, aMarkers[ 1 ][ x ], ::nBColorMar ) //CLR_BLUE )
      Next x
   else
      ::Send( SCI_SETMARGINWIDTHN, nMarg, 0 )
   endif

   nMarg++
   if ::lMessage
      if ValType( ::bTxtMarg ) = "B"
         if !Empty( Eval( ::bTxtMarg, Self ) ) .and. ;
             ValType( Eval( ::bTxtMarg, Self ) ) = "C"
             ::Send( SCI_SETMARGINWIDTHN, nMarg, ::nMargText )
             ::Send( SCI_SETMARGINTYPEN, nMarg, 5 ) //SC_MARGIN_RTEXT )
         //::Send( SCI_SETMARGINMASKN , nMarg, ( nOr( 0, SC_MASK_FOLDERS )) )
         //::Send( SCI_SETMARGINTYPEN, nMarg, SC_MARGIN_BACK )
         endif
      endif
   else
      ::Send( SCI_SETMARGINWIDTHN, nMarg, 0 )
   endif

   nMarg++
   if ::lMargRun
      ::Send( SCI_SETMARGINWIDTHN, nMarg, ::nMargBuild )
      ::Send( SCI_SETMARGINTYPEN, nMarg, 5 ) //SC_MARGIN_RTEXT )
      //::Send( SCI_MARKERSETFORE, 4, ::nTColorRun ) //CLR_RED )
      //::Send( SCI_MARKERSETBACK, 4, ::nBColorRun ) //METRO_GRIS8 )
      //::Send( SCI_SETMARGINSENSITIVEN, 4, 1)
   else
      ::Send( SCI_SETMARGINWIDTHN, nMarg, 0 )
   endif

   // Ojo, UNICODE
   ::Send( SCI_SETEOLMODE, SC_EOL_CRLF )
   //::SetEOL( .T. )
   ::Send( SCI_SETPASTECONVERTENDINGS, 1, 0 )

   ::SetMIndent()

   //::SetColorLimitCol()
   /*
   //Color seleccion del texto
   ::SetColorSelect(  ,  )
   */
   
   ::Send( SCI_SETMULTIPLESELECTION, 1, 0 )
   ::Send( SCI_SETADDITIONALSELECTIONTYPING, 1, 0 )
   ::Send( SCI_SETCARETLINEVISIBLEALWAYS, 1, 0 )
   ::Send( SCI_ANNOTATIONSETVISIBLE, 2, 0 )

   // Lineas verticales de Tabuladores
   if ::lLinTabs
      ::SetLinIndent( .T., .F. )
   endif

   if ::lVirtSpace
      //::Send( SCI_SETVIRTUALSPACEOPTIONS, SCVS_USERACCESSIBLE, 0 )
      ::Send( SCI_SETVIRTUALSPACEOPTIONS, ;
              SCVS_RECTANGULARSELECTION + SCVS_USERACCESSIBLE, 0 )
   endif

   //Indicators
   ::SetIndicators()
   ::SetTipCaret( ::nTipCaret )
   //if !Empty( ::cListAutoc )
   ::Send( SCI_AUTOCSETIGNORECASE, 1, 0 )
   ::Send( SCI_AUTOCSETCASEINSENSITIVEBEHAVIOUR, ;
           SC_CASEINSENSITIVEBEHAVIOUR_IGNORECASE, 0 ) // -> 1
   ::Send( SCI_AUTOCSETMAXHEIGHT, 10, 0 )
   //::Send( SCI_AUTOCSETMAXWIDTH, 50, 0 )
   //endif

   /*
   if !empty( ::bSetup )
      if Valtype( ::bSetup ) = "B"
         Eval( ::bSetup, Self )
      endif
   endif
   */

   ::SetSavePoint() // unmodified state

return nil

//----------------------------------------------------------------------------//
METHOD MouseMove( nRow, nCol, nKeyFlags ) CLASS TScintilla

   ::SetCursor( -1 )

return CallWindowProc( ::nOldProc, ::hWnd, WM_MOUSEMOVE, nKeyFlags, nMakeLong( nCol, nRow ) )

//----------------------------------------------------------------------------//

METHOD MouseWheel( nKeys, nDelta, nXPos, nYPos ) CLASS TScintilla

   local aPoint := { nYPos, nXPos }

   ScreenToClient( ::hWnd, aPoint )
   //::SetOldPos()

   if IsOverWnd( ::hWnd, aPoint[ 1 ], aPoint[ 2 ] ) //.and. ;
      //::MouseRowPos( aPoint[ 1 ] ) > 0
      ::SetCursor( 6 )
      if lAnd( nKeys, MK_MBUTTON )
         if nDelta > 0
            ::PageUp()
         else
            ::PageDown()
         endif
      else
         if nDelta > 0
            ::GoUp( WheelScroll() )   //OJO - Ahora no se pasa el numero de lineas
         else
            ::GoDown( WheelScroll() ) // como parametro - Hay que cambiar los metodos
         endif
      endif
   endif

return nil

//----------------------------------------------------------------------------//

#define WM_UNICHAR                      0x0109
#define WM_DRAWITEM                     0x002B

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TScintilla

   local nDlg
   local nOpc
   local nCol
   local nRow
   local uRet     := Nil

   do case
      //case nMsg == WM_NOTIFY
           //nCode      := GetNMHDRCode( nLParam )    //
           //cChar      := GetCharHdr( nLParam )
      //   ::Notify( nWParam, nLParam )

      Case nMsg == WM_COMMAND
            //LogFile( "eventsc.log", { nMsg, nWParam, nLParam } )
           Do Case
              Case nWParam == 10 //Deshacer

              Case nWParam == 11 //Rehacer

              Case nWParam == 12 //Cortar

              Case nWParam == 13 //Copy
                  //if ::SendEditor( SCI_GETMULTIPLESELECTION, 0, 0 )
                  //   ? ::SendEditor( SCI_GETSELECTIONS, 0, 0 )
                  //else
                  //
                  //endif
              Case nWParam == 14 //Pegar
                  //SCI_SETMULTIPASTE(int multiPaste)
                  //SCI_GETMULTIPASTE
                  //SC_MULTIPASTE_ONCE - Default
                  //SC_MULTIPASTE_EACH - Creo que esta

           EndCase

      //Case nMsg == WM_DRAWITEM
      //     ::DrawItem( 0, nLParam )  //nIdCtl

      Case nMsg == WM_SYSKEYDOWN
           Do Case
              Case nWParam == VK_LEFT .and. !GetKeyState( VK_SHIFT )
                   Eval( ::bViews, 1 )
              Case nWParam == VK_RIGHT .and. !GetKeyState( VK_SHIFT )
                   Eval( ::bViews, 3 )
              Case nWParam == VK_DOWN .and. !GetKeyState( VK_SHIFT )
                   Eval( ::bViews, 2 )
              Case nWParam == VK_UP .and. !GetKeyState( VK_SHIFT )
                   // Mostrar todos
                   Eval( ::bViews, 1 )
                   Eval( ::bViews, 3 )
                   Eval( ::bViews, 2 )
              Case nWParam == VK_DIVIDE
                   //if ::lMultiView
                     Eval( ::bDoubleView )
                   //endif
              Case nWParam == VK_ADD
                   if !empty( ::oFldEdt )
                      nDlg := ::oFldEdt:nOption
                      nDlg++
                      if nDlg > Len( ::oFldEdt:aPrompts )
                         nDlg := 1
                      endif
                      ::oFldEdt:SetOption( nDlg )
                   endif
              Case nWParam == VK_SUBTRACT
                   if !empty( ::oFldEdt )
                      nDlg := ::oFldEdt:nOption
                      nDlg--
                      if nDlg <= 0
                         nDlg := Len( ::oFldEdt:aPrompts )
                      endif
                      ::oFldEdt:SetOption( nDlg )
                   endif
           EndCase

      //Case nMsg == WM_CONTEXTMENU
        // ::Send( SCI_USEPOPUP, 0 )

      Case nMsg == WM_RBUTTONDOWN   // 0x204

           nCol = GetXParam( nLParam )
           nRow = GetYParam( nLParam )
           nOpc      := ::NumMargen( nRow, nCol,  )
           ::nMargen := nOpc
           if nOpc <= 5 .and. nOpc >= 0
              if nOpc > 0
                 //::GotoLine( nLine + 1 )
              endif
              if ::lMnuMargen
                 ::MnuMargen( nRow, nCol, , nOpc )
              endif
           else
              ::MnuMargen( nRow, nCol, , nOpc )
           endif
           uRet   := 1

      otherwise
           //FWLOG nMsg, nWParam, nLParam
           ::Super:HandleEvent( nMsg, nWParam, nLParam )

   endcase

return uRet

//----------------------------------------------------------------------------//

METHOD Notify( nIdCtrl, nPtrNMHDR ) CLASS TScintilla

   local nCode    := GetNMHDRCode( nPtrNMHDR )
   local nLine
   local nPos     //:= GetPosHdr( nPtrNMHDR )
   local nMargen  //:= GetMargHdr( nPtrNMHDR )
   local cChar    := GetCharHdr( nPtrNMHDR )      // pMsg->ch
   local nList    := GetListHdr( nPtrNMHDR )
   //local cPText   := GetTextHdr( nPtrNMHDR )
   local cText
   local lControl := GetKeyState( VK_CONTROL )
   local nPoints
   local aLines
   local nIndex
   local cFunc
   //local nListM   := GetListMethodHdr( nPtrNMHDR )
   // Devuelve: SCN_AUTOCSELECTION, SCN_AUTOCCOMPLETED, SCN_USERLISTSELECTION

   ( nIdCtrl )

   if lControl
      Return 1
   endif
   do case
      case nCode = SCN_STYLENEEDED      // 2000
         //FWLOG "SCN_STYLENEEDED"
      case nCode = SCN_CHARADDED        // 2001
         nPos       := ::GetCurrentPos()  //::nPos64
         nLine      := ::nLine()
         if Empty( cChar )
            cChar  := ::nKey64
         endif
         ::CharAdded( nPos, nLine, cChar )
      case nCode = SCN_SAVEPOINTREACHED      //2002
         ::lModified   := .F.
      case nCode = SCN_SAVEPOINTLEFT         //2003
         ::lModified   := .T.
      case nCode = SCN_MODIFYATTEMPTRO       //2004
         //MsgInfo( "File Read-Only", "Attention" )
         //FWLOG "SCN_MODIFYATTEMPTRO"
      case nCode = SCN_KEY                   //2005
         //FWLOG cChar, "SCN_KEY"
      case nCode = SCN_DOUBLECLICK           //2006
         //nPos       := ::GetCurrentPos()  //::nPos64
         //nLine      := ::nLine()
         //? ::Send( SCI_GETCHARAT, nPos, )
         cText  := ::GetSelText()
         if !Empty( nPoints := RAt( ":", cText ) ) .and. ;
            Empty( At( "(", cText ) ) 
            if nPoints > 2
               //? 1
            endif
         endif
      case nCode = SCN_UPDATEUI              //2007
         //FWLOG "SCN_UPDATEUI"
         ::UpdateUI()
      /*     
      case nCode = SCN_MODIFIED              //2008
           //FWLOG cChar, "SCN_MODIFIED", nMod, ::cWritten, nLine, ::GetLine( ::GetCurrentLine() )
           Do Case
              Case nMod = 18 //HexToDec( nOr( SC_MOD_DELETETEXT, SC_PERFORMED_USER ) )
                   //FWLOG cChar, "SCN_MODIFIED DELETETEXT", nMod
              Case nMod = 8210 //HexToDec( SC_MOD_DELETETEXT + SC_PERFORMED_USER + SC_STARTACTION )
                   //FWLOG cChar, "SCN_MODIFIED DELETETEXT", nMod              
           EndCase
      */
      case nCode = SCN_MACRORECORD           //2009
           //FWLOG nMess, nWPar, nLPar, cPText
      case nCode = SCN_MARGINCLICK           //2010
           nMargen  := ::nMargen
           nPos     := ::nPos64
           ::MarginClick( nMargen, nPos )
      case nCode = SCN_NEEDSHOWN             //2011
      case nCode = SCN_PAINTED               //2013
         //FWLOG "SCN_PAINTED"
      case nCode = SCN_USERLISTSELECTION     //2014
           Do Case
              Case nList = 1
              
           EndCase
           nIndex   := ::Send( SCI_AUTOCGETCURRENT, 0, 0 )
           if !Empty( nIndex )
              aLines   := HB_ATokens( ::cListAutoc, " " )
              cFunc    := Left( aLines[ nIndex + 1 ], ;
                                At( "?", aLines[ nIndex + 1 ] ) - 1 )
              ::InsertChars( cFunc, , , )
              //::GotoPos( ::Send( SCI_AUTOCPOSSTART, 0, 0 ) + 1 + Len( cFunc ) )
              //FWLOG ::Send( SCI_AUTOCGETCURRENTTEXT,, @cFunc ), cFunc, nList
           endif
      /*
      case nCode = SCN_DWELLSTART            //2016
           //SCI_SETMOUSEDWELLTIME(int milliseconds)
      case nCode = SCN_DWELLEND              //2017
      case nCode = SCN_ZOOM                  //2018
      case nCode = SCN_HOTSPOTCLICK          //2019
      case nCode = SCN_HOTSPOTDOUBLECLICK    //2020
      case nCode = SCN_CALLTIPCLICK          //2021
      case nCode = SCN_AUTOCSELECTION        //2022
      case nCode = SCN_INDICATORCLICK        //2023
      case nCode = SCN_INDICATORRELEASE      //2024
      case nCode = SCN_AUTOCCANCELLED        //2025
      case nCode = SCN_AUTOCCHARDELETED      //2026
      case nCode = SCN_HOTSPOTRELEASECLICK   //2027
      */
      
      case nCode = SCN_FOCUSIN               //2028
      
      case nCode = SCN_FOCUSOUT              //2029
           //? "OUT"
      //case nCode = SCN_AUTOCCOMPLETED        // == SCN_AUTOCSELECTION ?

      Otherwise
   endcase

return nil

//----------------------------------------------------------------------------//

METHOD SysCommand( nType, nLoWord, nHiWord ) CLASS TScintilla

   local oWnd

   ( nHiWord )

   do case
      case nType == SC_KEYMENU
           do case
              case nLoWord == Asc( "i" ) .or. nLoWord == Asc( "I" )
                   oWnd = WndMain()
                   if oWnd:oMsgBar != nil .and. ;
                      oWnd:oMsgBar:oKeyIns != nil
                      oWnd:oMsgBar:oKeyIns:lActive = ;
                         ( ::Send( SCI_GETOVERTYPE ) == 1 )
                      oWnd:oMsgBar:oKeyIns:bMsg = nil
                      oWnd:oMsgBar:Refresh()
                   endif
                   ::Send( SCI_EDITTOGGLEOVERTYPE )

              case nLoWord == Asc( "l" ) .or. nLoWord == Asc( "L" )
                   if ::GetSelectionEnd() - ::GetSelectionStart() > 0
                      ::SetSel( ::nCurrentPos, ::nCurrentPos )
                   else
                      ::nCurrentPos = ::GetCurrentPos()
                      ::SetSel( ::PositionFromLine( ::nLine() - 1 ),;
                                ::PositionFromLine( ::nLine() + 1 ) - 1 )
                   endif

              case nLoWord == Asc( "c" ) .or. nLoWord == Asc( "C" )
                   if Empty( ::Send( SCI_GETMOUSESELECTIONRECTANGULARSWITCH ) )
                      ::Send( SCI_SETMOUSESELECTIONRECTANGULARSWITCH, 1, 0 )
                      ::Send( SCI_SETSELECTIONMODE, SC_SEL_RECTANGLE, 0 )
                   else
                      ::Send( SCI_SETMOUSESELECTIONRECTANGULARSWITCH )
                      ::Send( SCI_SETSELECTIONMODE, SC_SEL_STREAM, 0 )
                   endif

              otherwise

           endcase
   endcase

return nil

//----------------------------------------------------------------------------//

METHOD SetToggleMark( nL, nAdd, nColor ) CLASS TScintilla

   local lSw       := .F.
   local nLine     := ::GetCurrentLine()
   local nPos
   DEFAULT nL      := 0
   DEFAULT nAdd    := 0
   DEFAULT nColor  := 0

   if !Empty( nL )
      nLine := nL - 1
   endif

   if ::Send( SCI_MARKERGET, nLine ) == 0  //.or.

      if !Empty( nColor )
         ::Send( SCI_MARKERSETBACK, SC_MARK_SHORTARROW, nColor )
      endif
      ::Send( SCI_MARKERDEFINE, 1, nAnd(SC_MARK_BACKGROUND, ::nMarker) )
      /*
      // Esto resalta la linea, no crea marca en el margen
      ::Send( SCI_MARKERDEFINE, 1, SC_MARK_BACKGROUND )
      // El color dependera de lo que queremos
      ::Send( SCI_MARKERSETBACK, 1, CLR_HRED )
      */
      if Empty( nAdd )
         AAdd( ::aMarkerHand, ::Send( SCI_MARKERADD, nLine, 1 ) )
         AAdd( ::aBookMarker, nLine + 1 )
      else
         ::Send( SCI_MARKERADD, nLine, 1 )
      endif
      lSw := .T.
   else
      ::Send( SCI_MARKERDELETE, nLine, 1 )
      if Empty( nAdd )
         nPos := AScan( ::aBookMarker, nLine + 1 )
         if !Empty( nPos )
            ADel( ::aBookMarker, nPos )
            ASize( ::aBookMarker, Len( ::aBookMarker ) - 1 )
            ::Send( SCI_MARKERDELETEHANDLE, ::aMarkerHand[ nPos ] )
            ADel( ::aMarkerHand, nPos )
            ASize( ::aMarkerHand, Len( ::aMarkerHand ) - 1 )
         else
            ::Send( SCI_MARKERDELETE, nLine, 2 )
            nPos := AScan( ::aPointBreak, nLine+1 )
            if !Empty( nPos )
               ADel( ::aPointBreak, nPos )
               ASize( ::aPointBreak, Len( ::aPointBreak ) - 1 )
            endif
         endif
      endif
   endif

   if !Empty( ::oMarkPnel )
      ::oMarkPnel:aArrayData := ::aBookMarker  //SetArray( ::aBookMarker )
      ::oMarkPnel:Refresh()
      //::SetFocus()
   endif

Return lSw

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

METHOD GetCurrentLine() CLASS TScintilla

   local nCurrentPos := ::Send( SCI_GETCURRENTPOS )
   local nLine       := ::Send( SCI_LINEFROMPOSITION, nCurrentPos )

Return nLine

//----------------------------------------------------------------------------//

METHOD CharAdded( nPos, nLine, cChar ) CLASS TScintilla

   local uRet         := -1
   local nCurrent
   local nOldCurrent

   ( nPos )

   if !::GetReadOnly()
   Do Case
      Case cChar == 8
          //FWLOG ::cWritten
          if !Empty( ::cWritten )
             ::cWritten := Left( ::cWritten, Len( ::cWritten ) - 1 )
          else
             ::cWritten := ""
          endif
      Case cChar == VK_TAB
          ::cWritten  := ""
          ::SetFocus()

      Case cChar == 13
          //::ActBooks( nLine, .T., 1 )
         if ::lFoundToken
            if ! Empty( ::cFoundToken )
               //if ::CallTipActive()
                  //nCurrent = ::GetCurrentPos() - 1
                  nCurrent     := ::Send( SCI_CALLTIPPOSSTART, 0, 0 ) - 1
                  nOldCurrent  := nCurrent
                  WHILE ::ValidChar( cChar := ::GetTextAt( nCurrent ) )
                     nCurrent--
                  END
                  if nCurrent < nOldCurrent
                     nOldCurrent := nOldCurrent - nCurrent
                  else
                     nOldCurrent := 0
                  endif
                  ::GotoPos( nCurrent )
                  //::SetSel( nCurrent + 1, ::GetCurrentPos() + 3 + Len( ::cWritten ) + nOldCurrent )
                  ::SetSel( nCurrent + 1, ::GetCurrentPos() + 3 + nOldCurrent )
                  ::ReplaceSel( ::cFoundToken )
               //endif
               ::cFoundToken := NIL
               ::CallTipCancel()
            else
               ::AutoIndent()
            endif
         else
            ::AutoIndent()
         endif
         ::cWritten := ""

     
      Case cChar = 32
         //if ! Empty( ::cFoundToken := ::FindToken( -1 ) )
         //   FWLOG ::cFoundToken
         //   ::cFoundToken   := Nil
         //endif
         /*
               if ! Empty( ::cFoundToken := ::FindToken( -1 ) )
                  ::nTokenPos := ::GetCurrentPos()
                  ::CallTipShow( ::nTokenPos, ::cFoundToken )
               else
                  ::CallTipCancel()
                  ::nTokenPos  := 0
               endif
         */
         ::cWritten := ""

      Otherwise
         if ::lFoundToken
            if cChar != 10
               if ! Empty( ::cFoundToken := ::FindToken() )
                  ::nTokenPos := ::GetCurrentPos()
                  ::CallTipShow( ::nTokenPos, ::cFoundToken )
               else
                  ::CallTipCancel()
                  ::nTokenPos  := 0
               endif
            endif
         endif
         if ( cChar >= 48 .and. cChar <= 58 ) .or. ;
            ( cChar >= 65 .and. cChar <= 90 ) .or. ;
            ( cChar >= 97 .and. cChar <= 122 )
            ::cWritten += Chr( cChar ) //nKey )
         else
            if cChar == 40 //.or. cChar == 41
               //if ! Empty( ::cFoundToken := ::FindToken( -1 ) )
               //   FWLOG ::cFoundToken
               //endif
               if ::lTipFunc
                  ::TipShow( cChar, nLine + 1, 0 )
               endif
            endif
         endif
         if !::lFoundToken  //Empty( ::nTokenPos ) .and. 
            if ::cWritten = "::"
               if !Empty( ::cListAutoc )
                  ::Send( SCI_AUTOCSHOW, 0, ::cListAutoc )
                  ::cWritten := ""
               endif
            else
               if ( Right( ::cWritten, 1 ) = ":" .and. ;
                  ::ValidChar( ::GetTextAt( ::GetCurrentPos() - 2 ) ) )
                  //::Send( SCI_AUTOCSETAUTOHIDE, 0, 0 )
                  ::Send( SCI_AUTOCSHOW, 0, ::cListAutoc )
                  //::Send( SCI_USERLISTSHOW, 1, ::cListAutoc )
                  //::Send( SCI_AUTOCSETAUTOHIDE, 1, 0 )
                  ::cWritten := ""
               endif
            endif
         endif
   EndCase
   else
      MsgInfo( "File Read-Only", "Attention" )
      ::SetFocus()
   endif
   
Return uRet

//----------------------------------------------------------------------------//

METHOD GetWord( lTip, lMove, lCopy ) CLASS TScintilla

   local nCurrent
   local nOldCurrent
   local cText       := ""
   local cChar
   DEFAULT lTip      := .F.
   DEFAULT lMove     := .F.
   DEFAULT lCopy     := .F.
   
   nCurrent := ::GetCurrentPos() - 1
   if lTip
      nCurrent := ::Send( SCI_CALLTIPPOSSTART, 0, 0 ) - 1
   endif
   nOldCurrent := nCurrent
   nCurrent--
   WHILE ::ValidChar( cChar := ::GetTextAt( nCurrent ) )
      if !lCopy 
         cText := cChar + cText
      endif
      nCurrent--
   END
   if lMove
      ::GotoPos( nCurrent )
   endif
   if lCopy
      ::SetSel( nCurrent + 1, nOldCurrent ) // + Len( ::cWritten ) )
      cText := ::GetSelText()
   endif
   cText := StrTran( cText, CRLF, "" )

Return cText

//----------------------------------------------------------------------------//

METHOD MarginClick( nMargen, nPos ) CLASS TScintilla

  local nLine
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

METHOD UpdateUI() CLASS TScintilla

   local nPos
   local nAt

   
   if !Empty( ::oUndo )
      ::oUndo:Refresh()
   endif
   if !Empty( ::oRedo )
      ::oRedo:Refresh()
   endif
   
   if !Empty( ::oModify )
      ::oModify:SetText( FWString( "File has changed" ) + ;
          iif( ::lModified, " " + ": YES" + " ", ;    //IIF( ::GetModify(),
               " " + ": NO" + " " ) )
   endif
   ::SetGetAnota( .F. )
   if ::oRowItem != nil
      ::oRowItem:SetText( "Row: " + AllTrim( Str( ::nLine() ) ) )
   endif
   if ::oColItem != nil
      ::oColItem:SetText( "Col: " + AllTrim( Str( ::nCol() ) ) )
   endif

   nPos = ::GetCurrentPos()
   if Chr( ::GetCharAt( nPos ) ) $ "([{}])"
      if ( nAt := ::BraceMatch( nPos ) ) != -1
         ::BraceHighLight( nPos, nAt )
      else
         ::BraceBadLight( nPos, nAt )
      endif
   endif
   if ::bChange != nil
      Eval( ::bChange, Self )
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD TipoMonitor() CLASS TScintilla
local nAncho
local nTipoMonitor
      nAncho := GetSysMetrics( 0 )
      Do Case
      Case nAncho >= 800  .and. nAncho <  1100
           nTipoMonitor  := -2
      Case nAncho >= 1100 .and. nAncho <  1360
           nTipoMonitor := -1
      Case nAncho >= 1360 .and. nAncho <= 1400  // 1366
           nTipoMonitor := 0
      Case nAncho > 1400 .and. nAncho < 1700   // 1600
           nTipoMonitor := 1
      Case nAncho >= 1700   //1920
           nTipoMonitor := 2
      EndCase
      ::nTpMonitor   := nTipoMonitor
Return nTipoMonitor

//----------------------------------------------------------------------------//

METHOD SetZoomBar( nZ ) CLASS TScintilla

   local  nZoomFactor := ::Send( SCI_GETZOOM, 0, 0 )
   DEFAULT nZ  := 0
   if !empty( ::GetText() )
      if nZ > -11 .and. nZ < 21
         ::Send( SCI_SETZOOM, nZ, 0 )
      endif
      nZoomFactor := ::Send( SCI_GETZOOM, 0, 0 )
   endif

Return nZoomFactor

//----------------------------------------------------------------------------//

METHOD RefreshZoom( nVar, oBtt, lPaint ) CLASS TScintilla

   local nPorcent  := ( nVar + 10 ) * 10
   DEFAULT oBtt    := ::oZoom
   DEFAULT lPaint  := .T.

   if nPorcent  = 0
      nPorcent := 10
   endif
   if !Empty( oBtt )
      oBtt:SetText("Zoom: " + AllTrim( Str( nPorcent ) )+"%" )
   endif
   if lPaint
      ::SetZoomBar( nVar ) // Actualiza el zoom de scintilla en ButtonBar
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD CaracterSet( nOp, lIni, nC ) CLASS TScintilla

   local nCar
   local aChars   := {;
      { "SC_CHARSET_ANSI", 0 }    , { "SC_CHARSET_DEFAULT", 1 }, ;
      { "SC_CHARSET_BALTIC", 186 }, { "SC_CHARSET_CHINESEBIG5", 136 }, ;
      { "SC_CHARSET_EASTEUROPE", 238 }, { "SC_CHARSET_GB2312", 134 }, ;
      { "SC_CHARSET_GREEK", 161 }, { "SC_CHARSET_HANGUL", 129 }, ;
      { "SC_CHARSET_MAC", 77 }, { "SC_CHARSET_OEM", 255 }, ;
      { "SC_CHARSET_RUSSIAN", 204 }, { "SC_CHARSET_CYRILLIC", 1251 }, ;
      { "SC_CHARSET_SHIFTJIS", 128 }, { "SC_CHARSET_SYMBOL", 2 }, ;
      { "SC_CHARSET_TURKISH", 162 }, { "SC_CHARSET_JOHAB", 130 }, ;
      { "SC_CHARSET_HEBREW", 177 }, { "SC_CHARSET_ARABIC", 178 }, ;
      { "SC_CHARSET_VIETNAMESE", 163 }, { "SC_CHARSET_THAI", 222 }, ;
      { "SC_CHARSET_8859_15", 1000 }, { "SC_CP_UTF8", 65001 } }
      //{ "SC_CP_ANSI", 0 } ;      // Este me lo he inventado yo

   DEFAULT nOp    := 0
   DEFAULT lIni   := .F.
   DEFAULT nC     := 0

   if Empty( nC )
      if !lIni
         if Empty( nOp )
            ::Send( SCI_SETCODEPAGE, SC_CHARSET_DEFAULT, 0 )    //ANSI
         else
            //::Send( SCI_SETCODEPAGE, aCarSets[ nOp ], 0 )
            ::Send( SCI_SETCODEPAGE, nOp, 0 )
         endif
      else
         ::Send( SCI_SETCODEPAGE, nOp, 0 )
      endif
      nCar := ::Send( SCI_GETCODEPAGE, 0, 0 )
   else
      nCar := aChars
   endif

Return nCar

//----------------------------------------------------------------------------//

/*
UTF-8                EF BB BF Ã¯Â»Â¿            239 187 191
UTF-16 Big Endian    FE FF    Ã¾Ã¿             254 255
UTF-16 Little Endian FF FE    Ã¿Ã¾             255 254
*/

METHOD DocIsUtf8( cDoc, lUtf8 ) CLASS TScintilla

   local cCad     := Chr( 239 ) + Chr( 187 ) + Chr(191)
   local cCad1    := Chr( 255 ) + Chr( 254 )
   local cCad2    := Chr( 254 ) + Chr( 255 )
   local cText
   DEFAULT lUtf8  := .F.
   if Empty( cDoc )
      cText  := ::GetLine( 0 )
      if Left( cText, 3 ) == cCad
         ::lUtf8  := .T.
         ::lBom   := .T.
      else
         if Left( cDoc, 2 ) = cCad1 .or. Left( cDoc, 2 ) = cCad2
            ::lUtf16 := .T.
            ::lUtf8  := .T.
            ::lBom   := .T.
            if Left( cDoc, 2 ) = cCad2
               ::lBig   := .T.
            endif
         else
            if !lUtf8
               ::lUtf8  := IsUtF8( cDoc )
            else
               ::lUtf8  := .T.
            endif
            ::lBom   := .F.
         endif
      endif
   else
      if Left( cDoc, 3 ) == cCad
         ::lUtf8  := .T.
         ::lBom   := .T.
      else
         if Left( cDoc, 2 ) = cCad1 .or. Left( cDoc, 2 ) = cCad2
            ::lUtf16 := .T.
            ::lUtf8  := .T.
            ::lBom   := .T.
            if Left( cDoc, 2 ) = cCad2
               ::lBig   := .T.
            endif
         else
            ::lUtf8  := IsUtF8( cDoc )
            ::lBom   := .F.
         endif
      endif
   endif

Return ::lUtf8

//----------------------------------------------------------------------------//

METHOD SetMBrace() CLASS TScintilla

   ::Send( SCI_STYLESETFORE, STYLE_BRACELIGHT, ::cCBraces[ 1 ] ) //YELLOW
   ::Send( SCI_STYLESETBACK, STYLE_BRACELIGHT, ::cCBraces[ 2 ] ) //::nCaretBackColor )
   ::Send( SCI_STYLESETFORE, STYLE_BRACEBAD, ::cCBraceBad[ 1 ] ) //CLR_HRED )
   ::Send( SCI_STYLESETBACK, STYLE_BRACEBAD, ::cCBraceBad[ 2 ] ) //::nCaretBackColor )
   //::Send( SCI_BRACEHIGHLIGHTINDICATOR, 1, 1 )
   //::Send( SCI_BRACEBADLIGHTINDICATOR, 1, 1 )

Return nil

//----------------------------------------------------------------------------//
/*
METHOD RButtonDown( nRow, nCol, nKeyFlags ) CLASS TScintilla
local nOpc
local nLine
local nPos

   //nPos   := ::Send( SCI_POSITIONFROMPOINT, nCol, nRow )
   //if !empty( nPos )
      //nLine  := ::Send( SCI_LINEFROMPOSITION, nPos, 0 )
      //if !Empty( nLine )
      //   ::GotoLine( nLine + 1 )
      //   //::GotoPos( ::Send( SCI_POSITIONFROMLINE, nLine, 0 ) )
      //endif
   //endif
   nOpc      := ::NumMargen( nRow, nCol, nKeyFlags )
   ::nMargen := nOpc
   if nOpc <= 5 .and. nOpc >= 0
      if ::lMnuMargen
         ::MnuMargen( nRow, nCol, nKeyFlags, nOpc )
      endif
   else
      ::MnuMargen( nRow, nCol, nKeyFlags, nOpc )
      //Return 1
   endif

   if ::bRClicked != nil
      Return Eval( ::bRClicked, nRow, nCol, nKeyFlags, Self )
   endif

Return nil //::Super():RButtonDown( nRow, nCol, nKeyFlags ) //nil //1
*/
//----------------------------------------------------------------------------//

METHOD LButtonDown( nRow, nCol, nKeyFlags, lTouch ) CLASS TScintilla

   ::SetCursor( -1 )
   ::Send( SCI_BRACEHIGHLIGHT, -1, 0 )
   ::Send( SCI_BRACEBADLIGHT, -1, 0 )
   ::SetOldPos()

   ::nPos64  := ::Send( SCI_POSITIONFROMPOINT, nCol, nRow)
   ::nMargen := -1
   ::nMargen := ::NumMargen( nRow, nCol, nKeyFlags )
   if ::bLClicked != nil
      Return Eval( ::bLClicked, nRow, nCol, nKeyFlags, Self, lTouch )
   endif

Return nil //::Super():LButtonDown( nRow, nCol, nKeyFlags, lTouch )

//----------------------------------------------------------------------------//

METHOD NumMargen( nRow, nCol, nKeyFlags ) CLASS TScintilla

   local nTotMarg := ( ::nMargLines + ::nMargSymbol + ::nMargFold + ::nMargText + ::nMargBuild)
   local nOpc     := -1

   ( nRow, nKeyFlags )

   if nCol <= ::nMargLines
      // AÃ±adir linea a lineas sin posibilidad de modificacion aLinReadOnly
      nOpc := 0
   else
      if nCol > ::nMargLines .and. nCol <=  (::nMargLines + ::nMargSymbol)
         nOpc := 1
      else
         if nCol >  ( ::nMargLines + ::nMargSymbol ) .and. ;
            nCol <= ( ::nMargLines + ::nMargSymbol + ::nMargFold )
            nOpc := 2
         else
          if nCol >  ( ::nMargLines + ::nMargSymbol + ::nMargFold ) .and. ;
            nCol <= ( ::nMargLines + ::nMargSymbol + ::nMargFold + ::nMargText )
            nOpc := 3
          else
            if nCol >  ( ::nMargLines + ::nMargSymbol + ::nMargFold + ::nMargText ) .and. ;
               nCol <= ( ::nMargLines + ::nMargSymbol + ::nMargFold + ::nMargText + ::nMargBuild )
               nOpc := 4
            else
               if nCol < nTotMarg
                  nOpc := 5
               endif
            endif
          endif
         endif
      endif
   endif

Return nOpc

//----------------------------------------------------------------------------//

METHOD MnuMargen( nRow, nCol, nKeyFlags, nMarg ) CLASS TScintilla

   local oMnu
   local nPos
   local cText   := Space( 40 )

   ( nKeyFlags )

      //::GoToLine( ::nLine() )
      MENU oMnu POPUP COLORS //OF Self
         oMnu:l2007    := ( ::nMnuStyle == 2007 )
         oMnu:l2010    := ( ::nMnuStyle == 2010 )
         oMnu:l2013    := ( ::nMnuStyle == 2013 )
         oMnu:l2015    := ( ::nMnuStyle == 2015 )
        if nMarg < 0
         ::MenuEdit( .T. )
        else
         MENUITEM "Search Selection"
            MENU
               MENUITEM "At Document" ;
                  WHEN ( oMenuItem, !Empty(::GetSelText()) ) ;
                  ACTION ( oMenuItem, ::NoImplemented() ) ;
                  RESOURCE "find16"   //zoom16
               SEPARATOR
               MENUITEM "At WEB" ;
                  WHEN ( oMenuItem, !Empty(::GetSelText()) ) ;
                  ACTION ( oMenuItem, ::NoImplemented() ) ;
                  RESOURCE "find16"   //zoom16
            ENDMENU
         SEPARATOR
         MENUITEM "Return to Previous Position" ; //+ Chr( 9 ) + "Ctrl+ " ;
                  WHEN ( oMenuItem, ::nOldPos > 0 ) ;
                  ACTION ( oMenuItem, ::GotoOldPos() )  //;
                  //ACCELERATOR ACC_CONTROL, 9
         MENUITEM "Line Duplicate" + Chr(9) + "F5";
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  ACTION ( oMenuItem, ::Lineduplicate() ) ;
                  RESOURCE "dupline16"
         MENUITEM FWString( "Code &separator" ) + Chr( 9 ) + "F4" ;
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  ACTION ( oMenuItem, ::LineSep() ) ;
                  RESOURCE "Comment" ;
                  ACCELERATOR 0, VK_F4
         MENUITEM "Current Line" ;
                  RESOURCE "goto16" ; //"Next2" ;
                  WHEN ( oMenuItem, nMarg = 0 )
            MENU
               MENUITEM "Select Line" ;
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  ACTION ( oMenuItem, ::SelectLine() ) ;
                  RESOURCE "Goto16"
               SEPARATOR
               MENUITEM "Line Transpose" ;
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  ACTION ( oMenuItem, ::LineTranspose() ) ;
                  RESOURCE "replace16"
               SEPARATOR
               MENUITEM "Increase Indent" ;
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  ACTION ( oMenuItem, ::InsertTab() ) ;
                  RESOURCE "code16"  //"IIncre"
               MENUITEM "Decrease Indent" ;
                  ACTION ( oMenuItem, ::Backtab() )  ;
                  WHEN ( oMenuItem, nMarg = 0 ) //;
                  //RESOURCE "IDecre"
               //MENUITEM "Cambiar Modo Normal/Solo Lectura" ;
               //   WHEN nMarg = 0 ;
               //   ACTION ::NoImplemented() //;
                  //RESOURCE "Option"
               MENUITEM "Marks Comments" ;
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  ACTION ( oMenuItem, ::InsertChars( "//", 0 ) ) ;
                  RESOURCE "Comment16"
               MENUITEM "Remove Marks Comments" ;
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  ACTION ( oMenuItem, ::DesComment() ) ;
                  RESOURCE "Empty16" //"Empty"
            ENDMENU
         MENUITEM "Line(s) Select(s)" ;
                  RESOURCE "dlgsmal" ; //"Combo" ;
                  WHEN ( oMenuItem, !Empty(::GetSelText()) ) //nMarg = 0
            MENU
               MENUITEM "Format code" ;
                  ACTION ( oMenuItem, ::SetFmtCode() ) ;
                  WHEN ( oMenuItem, !Empty(::GetSelText()) ) ;
                  RESOURCE "code16"
               SEPARATOR
               MENUITEM "Increase Indent" ;
                  ACTION ( oMenuItem, ::InsertTab( .T. ) ) ;
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  RESOURCE "code16"  //"IIncre"
               MENUITEM "Decrease Indent" ;
                  ACTION ( oMenuItem, ::Backtab() ) ;
                  WHEN ( oMenuItem, nMarg = 0 ) //;
                  //RESOURCE "IDecre"
               
               MENUITEM "Comment" ;
                  ACTION ( oMenuItem, ::InsertChars( "//", 0, .F., .T. ) ) ;
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  RESOURCE "Comment16"
               MENUITEM "Remove Comment" ;
                  ACTION ( oMenuItem, ::DesComment( .T. ) ) ;
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  RESOURCE "Empty16"   //"Empty"
            
            ENDMENU
         
         SEPARATOR
         MENUITEM "Transform Upper./Lower." ;
                  WHEN ( oMenuItem, nMarg = 0 ) RESOURCE "Label"
            MENU
               MENUITEM "Lowercase -> Upper." ;
                  ACTION ( oMenuItem, ::MinMay() ) ;
                  WHEN ( oMenuItem, nMarg = 0 ) RESOURCE "Label"
               MENUITEM "Uppercase -> Lower." ;
                  ACTION ( oMenuItem, ::MayMin() ) ;
                  WHEN ( oMenuItem, nMarg = 0 ) RESOURCE "Edit16"
               MENUITEM "Invert Upper./Lower" ;
                  ACTION ( oMenuItem, ::InvMinMay() ) ;
                  WHEN ( oMenuItem, nMarg = 0 ) RESOURCE "Label"
            ENDMENU
         MENUITEM "Tipo Titulo ( Letter Capital )" ;
                  ACTION ( oMenuItem, ::CapMay() ) ;
                  WHEN ( oMenuItem, nMarg = 0 ) RESOURCE "Text16"
         SEPARATOR
         MENUITEM "Select into [{( )}]" ;
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  ACTION ( oMenuItem, ::SelEntrePar() ) ;
                  RESOURCE "Array16"
         SEPARATOR
         MENUITEM "Remove All Marks " ;
                  WHEN ( oMenuItem, nMarg = 1 ) ;
                  ACTION ( oMenuItem, ::BookmarkClearAll( -1 ) ) ;
                  CHARICON "X"
         MENUITEM "Remove Marks User" ; //"List of Marks" ;
                  WHEN ( oMenuItem, nMarg = 1 ) ;
                  ACTION ( oMenuItem, ::BookmarkClearAll( 1 ) ) ; //ListaFolds( Self ) ) ;
                  HSYSBITMAP 32739
         MENUITEM "Remove Marks Run" ; //"List of Marks" ;
                  WHEN ( oMenuItem, nMarg = 1 ) ;
                  ACTION ( oMenuItem, ::BookmarkClearAll( 2 ) ) ; //ListaFolds( Self ) ) ;
                  HSYSBITMAP 32761
         SEPARATOR
         MENUITEM "Clear Indicators" + Chr( 9 ) + "F7" ;
                  WHEN ( oMenuItem, nMarg = 0 ) RESOURCE "edit16" ;
                  ACTION ( oMenuItem, if( ::lIndicators, ;
                ::Send( SCI_INDICATORCLEARRANGE, 0, ::Send( SCI_GETTEXTLENGTH, 0, 0 ) ), ))
         SEPARATOR
         MENUITEM "Annotations" ;
                  WHEN ( oMenuItem, nMarg = 1 ) RESOURCE "edit16"  //"Option1"
            MENU
               MENUITEM "Active/Deactivate" ;
                  WHEN ( oMenuItem, nMarg = 1 ) ;
                  ACTION ( oMenuItem, ::SetGetAnota()  ) ; //  RESOURCE "yes16"
                  CHECKED
               MENUITEM "Set Annotation" ;
                  WHEN ( oMenuItem, nMarg = 1 .and. ;
                       !Empty(::Send( SCI_ANNOTATIONGETVISIBLE, 0, 0 )) );
                  ACTION ( oMenuItem, if( MsgGet( "Anotacion: "+Str( ::nLine() ), "Texto: ", @cText ),;
                      ::Send( SCI_ANNOTATIONSETTEXT, ::nLine()-1, cText ),"")) ;
                  RESOURCE "edit16"  //"Option1"
               MENUITEM "Remove Annotation" ;
                  WHEN ( oMenuItem, nMarg = 1 ) ;
                  ACTION ( oMenuItem, ::Send( SCI_ANNOTATIONSETTEXT, ::nLine()-1, nil) ) //;
                  //RESOURCE "Option"
               MENUITEM "Remove all Annotations" ;
                  WHEN ( oMenuItem, nMarg >= 0 ) ;
                  ACTION ( oMenuItem, ::Send( SCI_ANNOTATIONCLEARALL, 1, 0 ) ) //;
                  //RESOURCE "New"
               SEPARATOR
               MENUITEM "Annotation: Select Text" ;
                  WHEN( oMenuItem,  nMarg = 1 .and. ;
                       !Empty(::Send( SCI_ANNOTATIONGETVISIBLE, 0, 0 )) );
                  ACTION ( oMenuItem, cText := ::GetSelText() , ;
                  IF( !Empty( cText ), ;
                      ::Send( SCI_ANNOTATIONSETTEXT, ::nLine()-1, cText ),)) ;
                  RESOURCE "paste16"  //"bPaste"
            ENDMENU
         /*
         MENUITEM "Definicion bajo cursor" ;
                  ACTION ( oMenuItem, ::NoImplemented() ) ;
                  WHEN ( oMenuItem, nMarg = 0 ) //;
                  //RESOURCE "Topic"
         */
         SEPARATOR

         //MENUITEM "Indicadores" ;
         //         WHEN nMarg = 1 RESOURCE "edit16"  //"Option1"
         //SEPARATOR

         MENUITEM "Toggle Fold Collapse/Expand" ;
                  WHEN ( oMenuItem, nMarg >= 0 ) ;
                  ACTION ( oMenuItem, ::FoldAllToggle() ) ;
                  RESOURCE "treem1"
         MENUITEM "Fold Collapse All" ;
                  WHEN ( oMenuItem, nMarg >= 0 ) ;
                  ACTION ( oMenuItem, ::FoldAllContract() ) ;
                  RESOURCE "treem16"
         MENUITEM "Fold Expand All" ;
                  WHEN ( oMenuItem, nMarg >= 0 ) ;
                  ACTION ( oMenuItem, ::FoldAllToggle() ) ;
                  RESOURCE "treem1"
         SEPARATOR
         MENUITEM "Remove Text of Margin" ;
                  WHEN ( oMenuItem, nMarg = 3 ) ;
                  ACTION ( oMenuItem, ::Send( SCI_MARGINTEXTCLEARALL, 0, 0 ) ) //;
                  //RESOURCE "New"
         SEPARATOR

         MENUITEM "Add File under current line" ;
                  ACTION ( oMenuItem, ::AddFile( .F. ) ) ;
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  RESOURCE "forms16"  //"bpspacin"
         MENUITEM "Add File to end document" ;
                  ACTION ( oMenuItem, ::AddFile( .T. ) ) ;
                  WHEN ( oMenuItem, nMarg = 0 ) ;
                  RESOURCE "addprg16"  //"AddPrg"
         SEPARATOR
         MENUITEM "Syncronize" ; // WHEN nMarg = 2 ;
                  ACTION ( oMenuItem, ::Send( SCI_COLOURISE, 0, -1 ) ) ;
                  RESOURCE "Setup16"  //"Sincro"
        endif
      ENDMENU

      if nMarg < 0
         nPos   := nCol
      else
      Do Case
         Case nMarg = 0
             nPos := ::nMargLines
         Case nMarg = 1
             nPos := ::nMargLines + ::nMargSymbol
         Case nMarg = 2
             nPos := ::nMargLines + ::nMargSymbol + ::nMargFold
         Case nMarg = 3
             nPos := ::nMargLines + ::nMargSymbol + ::nMargFold + ::nMargText
         Case nMarg = 4
             nPos := ::nMargLines + ::nMargSymbol + ::nMargFold + ::nMargText + ::nMargBuild
         Otherwise
             nPos := ::nMargLines + ::nMargSymbol + ::nMargFold + ::nMargText + ::nMargBuild
      EndCase
      endif

      ACTIVATE POPUP oMnu AT nRow, nPos OF Self:oWnd
      //endif
   //endif

Return oMnu  //nRet

//----------------------------------------------------------------------------//

METHOD MenuEdit( lPopup ) CLASS TScintilla

   local oMnu
   DEFAULT lPopup  := .F.

   if !lPopup
      MENU oMnu
   endif
      MENUITEM "Pos:" + Str( ::GetCurrentPos() ) WHEN ( oMenuItem, .F. ) //SEPARATOR
      SEPARATOR
      MENUITEM FWString( "&Undo" ) + Chr( 9 ) + "Alt+BkSp" ;
         RESOURCE "undo16" WHEN ( oMenuItem, ::CanUndo() ) ;
         ACTION ( oMenuItem, ::Undo() )

      MENUITEM FWString( "&Redo" ) + Chr( 9 ) + "Alt+Shift+BkSp" ;
         RESOURCE "redo16" WHEN ( oMenuItem, ::CanRedo() ) ;
         ACTION ( oMenuItem, ::Redo() )

      SEPARATOR

      MENUITEM FWString( "Cu&t" ) + Chr( 9 ) + "Shift+Del" ;
         RESOURCE "cut16" ;
         ACTION ( oMenuItem, ::Cut() )

      MENUITEM FWString( "&Copy" ) + Chr( 9 ) + "Ctrl+Ins" ;
         RESOURCE "copy16" ;
         ACTION ( oMenuItem, ::Copy() )

      MENUITEM FWString( "&Paste" ) + Chr( 9 ) + "Shift+Ins" ;
         RESOURCE "paste16" ;
         ACTION ( oMenuItem, ::Paste() )

      //MENUITEM FWString( "Delete" )
      SEPARATOR

      MENUITEM FWString( "Select &All" ) + Chr( 9 ) + "F2" ;
         RESOURCE "inspect16" ;
         ACTION ( oMenuItem, ::SelectAll() ) ;
         ACCELERATOR 0, VK_F2
      SEPARATOR
      SEPARATOR
      MENUITEM "Copy Line" WHEN ( oMenuItem, .F. )
      MENUITEM "Paste Line" WHEN ( oMenuItem, .F. )
      SEPARATOR
      MENUITEM "Select Line" ACTION ( oMenuItem, ::SelectLine() ) RESOURCE "Goto16"
      MENUITEM "Line Transpose" ACTION ( oMenuItem, ::LineTranspose() ) RESOURCE "replace16"
      SEPARATOR
      MENUITEM "Transform Upper./Lower." RESOURCE "Label"
         MENU
            MENUITEM "Lowercase -> Upper." ACTION ( oMenuItem, ::MinMay() ) RESOURCE "Label"
            MENUITEM "Uppercase -> Lower." ACTION ( oMenuItem, ::MayMin() ) RESOURCE "Edit16"
            MENUITEM "Invert Upper./Lower" ACTION ( oMenuItem, ::InvMinMay() ) RESOURCE "Label"
         ENDMENU
      MENUITEM "Tipo Titulo ( Letter Capital )" ACTION ( oMenuItem, ::CapMay() ) RESOURCE "Text16"
      SEPARATOR
      MENUITEM "Select into [{( )}]" ACTION ( oMenuItem, ::SelEntrePar() ) RESOURCE "Array16"
      
      SEPARATOR
      SEPARATOR

      MENUITEM "Search Selection" ;
               WHEN ( oMenuItem, !Empty(::GetSelText()) ) ; // nMarg = 0 ;
               ACTION ( oMenuItem, ::DlgFindText( , , .F. ) ) ;
               RESOURCE "find16"

      MENUITEM "Wiki Search Selection" ;  //WHEN !Empty(::GetSelText()) ; 
               ACTION ( oMenuItem, ::DlgFindWiki( , , .T. ) ) ;
               RESOURCE "find16"

      SEPARATOR
      SEPARATOR
      
      MENUITEM "Return to Previous Position" ;
               RESOURCE "undo16" ;
               WHEN ( oMenuItem, ::nOldPos > 0 ) ;
               ACTION ( oMenuItem, ::GotoOldPos() )

      SEPARATOR

      MENUITEM FWString( "Line &Duplicate" ) + Chr( 9 ) + "F5" ;
         RESOURCE "dupline16" ;
         ACTION ( oMenuItem, ::LineDuplicate() ) ;
         ACCELERATOR 0, VK_F5

      MENUITEM FWString( "Code &separator" ) + Chr( 9 ) + "F4" ;
         RESOURCE "comment" ;
         ACTION ( oMenuItem, ::LineSep() ) ;
         ACCELERATOR 0, VK_F4

      if !lPopup
      ENDMENU
      endif

Return oMnu

//----------------------------------------------------------------------------//

METHOD MenuPrint( aBmps, nStyle ) CLASS TScintilla
local oMenu

   DEFAULT nStyle    := 0

   ( aBmps )
   
   MENU oMenu POPUP
      oMenu:l2007    := ( nStyle == 2007 )
      oMenu:l2010    := ( nStyle == 2010 )
      oMenu:l2013    := ( nStyle == 2013 )
      oMenu:l2015    := ( nStyle == 2015 )
      oMenu:SetColors()
      
      MENUITEM "With NÂº Line" ;
            RESOURCE "number16" ;
            ACTION ( oMenuItem, ::Print( ::oFntEdt, ;
              ::cFileName, .T. ), ::oWnd:SetFocus() )
      SEPARATOR
      MENUITEM "Whitout NÂº Line" ;
            RESOURCE "prev16" ;
            ACTION ( oMenuItem, ::Print( ::oFntEdt, ;
               ::cFileName, .F. ), ::oWnd:SetFocus() )
   ENDMENU
   //ACTIVATE POPUP oMenu

Return oMenu

//----------------------------------------------------------------------------//

METHOD LineSep() CLASS TScintilla

   local nPos   := ::GetCurrentPos()
   //::InsertChars( "//" + Replicate( "-", 76 ) + "//", SCI_LINEEND, .T. ) //EXTEND )
   ::InsertText( nPos, "//" + Replicate( "-", 76 ) + "//" + hb_eol() )
   ::GotoLine( ::GetCurrentLine() + 2 )

Return nil

//----------------------------------------------------------------------------//

METHOD InsertChars( cCad, uAction, lEnd, lSel ) CLASS TScintilla

   local nP          := ::Send( SCI_CANPASTE, 0 , 0 )
   local nCurrentPos := ::Send( SCI_GETCURRENTPOS, 0, 0 )
   local lSw         := if( Empty( cCad ) .and. Len( cCad ) < 1, .F., .T. )
   local cCadSel     := ::GetSelText()
   local nStart      := ::Send( SCI_GETSELECTIONSTART, 0, 0 )
   local nEnd        := ::Send( SCI_GETSELECTIONEND, 0, 0 )
   local nLin1       := ::Send( SCI_LINEFROMPOSITION, nStart, 0 ) + 1
   local nLin2       := ::Send( SCI_LINEFROMPOSITION, nEnd, 0 ) + 1
   local x
   //Local nLine        := ::Send( SCI_LINEFROMPOSITION, nCurrentPos )

   DEFAULT cCad      := CRLF
   DEFAULT uAction   := 0
   DEFAULT lEnd      := .F.
   DEFAULT lSel      := .F.

   //if !Empty( nP )   // Ojo como hacemos la insercion: si con copy/paste o comando
   if lSw
      if lEnd
         cCad   := cCad + hb_Eol()
      endif
      if !lSel
         ::Send( SCI_INSERTTEXT, -1, cCad )
      else
         if !Empty( cCadSel )
            For x = nLin1 to nLin2
               ::GoLine( x )
               ::GoHome()
               if x = 1 .and. ( ::lUtf8 .and. ::lBom )
                  if !::lUtf16
                     ::GotoPos( 4 )
                  else
                     ::GotoPos( 3 )
                  endif
               endif
               //::GotoPos( ::Send( SCI_POSITIONFROMLINE, x-1, 0 ) + nCol, 0, 0 )
               ::Send( SCI_INSERTTEXT, -1, cCad )
            Next x
         endif
      endif
   else
      // Ojo, cuando se implemente el array de lineas de solo lectura
      //MsgInfo("No se puede modificar el documento","Fichero Solo Lectura")
   endif
   // Ojo, actualizar lineas de Browses de Funciones, BookMarks, etc
   //::oWnd:SetFocus()
   if !lEnd
      ::GotoPos( nCurrentPos )
   else
      ::GotoPos( nCurrentPos + Len( cCad ) )
   endif

   if !Empty( uAction ) .and. ValType( uAction ) <> "B"
      ::Send( uAction, 0, 0 )
   else
      if ValType( uAction ) = "B"
         Eval( uAction, Self, nP, nCurrentPos, cCad )
      endif
   endif

Return Len( cCad )

//----------------------------------------------------------------------------//

METHOD InsertTab( lSel ) CLASS TScintilla

   local cCad    := ::GetSelText()
   local nStart  := ::Send( SCI_GETSELECTIONSTART, 0, 0 )
   local nEnd    := ::Send( SCI_GETSELECTIONEND, 0, 0 )
   local nLin1   := ::Send( SCI_LINEFROMPOSITION, nStart, 0 ) + 1
   local nLin2   := ::Send( SCI_LINEFROMPOSITION, nEnd, 0 ) + 1
   local x
   DEFAULT lSel := .F.

   if lSel
      if !Empty( cCad )
         For x = nLin1 to nLin2
            ::GoLine( x )
            ::GoHome()
            //::SetCurrentPos()
            ::Tab()
         Next x
      endif
   else
      ::GoHome()
      ::Tab()
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD DesComment( lMulti ) CLASS TScintilla

   local nCurLine := ::GetCurrentLine() + 1
   local cCad     := ::GetLine( nCurLine )
   local cCad1
   local nPos
   local nStart
   local nEnd
   local nLin1
   local nLin2
   local x
   DEFAULT lMulti  := .F.

   if !lMulti
      nStart  := ::GetCurrentPos()
      ::LineEnd()
      nEnd    := ::GetCurrentPos()
      ::SetSel( nStart, nEnd )
      cCad1   := ::GetSelText()
      if !Empty( cCad1 )
         nPos  := At( "//", cCad )
         if !Empty( nPos ) .and. nPos = 1
            cCad1 := Right( cCad1, Len( cCad1 ) - 2 )
            ::ReplaceSel( cCad1 )
         endif
      endif
   else
      cCad1   := ::GetSelText()
      nStart  := ::Send( SCI_GETSELECTIONSTART, 0, 0 )
      nEnd    := ::Send( SCI_GETSELECTIONEND, 0, 0 )
      nLin1   := ::Send( SCI_LINEFROMPOSITION, nStart, 0 ) + 1
      nLin2   := ::Send( SCI_LINEFROMPOSITION, nEnd, 0 ) + 1
      if !Empty( cCad1 )
         For x = nLin1 to nLin2
            ::GoLine( x )
            ::Home()
            ::DesComment( .F. )
         Next x
      endif
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD AddFile( lFin, lHome ) CLASS TScintilla

   local nP          := ::GetReadOnly()    //::Send( SCI_CANPASTE, 0 , 0 )
   local cCad
   local cFile       := cGetFile32( "Program file (*.prg) |*.prg|" + ;
                               "Header file (*.ch) |*.ch|" + ;
                               "Resource file (*.rc) |*.rc|" + ;
                               "Open any file (*.*) |*.*|",;
                               "Select a file to open" )
   DEFAULT lFin      := .F.
   DEFAULT lHome     := .F.
   if !Empty( cFile )
      cCad  := MemoRead( cFile )
      if !Empty( cCad )
         if !nP
            if lFin
               cCad  := CRLF + CRLF + cCad
               ::Send( SCI_APPENDTEXT, Len( cCad ), cCad )
            else
               if !lHome
                  cCad  := CRLF + cCad
                  ::InsertChars( cCad , 0, .T., .F. )
               else
                  cCad  := CRLF + cCad + CRLF + ::GetText()
                  ::SetText( "" )
                  ::GotoLine( 1 )
                  ::InsertChars( cCad , 0, .F., .F. )
               endif
            endif
            ::SetFocus()
         else
            MsgInfo("You not can modify the document","Only Read File")
         endif
      else
         MsgInfo("File is Empty", "Attention")
      endif
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD NextMarker( lVer ) CLASS TScintilla

   local nCurLine     := ::GetCurrentLine() + 1
   local nActLine

   DEFAULT lVer      := .T.

   nActLine := ::Send( SCI_MARKERNEXT, nCurLine, -1 )  //,nMark
   if lVer
      if nActLine > 0
         ::GoLineEnsureVisible( nActLine + 1 )
      else
         ::GoLineEnsureVisible( 1 )
      endif
   endif

Return nActLine

//----------------------------------------------------------------------------//

METHOD PrevMarker( lVer ) CLASS TScintilla

   local nCurLine     := ::GetCurrentLine() + 1
   local nActLine

   DEFAULT lVer      := .T.
   
   if nCurLine > 1
      nCurLine := nCurLine - 2
   else
      nCurLine := ::Send( SCI_GETLINECOUNT, 0, 0 )
   endif
   nActLine := ::Send( SCI_MARKERPREVIOUS, nCurLine, -1 )
   
   if lVer
      if nActLine > 0
         ::GoLineEnsureVisible( nActLine + 1 )
      else
         ::GoLineEnsureVisible( ::Send( SCI_GETLINECOUNT, 0, 0 ) )
      endif
   endif
Return nActLine //nMark

//----------------------------------------------------------------------------//

METHOD GoLineEnsureVisible( nLine ) CLASS TScintilla

   ::Send( SCI_ENSUREVISIBLEENFORCEPOLICY, nLine )
   ::GoToLine( nLine )

Return nil

//----------------------------------------------------------------------------//

METHOD SetGetAnota( lChange ) CLASS TScintilla

   local nOnOff      := ::Send( SCI_ANNOTATIONGETVISIBLE, 0, 0 )
   local lOnOff      := if( Empty( nOnOff ), .F., .T. )
   DEFAULT lChange   := .T.

   if !lOnOff
      if lChange
         ::Send( SCI_ANNOTATIONSETVISIBLE, 2, 0 )
         if !Empty( ::oAnota )
            ::oAnota:SetText( "Annotations are Actives" + ": YES" )
         endif
      else
         if !Empty( ::oAnota )
            ::oAnota:SetText( "Annotations are Actives" + ": NO" )
         endif
      endif
   else
      if lChange
         ::Send( SCI_ANNOTATIONSETVISIBLE, 0, 0 )
         if !Empty( ::oAnota )
            ::oAnota:SetText( "Annotations are Actives" + ": NO" )
         endif
      else
         if !Empty( ::oAnota )
            ::oAnota:SetText( "Annotations are Actives" + ": YES" )
         endif
      endif
   endif

Return lOnOff

//----------------------------------------------------------------------------//

METHOD MinMay() CLASS TScintilla

   local cCad     := ::GetSelText()
   local nStart
   local nEnd

   if Empty( cCad )
      nStart  := ::GetCurrentPos()
      ::LineEnd()
      nEnd    := ::GetCurrentPos()
      ::SetSel( nStart, nEnd )
      cCad     := ::GetSelText()
   endif
   if !Empty( cCad )
      ::ReplaceSel( Upper( cCad ) )
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD MayMin() CLASS TScintilla

   local cCad     := ::GetSelText()
   local nStart
   local nEnd

   if Empty( cCad )
      nStart  := ::GetCurrentPos()
      ::LineEnd()
      nEnd    := ::GetCurrentPos()
      ::SetSel( nStart, nEnd )
      cCad     := ::GetSelText()
   endif
   if !Empty( cCad )
      ::ReplaceSel( Lower( cCad ) )
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD CapMay() CLASS TScintilla

   local cCad     := ::GetSelText()
   local nStart
   local nEnd

   if Empty( cCad )
      nStart  := ::GetCurrentPos()
      ::LineEnd()
      nEnd    := ::GetCurrentPos()
      ::SetSel( nStart, nEnd )
      cCad     := ::GetSelText()
   endif
   if !Empty( cCad )
      cCad := StrCapFirst( cCad )
      //cCad := Upper( Left( cCad, 1 ) ) + Right( cCad, Len( cCad ) - 1 )
      ::ReplaceSel( cCad )
   endif

Return nil

//----------------------------------------------------------------------------//

//SCI_SETOVERTYPE(bool overType)
//SCI_GETOVERTYPE

METHOD InvMinMay() CLASS TScintilla

   local nCurLine := ::GetCurrentLine() + 1
   local cCad     := ::GetSelText()
   local x
   local cChar
   local cCad1    := ""
   if Empty( cCad )
      cCad := ::GetLine( nCurLine )
   endif
   if !Empty( cCad )
      For x = 1 to Len( cCad )
         cChar := SubStr( cCad, x, 1 )
         if Asc( cChar ) >= 65 .and. Asc( cChar ) <= 90
            cCad1 += Chr( Asc( cChar ) + 32 )
         else
            if Asc( cChar ) >= 97 .and. Asc( cChar ) <= 122
               cCad1 += Chr( Asc( cChar ) - 32 )
            else
               if Asc( cChar ) <> 10 .and. Asc( cChar ) <> 13
                  cCad1 += cChar
               endif
            endif
         endif
      Next x
      ::ReplaceSel( cCad1 )
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD SelEntrePar( nTp ) CLASS TScintilla

   local nCurLine := ::GetCurrentLine() + 1
   local cCad     := ::GetLine( nCurLine )
   local cCad1
   local nPos
   local nStart
   local nEnd
   local aSymb    := { {"(",")"}, {"[","]"}, {"{","}"} }
   DEFAULT nTp    := 1

   if nTp > 3
      nTp  := 3
   endif
   nPos    := ::PositionFromLine( nCurLine - 1 )
   nStart  := At( aSymb[ nTp ][ 1 ], cCad )
   if Empty( At( "//", cCad ) )
      nEnd    := RAt( aSymb[ nTp ][ 2 ], cCad )
   else
      nEnd    := At( aSymb[ nTp ][ 2 ], cCad )   
   endif
   ::SetSel( nStart + nPos, nEnd + nPos - 1 )
   //::HideSelection( .T. )
   cCad1   := ::GetSelText()
   ::CopyRange( nStart + nPos, nEnd + nPos - 1 )
   //::HideSelection( .F. )
   //::Send( SCI_CANCEL, 0, 0 )

Return cCad1

//----------------------------------------------------------------------------//

METHOD SelectLine( nLine ) CLASS TScintilla

   local nCurLine := ::GetCurrentLine() + 1
   local nStart
   local nEnd

   if !Empty( nLine )
      ::GotoLine( nLine )
   else
      nLine  := nCurLine - 1
   endif

   nStart    := ::Send( SCI_POSITIONFROMLINE, nLine, 0 )
   //::Send( SCI_SETEMPTYSELECTION, nStart, 0 )
   nEnd      := ::Send( SCI_GETLINEENDPOSITION, nLine, 0 )
   //nEnd      := nStart + ::Send( SCI_LINELENGTH, nLine, 0 )
   ::LineEnd()
   ::SetSel( nStart, nEnd )

Return nil

//----------------------------------------------------------------------------//

METHOD nModColumn() CLASS TScintilla

   local nSw := ::Send( SCI_GETMOUSESELECTIONRECTANGULARSWITCH, 0, 0 )
   if Empty( nSw )
      ::Send( SCI_SETMOUSESELECTIONRECTANGULARSWITCH, 1 , 0 )
      ::Send( SCI_SETSELECTIONMODE, SC_SEL_RECTANGLE , 0 )
   else
      ::Send( SCI_SETMOUSESELECTIONRECTANGULARSWITCH, 0 , 0 )
      ::Send( SCI_SETSELECTIONMODE, SC_SEL_STREAM , 0 )
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD SetMIndent( nSp ) CLASS TScintilla

   DEFAULT nSp  := ::nWidthTab

   ::Send( SCI_SETUSETABS, 0, 0 )
   ::nWidthTab  := nSp
   ::Send( SCI_SETTABWIDTH, ::nWidthTab, 0 )

   //Set autoindentation con 3 spaces
   ::Send( SCI_SETINDENT, ::Send( SCI_GETTABWIDTH, 0, 0 ), 0  )
   ::Send( SCI_SETTABINDENTS, 1, 0  )
   ::Send( SCI_SETBACKSPACEUNINDENTS, 1, 0 )

Return nil

//----------------------------------------------------------------------------//

METHOD SetColorCaret( nColor, lVisible ) CLASS TScintilla

   local nVisible
   DEFAULT nColor    := ::nCaretBackColor
   DEFAULT lVisible  := .T.

   nVisible          := if( lVisible, 1, 0 )
   ::Send( SCI_SETCARETLINEBACK, nColor )
   ::Send( SCI_SETCARETLINEVISIBLE, nVisible )

Return nColor

//----------------------------------------------------------------------------//

METHOD TipShow( cChar, nLine, nMod ) CLASS TScintilla

   local cLine
   local cCad
   local cCad1   := ""
   local nPos1

   DEFAULT cChar := 0
   DEFAULT nMod  := 0

      Do Case
         Case cChar == 40  //
            cLine := ::GetLine( nLine - 1 )
            //cLine := Left( cLine, Len( cLine ) - 2 )
            cCad  :=  SubStr( cLine, RAt( " ", cLine ), ;
                              Len( cLine ) - RAt( " ", cLine ) + 1 )
            Do Case
               Case nMod == 0
                    if !Empty( cCad )
                       cCad1 := FuncHarb( AllTrim( cCad ), Self )
                    endif
            EndCase
            if !empty( cCad1 )
               if !Empty( ::Send( SCI_CALLTIPACTIVE, 0, 0 ) )
                  ::Send( SCI_CALLTIPCANCEL, 0, 0 )
               endif
               nPos1 := ::Send( SCI_POSITIONFROMLINE, nLine, 0 )
               if Len( AllTrim( cCad ) ) > 2
                  ::Send( SCI_CALLTIPSHOW, nPos1 + MLCount( cCad1 ), cCad1 )
                  ::Send( SCI_CALLTIPSETPOSITION, 1, 0 )
                  ::Send( SCI_CALLTIPSETFOREHLT, METRO_BROWN, 0 )
                  ::Send( SCI_CALLTIPSETBACK, CLR_VSBAR, 0 )
                  ::Send( SCI_CALLTIPSETFORE, CLR_VSBAK, 0 )
                  ::Send( SCI_CALLTIPSETHLT, 0, At( "(", cCad1) - 1 )
               endif
            endif

         Case cChar == 41
            //Si el calltip show, cerrar
            if !Empty( ::Send( SCI_CALLTIPACTIVE, 0, 0 ) )
               ::Send( SCI_CALLTIPCANCEL, 0, 0 )
            endif
      EndCase

Return nil

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

METHOD HighlightWord( cText, nIndic ) CLASS TScintilla

    local   n      := 0

    DEFAULT nIndic := 15
    ::Send( SCI_SETINDICATORCURRENT, nIndic, 0 )
    ::Send( SCI_INDICATORCLEARRANGE, 0, ::Send( SCI_GETTEXTLENGTH, 0, 0 ) )

    ::Send( SCI_INDICSETUNDER, nIndic, 1 )
    ::Send( SCI_INDICSETFORE, nIndic, CLR_VSBAK )
    ::Send( SCI_INDICSETOUTLINEALPHA, nIndic, 150 )
    ::Send( SCI_INDICSETALPHA, nIndic, 130 )

    // Search the document
    ::Send( SCI_SETTARGETSTART, 0, 0 )
    ::Send( SCI_SETTARGETEND, ::Send( SCI_GETLENGTH, 0, 0 ), 0 ) //scintilla.TargetEnd = scintilla.TextLength;
    Do While ( ::Send( SCI_SEARCHINTARGET, Len( cText ), cText ) <> -1 )
       // Mark the search results with the current indicator
       ::Send( SCI_INDICATORFILLRANGE, ::Send( SCI_GETTARGETSTART, 0, 0 ), ::Send( SCI_GETTARGETEND, 0, 0 ) - ::Send( SCI_GETTARGETSTART, 0, 0 ))
       // Search the remainder of the document
       ::Send( SCI_SETTARGETSTART, ::Send( SCI_GETTARGETEND, 0, 0 ), 0 ) // scintilla.TargetStart = 0;
       ::Send( SCI_SETTARGETEND, ::Send( SCI_GETLENGTH, 0, 0 ), 0 ) //scintilla.TargetEnd = scintilla.TextLength;
    Enddo

Return n

//----------------------------------------------------------------------------//

METHOD ExecPlugIn( cPl ) CLASS TScintilla

   local aLinPlug  := {}
   local aTemp
   local x

   ::cPlugIn  := cPl
   if !Empty( ::cPlugIn )
      aTemp   := hb_aTokens( ::cPlugIn, CRLF ) //Chr(10) )
      For x = 1 to Len( aTemp ) - 1
         AAdd( aLinPlug, hb_aTokens( AllTrim( aTemp[ x ] ), Chr( 9 ) ) )
         if Len( aTail( aLinPlug ) ) < 3
            AAdd( aTail( aLinPlug ), nil )  //""
         endif
      Next x
      ::SetFocus()
      For x = 1 to Len( aLinPlug )
          //FWLOG x, aLinPlug[ x ][ 1 ], aLinPlug[ x ][ 2 ], aLinPlug[ x ][ 3 ]
          if !Empty( aLinPlug[ x ][ 1 ] )
             ::Send( Val( aLinPlug[ x ][ 1 ] ), ;
                     if( IsAlpha( Left( aLinPlug[ x ][ 2 ], 1 ) ),;
                         aLinPlug[ x ][ 2 ], ;
                         if( !hb_IsNil( aLinPlug[ x ][ 2 ] ),;
                             Val( aLinPlug[ x ][ 2 ] ), nil ) ), ;
                     if( IsAlpha( Left( aLinPlug[ x ][ 3 ], 1 ) ),;
                         aLinPlug[ x ][ 3 ], ;
                         if( !hb_IsNil( aLinPlug[ x ][ 3 ] ),;
                             Val( aLinPlug[ x ][ 3 ] ), nil ) ) )
          endif
      Next x
   endif

Return nil

//----------------------------------------------------------------------------//

METHOD SetFmtCode() CLASS TScintilla

   local nIni    := ::Send( SCI_GETSELECTIONSTART, 0, 0 )
   local nFin    := ::Send( SCI_GETSELECTIONEND,   0, 0 )
   local cLine
   local cToken
   local x
   //local nLines  := MLCount( cText )
   local nL
   local nL1
   local nIndTot := 1
   local nPos1
   local nIndOld

   nL    := ::Send( SCI_LINEFROMPOSITION, nIni, 0 ) + 1
   nL1   := ::Send( SCI_LINEFROMPOSITION, nFin, 0 )
   For x = nL to nL1
      cLine  := ::GetLine( x )
      if !Empty( cLine )
         cToken  := StrTran( StrToken( Upper(cLine), 1 ), CRLF, "" )
         nPos1   := AsCan( ::aIndentChars, { | o | cToken == o[ 1 ] } )
         if !Empty( nPos1 )
            //nIndTot += ::aIndentChars[ nPos1 ][ 2 ]
            nIndTot := ::aIndentChars[ nPos1 ][ 2 ]
         else
            nIndTot := 0
         endif
      endif
      nIndOld := ::Send( SCI_GETLINEINDENTATION, x-1, 0 )
      ::Send( SCI_SETLINEINDENTATION, x, nIndTot * ::nWidthTab + nIndOld )
   Next x

Return nil

//----------------------------------------------------------------------------//

METHOD TexttoArray( cText, cDelim, lSelec, lWord, lSort ) CLASS TScintilla

   local aText     := {}
   local nDelim    := ::Send( SCI_GETEOLMODE, 0, 0 ) //0 -> CRLF
   local cEol      := ""
//   local x
//   local cChar
   DEFAULT lSelec  := .F.
   DEFAULT cText   := if( lSelec, ::GetSelText(), ::GetText() )
   DEFAULT lWord   := .F.
   DEFAULT lSort   := .F.

   if Empty( cDelim )
      Do Case
         Case nDelim = 0
              cEol  := CRLF
         Case nDelim = 1
              cEol  := Chr( 13 )  //CR
         Case nDelim = 2
              cEol  := Chr( 10 )  //LF
      EndCase
      DEFAULT cDelim  := cEol
   endif

   if !Empty( cText )
      if lWord
         cDelim    := " "
      endif
      aText := hb_aTokens( cText, cDelim )
      /*
      For x = 1 to Len( aText )
          aText[ x ]   := AllTrim( aText[ x ] )
          cChar        := Left( aText[ x ], 1 )
          if !::ValidChar( cChar ) .and. ;
             ( cChar != ":" .and. !::ValidChar( Substr( aText[ x ], 2, 1 ) ) )
          //if Empty( aText[ x ] ) .or. aText[ x ] == cDelim .or. ;
          //   aText[ x ] == CRLF .or. aText[ x ] == Chr( 13 ) .or. ;
          //   aText[ x ] == Chr( 10 )
             ADel( aText, x )
             ASize( aText, Len( aText ) - 1 )
          endif
      Next x
      */
      if lSort
         aText := ASort( aText )
      endif
   endif

Return aText

//----------------------------------------------------------------------------//

METHOD NoImplemented() CLASS TScintilla

   MsgInfo( "No Implemented" )
   ::SetFocus()

Return nil

//----------------------------------------------------------------------------//

Function HCadFunction( nOp )

     local nSymbols
     local n
     local aFunc   := {}
     local cCad    := ""
     DEFAULT nOp   := 0
     nSymbols      := __dynsCount()

     for n := 1 to nSymbols
        if __dynsIsFun( n )
           AAdd( aFunc, __dynsGetName( n ) + "()" )
           cCad := __dynsGetName( n ) + " "
        else

        endif
     next

return IF( Empty( nOp ), cCad, aFunc )

//----------------------------------------------------------------------------//

Function FuncHarb( cCad, oEd )

   local x
   local nPos1   := 0
   local cRet    := ""
   local lClass  := .F.
   local n
   DEFAULT cCad  := ""

   /*
   if !Empty( oEd )
      if !oEd:lAddFuncs
        For x = 1 to Len( oEd:aStructs )
          AAdd( aFHb, cFileNoExt( oEd:cFileName ) + " -> " + ;
                      oEd:aStructs[x][2] + " " + oEd:aStructs[x][1] )
          //AAdd( aFHb, oEd:aStructs[x][1] )
        Next x
        if Len( oEd:aStructs ) > 0
           oEd:lAddFuncs  := .T.
        endif
      endif
   endif
   */

   if !Empty( cCad )
      cCad := Left( cCad, Len( cCad ) - 2 )
      if Left( cCad, 1 ) <> ":"
         For x = 1 to Len( aFHb )
            if ( " " + Upper( cCad ) ) $ ( " " + Upper( aFHb[ x ] ) )
               cRet  += aFHb[ x ] //+ CRLF
               nPos1 := x //nPos
               x := Len( aFHb ) + 1
            endif
         Next x
      endif
      if Empty( cRet )
         if !Empty( oEd:oListFunc )
            if Left( cCad, 2 ) == "::"
               cCad   := Right( cCad, Len( cCad ) - 2 )
               lClass := .T.
            else
               if Left( cCad, 1 ) == ":"
                  cCad  := Right( cCad, Len( cCad ) - 1 )
                  lClass := .T.
               endif
            endif
            // Buscar en Listbox
            if !lClass
               For x = 1 to Len( oEd:oListFunc:aArrayData )
                  if Valtype( oEd:oListFunc:aArrayData[ x ][ 3 ] ) = "N"
                     n := 1
                  else
                     n := 3
                  endif
                  if Upper( cCad ) $ Upper( oEd:oListFunc:aArrayData[ x ][ n ] )  //1
                     cRet  += oEd:oListFunc:aArrayData[ x ][ n ] //+ CRLF
                     nPos1 := x
                     x     := Len( oEd:oListFunc:aArrayData ) + 1
                  endif
               Next x
            else
            endif
         endif
      endif
   endif

Return IF( !Empty( nPos1 ), cRet, " " )

//----------------------------------------------------------------------------//

Function ReadFuncHb( cF, nOp )

   local cLine
   local n         := 1
   local aFuncs    := {}
   local cCad      := ""
   local i
   DEFAULT nOp     := 0
   DEFAULT cF := cFilePath( GetModuleFileName( GetInstance() )) + "FuncHarb.ini"

   Do While !Empty( cLine := GetPvProfString( "Harbour", AllTrim(Str(n)), "", cF ))
      AAdd( aFuncs, AllTrim( cLine ) ) //AllTrim( StrToken( cLine, 1, Chr(13) ) ) )
      if Empty( nOp )
         if Left( cLine, 2 ) = "__"
            AAdd( aFuncs, AllTrim( Right( cLine, Len( cLine ) - 2 ) ) )
         endif
      endif
      n++
   Enddo
   if Empty( nOp )
      For i := 1 to Len( aFuncs )
         cCad += Lower( aFuncs[ i ] ) + " "
      Next i
   endif

Return IIF( Empty( nOp ), cCad, aFuncs )

//----------------------------------------------------------------------------//

Function ReadFuncFw( cF, nOp )

   local cLine
   local n         := 1
   local aFuncs    := {}
   local cCad      := ""
   local i
   DEFAULT nOp     := 0
   DEFAULT cF := cFilePath( GetModuleFileName( GetInstance() )) + "FuncFw.ini"

   Do While !Empty( cLine := GetPvProfString( "Fivewin", AllTrim(Str(n)), "", cF ))
      AAdd( aFuncs, AllTrim( cLine ) ) //AllTrim( StrToken( cLine, 1, Chr(13) ) ) )
      n++
   Enddo
   if Empty( nOp )
      For i := 1 to Len( aFuncs )
         cCad += Lower( aFuncs[ i ] ) + " "
      Next i
   endif

Return IIF( Empty( nOp ), cCad, aFuncs )

//----------------------------------------------------------------------------//

Function ReadFuncFwC( cF, nOp )

   local cLine
   local n         := 1
   local aFuncs    := {}
   local cCad      := ""
   local i
   DEFAULT nOp     := 0
   DEFAULT cF := cFilePath( GetModuleFileName( GetInstance() )) + "FuncFwC.ini"

   Do While !Empty( cLine := GetPvProfString( "Fivewin", AllTrim(Str(n)), "", cF ))
      AAdd( aFuncs, AllTrim( cLine ) ) //AllTrim( StrToken( cLine, 1, Chr(13) ) ) )
      n++
   Enddo
   if Empty( nOp )
      For i := 1 to Len( aFuncs )
         cCad += Lower( aFuncs[ i ] ) + " "
      Next i
   endif

Return IIF( Empty( nOp ), cCad, aFuncs )

//----------------------------------------------------------------------------//

Function LoadFHb( cF )

   local cLine
   local n     := 1
   DEFAULT cF  := cFilePath( GetModuleFileName( GetInstance() ) ) + "FuncsHb1.ini"
   aFHb := {}
   Do While !Empty( cLine := GetPvProfString( "Harbour", AllTrim(Str(n)), "", cF ))
      AAdd( aFHb, cLine ) //AllTrim( StrToken( cLine, 1, Chr(13) ) ) )
      n++
   Enddo

Return aFHb

//----------------------------------------------------------------------------//

Function GetLexers( uOp, cFile )

   local aLexers := { ;
       {"  SCLEX_CONTAINER", 0      },;
       {"  SCLEX_NULL", 1           },;
       {"  SCLEX_CPP", 3            },;
       {"  SCLEX_HTML", 4           },;
       {"  SCLEX_XML", 5            },;
       {"  SCLEX_SQL", 7            },;
       {"  SCLEX_CPPNOCASE", 35     },;
       {"  SCLEX_MSSQL", 55         },;
       {"  SCLEX_PHPSCRIPT", 69     },;
       {"  SCLEX_FLAGSHIP", 73      },;
       {"  SCLEX_MYSQL", 89         },;
       {"  SCLEX_FWH", 517          },;
       {"  SCLEX_FWH1", 518         },;
       {"  SCLEX_FWHC", 519         },;
       {"  SCLEX_AUTOMATIC", 1000   } }
   local aExt     := { ;
                      { { "C", "CPP", "CXX", "RC", "H" }, 3 } , ;
                      { { "HTML", "XHTML", "JS" }, 4 }, ;
                      { { "XML", "XAML" }, 5 }, ;
                      { { "SQL" }, 89 }, ;
                      { { "PHP" }, 69 }, ;
                      { { "PRG", "HRB", "CH" }, 519 } ;
                     }
   local aReturns := {}
   local uRet
   local cRet     := ""
   local cExt
   local x
   local y
   DEFAULT cFile  := ""

   if uOp <> Nil .and. Valtype( uOp ) = "N"
      AEVal( aLexers, { | a | AAdd(  aReturns, LTrim(  a[ uOp ]   )  ) } )
   else
      AEVal( aLexers, { | a | AAdd(  aReturns, LTrim(  a[ 1 ]   )  ) } )
      uRet  := Ascan( aReturns, uOp, , , .T.,  )
      if !Empty( uRet )
         cRet   := aLexers[ uRet ][ 2 ]
      endif
      if !Empty( cFile )
         cExt     := Upper( cFileExt( cFile ) )
         For x = 1 to Len( aExt )
             y   := AsCan( aExt[ x ][ 1 ], cExt, , , .T., )
             if !Empty( y )
                cRet   := aExt[ x ][ 2 ]
                x      := Len( aExt ) + 1
             endif
         Next x
      endif
   endif

Return if( empty( uOp ), if( Empty( uRet ), aLexers, uRet ), if( Empty( uRet ), aReturns, cRet ) )

//----------------------------------------------------------------------------//

Function SetMiFont( cInfo )

   local oFn
   local cFn     := StrToken( cInfo, 1, "," )
   local nHFont  := Val( StrToken( cInfo, 3, "," ) )

   cFn     := Left( cFn, Len( cFn ) - 1 )
   cFn     := Substr( cFn, 3, Len( cFn ) )
   DEFINE FONT oFn NAME cFn SIZE 0, -Abs( nHFont )

Return oFn

//----------------------------------------------------------------------------//

Function ChoiceFont( oFnt, cColor, oEd )

   DEFAULT cColor := CLR_WHITE
   DEFAULT oFnt   := oEd:GetFont()

Return oFnt

//----------------------------------------------------------------------------//
/*
function MFontToText( oFont )
   local nPor  := Int( ( oFont:nHeight / 2.54 ) * 2 )
   if nPor > 20
      nPor--
   endif

return FW_ValToExp( { ;
   oFont:cFaceName,, oFont:nInpHeight, .f., oFont:lBold, oFont:nEscapement, ;
   oFont:nOrientation, nil, oFont:lItalic, oFont:lUnderline, oFont:lStrikeOut, ;
   oFont:nCharSet, oFont:nOutPrecision, oFont:nClipPrecision, oFont:nQuality, ;
   nil, oFont:nPitchFamily, oFont:nHeight, oFont:nWidth, -nPor }  )
*/
//----------------------------------------------------------------------------//
