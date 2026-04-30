#include "FiveMac.ch"

function Main()

    local oWnd, oGet
    local cGet := "Here is some text to save and load..."
    local cFile := ""
   
    DEFINE WINDOW oWnd TITLE "Word Document Test"  NOFLIPPED ;
        FROM 50, 50 TO 500, 700
      
    @ 20, 20 GET oGet VAR cGet MEMO SIZE 640, 400 OF oWnd
   
    @ 440, 20 BUTTON "Load .docx" OF oWnd ;
        ACTION ( cFile := cGetFile( "Select Word File", "Word (*.docx)|*.docx" ), ;
        If( !Empty( cFile ), TXTREADWORD( oGet:hWnd, cFile, .F. ), nil ) )
               
    @ 440, 160 BUTTON "Save .docx" OF oWnd ;
        ACTION ( cFile := cGetFile( "Save Word File", "Word (*.docx)|*.docx", "Save", "document.docx" ), ;
        If( !Empty( cFile ), TXTWRITEWORD( oGet:hWnd, cFile, .F. ), nil ) )

    ACTIVATE WINDOW oWnd CENTERED
   
return nil
