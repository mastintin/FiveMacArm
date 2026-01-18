#include "FiveMac.ch"

#define SWIFT_TYPE_TEXT          0
#define SWIFT_TYPE_BUTTON        9

function Main()

    local oWnd, oList

    DEFINE WINDOW oWnd TITLE "SwiftUI List Batch Registration" SIZE 400, 500

    oList := TSwiftList():New( 10, 10, 380, 480, oWnd )
    
    // Fill List using the Batch OO Style
    oList:AddItem( SWIFT_TYPE_TEXT,   "List Item 1" )
    oList:AddItem( SWIFT_TYPE_BUTTON, "List Button 2", {|| MsgInfo( "Clic on List 2" ) } )
    oList:AddItem( SWIFT_TYPE_TEXT,   "List Item 3" )
    oList:AddItem( SWIFT_TYPE_BUTTON, "List Button 4", {|| MsgInfo( "Clic on List 4" ) } )
    
    oList:AddBatch() 

    ACTIVATE WINDOW oWnd CENTERED

return nil
