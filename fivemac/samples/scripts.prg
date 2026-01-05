#include "FiveMac.ch"
REQUEST TBrush

static oSplitV, oBrw, oMemo, nLastRec := 1
extern DbEval, hbcharacter, hbarray, __ClsAssocType, __ClsInstSuper

function Main()

   local oWnd, oBar
   local cCode := '#include "FiveMac.ch"' + CRLF + CRLF + "function Test()" + CRLF + CRLF + ' MsgInfo( "Hello world!" )' + CRLF + CRLF + "return nil"
   local cfile := path()+"/scripts.dbf"
   local cAlias 

   if ! File( cfile )
      DbCreate( cfile, { { "NAME", "C", 20, 0 }, { "DESCRIPT", "C", 100, 0 }, { "CODE", "M", 80, 0 } } )
   endif 
 
   USE ( cfile )
   cAlias := Alias()

   if RecCount() == 0
      APPEND BLANK
      (cAlias)->Name := "Test"
      (cAlias)->Descript := "This is a test script"
      (cAlias)->Code := cCode
   endif 

   DEFINE WINDOW oWnd

   DEFINE BUTTONBAR oBar OF oWnd

   DEFINE BUTTON OF oBar PROMPT "New" ;
      TOOLTIP "New script" ;
      IMAGE ImgSymbols( "plus", "New script" ) ;
      ACTION New( oBrw, oMemo )

   DEFINE BUTTON OF oBar PROMPT "Save" ;
      TOOLTIP "Save script" ;
      IMAGE ImgSymbols( "externaldrive", "Save" ) ;
      ACTION SaveMemo()

   DEFINE BUTTON OF oBar PROMPT "Execute" ;
      TOOLTIP "Execute the script" ;
      IMAGE ImgSymbols( "play.fill", "Execute" ) ;
      ACTION (SaveMemo(), Execute())

   DEFINE BUTTON OF oBar PROMPT "Quit" ;
      TOOLTIP "Exit this application" ;
      IMAGE ImgSymbols( "xmark.circle", "Quit" ) ;
      ACTION oWnd:End()

 
 @ 21, 0 SPLITTER oSplitV OF oWnd SIZE oWnd:nWidth, oWnd:nHeight - 92 VERTICAL ;
     AUTORESIZE 18 VIEWS 2

    oSplitV:SetPosition( 1, 250 )

   BuildLeft( oSplitV:aViews[ 1 ] )
   BuildRight( oSplitV:aViews[ 2 ] )

   DEFINE MSGBAR OF oWnd PROMPT "FiveMac scripting"

   ACTIVATE WINDOW oWnd MAXIMIZED

return nil

//---------------------------------------------------

Function SaveMemo()
   local cAlias := Alias()
   (cAlias)->( RLock() )
   (cAlias)->code := oMemo:GetText()
   (cAlias)->( DbCommit() )
   (cAlias)->( DbUnlock() )
return nil

//--------------------------------------------------
function BuildLeft( oSplit  )
  local cAlias := Alias()
  local n

 @ 25, 0 BROWSE oBrw  SIZE oSplit:nWidth-2 , oSplit:nHeight-10 OF oSplit ;
      FIELDS (cAlias)->Name, (cAlias)->Descript ;
      HEADERS "Name", "Description" ;
      COLSIZES 150, 300 ;
      ON CHANGE ( oMemo:SetText( "" ),oMemo:Refresh() ,;
         if( Empty((cAlias)->Code),   oMemo:SetText( "" ), SciSetText( oMemo:hWnd, (cAlias)->Code ) ),;
                   oMemo:Refresh() ) ;
      AUTORESIZE nOr( 16, 2 )
    
     /* 
      ON CHANGE ( If( oMemo != nil .and. oMemo:IsModify(), ( n := (cAlias)->( RecNo() ), (cAlias)->( DbGoTo( nLastRec ) ), (cAlias)->Code := oMemo:GetText(), (cAlias)->( DbGoTo( n ) ) ), ),;
                  If( oMemo != nil, ( oMemo:SetText( (cAlias)->Code ), oMemo:Refresh() ), ), nLastRec := (cAlias)->( RecNo() ) ) ;
      AUTORESIZE nOr( 16, 2 )
*/
   oBrw:SetColEditable( 2, .T. )
   oBrw:SetHeadHeight( 40 )
   oBrw:SetBrush( TBrush():New( nRgb( 252, 252, 252 ) ) )


return nil
//---------
function BuildRight( oSplit )

  local cAlias := Alias()
  

   oMemo := TScintilla():New( 0, 0, oSplit:nWidth, oSplit:nHeight-10, oSplit )
   oMemo:nAutoResize := 18
   oMemo:SetText( (cAlias)->Code )
   oMemo:Send( 2130, 0, 0 ) // SCI_SETHSCROLLBAR, 0
   oMemo:Send( 2268, 1, 0 ) // SCI_SETWRAPMODE, SC_WRAP_WORD
   oMemo:SetColor( , nRgb( 252, 252, 252 ) , .t. )
  // oMemo:bChange := {|| msginfo("Change") }
  
return nil
//---------------------------------------------------

function Execute()

   local oHrb, cResult, bOldError
   local cAlias := Alias()
   local cCode := (cAlias)->Code
   local cFivePath := "/Users/manuel/five/Fivemac/fivemac"
   local cHarbourPath := "/Users/manuel/five/Fivemac/harbour"
   
   local cNewCode := StrTran( cCode, "Main", "__Main" )
   local cNewFivepath := StrTran( AllTrim( cFivePath ), "~", UserName() )
   local cNewHarbourpath := StrTran( AllTrim( cHarbourPath ), "~", UserName() )

     BEGIN SEQUENCE
      bOldError = ErrorBlock( { | o | DoBreak( o ) } )
      oHrb = HB_CompileFromBuf( cNewCode,;
                                .T., "-n", "-I" + ;
                                cNewFivepath + "/include",;
                                "-I" + cNewHarbourpath + "/include" )
   END SEQUENCE 
    ErrorBlock( bOldError )
   
   if ! Empty( oHrb )
      BEGIN SEQUENCE
         bOldError = ErrorBlock( { | o | DoBreak( o ) } )
         hb_HrbRun( oHrb )
      END SEQUENCE
      ErrorBlock( bOldError )
   endif
 
return nil

//----------------------------------------------------------------//

static function DoBreak( oError )

   local cInfo := oError:operation, n

   if ValType( oError:Args ) == "A"
      cInfo += "   Args:" + CRLF
      for n = 1 to Len( oError:Args )
         MsgInfo( oError:Args[ n ] )
         cInfo += "[" + Str( n, 4 ) + "] = " + ValType( oError:Args[ n ] ) + ;
                   "   " + cValToChar( oError:Args[ n ] ) + CRLF
      next
   endif

   MsgStop( oError:Description + CRLF + cInfo,;
            "Script error at line: " + Str( ProcLine( 2 ) ) )

   BREAK

return nil

//----------------------------------------------------------------//

function New( oBrw, oMemo )

   local cCode := '#include "FiveMac.ch"' + CRLF + CRLF + "function Test()" + CRLF + CRLF + ' MsgInfo( "Hello world!" )' + CRLF + CRLF + "return nil"
   local cName := "New Script"

   if MsgGet( "New Script", "Name:", @cName )
      APPEND BLANK
      Scripts->Name := cName
      Scripts->Descript := "Description..."
      Scripts->Code := cCode
      oBrw:Refresh()
      oBrw:SetFocus()
      oMemo:SetText( cCode )
   endif

return nil
