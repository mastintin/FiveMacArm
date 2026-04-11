#include "FiveMac.ch"

function Main()
    local oWnd, oImage, oGet, cText := "Drop files here...                 

    DEFINE WINDOW oWnd TITLE "Test Drag and Drop"  NOFLIPPED ;
        FROM 200, 200 TO 700, 600 

    @ 20, 20 GET oGet VAR cText SIZE 360, 100 OF oWnd UPDATE
    oGet:EnableDragDrop( .T. )
    oGet:bDropFiles = { | aFiles | ProcessDrop( aFiles, oGet, @cText ) }
   
    @ 140, 20 SAY "Drop an image directly below this line:" OF oWnd SIZE 360, 25

    @ 170, 20 IMAGE oImage SIZE 360, 240 OF oWnd 
    oImage:EnableDragDrop( .T. )
    oImage:bDropFiles = { | aFiles | If( Len( aFiles ) > 0, oImage:SetFile( aFiles[ 1 ] ),  }
    oImage:SetFrame( 2 ) // Add a visible border box
   
    ACTIVATE WINDOW oWnd  
       
                           
      
    
endif


	 

return nil

function ProcessDrop( aFiles, oGet, cText )
    local cOut := ""
    local i

    for i := 1 to Len( aFiles )
    cOut += aFiles[ i ] + CRLF
    next
	msginfo(1)

    cText := cOut
    oGet:Refresh()

return nil



