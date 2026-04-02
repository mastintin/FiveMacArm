#include "FiveMac.ch"

// Test specifically for the new clean CVBrowser implementation

#xcommand @ <nRow>, <nCol> BRIMAGE [ <oImage> ] ;
    [ OF <oWnd> ] ;
    [ SIZE <nWidth>, <nHeight> ] ;
    => ;
    [ <oImage> := ] TBrimage():New( <nRow>, <nCol>, <nWidth>, <nHeight>, <oWnd> )

function Main()

    local oWnd, oBr
    local cPath := "/Library/Desktop Pictures" 

    DEFINE WINDOW oWnd TITLE "New Image Browser (NSCollectionView)"  NOFLIPPED ;
        FROM 200, 200 TO 800, 1000

    @ 20, 20 BRIMAGE oBr OF oWnd SIZE 760, 560

    // Test 1: Add individual file
    // oBr:AddFile( "/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns" )

    // Test 2: Add Directory
    if File( cPath ) == .F.
    cPath = "/System/Library/Desktop Pictures" // Fallback for newer macOS
    endif
   
    oBr:OpenDir( cPath )
   
    @ 10, 20 BUTTON "Select Dir" OF oWnd ACTION oBr:OpenPanel()
   
    @ 10, 140 BUTTON "Zoom +" OF oWnd ACTION oBr:SetZoom( oBr:GetZoom() + 10 )
    @ 10, 240 BUTTON "Zoom -" OF oWnd ACTION oBr:SetZoom( oBr:GetZoom() - 10 )

    ACTIVATE WINDOW oWnd

return nil
