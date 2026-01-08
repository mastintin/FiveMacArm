#include "FiveMac.ch"

function Main()

   local oWnd, oEditor
   
   LogToMyFile( "Main Start" )

   DEFINE WINDOW oWnd TITLE "Scintilla Folding Test" ;
      FROM 200, 200 TO 800, 1000

   oEditor = TScintilla():New( 10, 10, 780, 560, oWnd )
   
   oEditor:SetText( "void main() {" + CRLF + ;
                    "  if (true) {" + CRLF + ;
                    "     printf('hello');" + CRLF + ;
                    "  }" + CRLF + ;
                    "}" )

   ACTIVATE WINDOW oWnd ON INIT CheckMargin( oEditor )

return nil

function CheckMargin( oEditor )
   local nSensitive := oEditor:Send( 2247, 2, 0 ) // SCI_GETMARGINSENSITIVEN
   local nMask      := oEditor:Send( 2245, 2, 0 ) // SCI_GETMARGINMASKN
   
   oEditor:Send( 4003, 0, -1 ) // SCI_COLOURISE(0, -1)
   
   MsgInfo( "Margin 2 Sensitive: " + Str( nSensitive ) + " Mask: " + Str( nMask ) )
return nil

function LogToMyFile( cMsg )
   local hFile := FOpen( "mytest.log", 2 + 16 ) // FO_READWRITE + FO_SHARED
   if hFile == -1
      hFile := FCreate( "mytest.log" )
   endif
   FSeek( hFile, 0, 2 ) // Go to end
   FWrite( hFile, cMsg + CRLF )
   FClose( hFile )
return nil
