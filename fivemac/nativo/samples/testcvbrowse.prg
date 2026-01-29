#include "FiveMac.ch"

function Main()

    local oWnd, oBr
    local oSlide 
    local nPos, oBtn
    local nZoom := 20
   
    DEFINE WINDOW oWnd TITLE "Test CVBrowse (Selection Event)" ;
        FROM 200, 200 TO 700, 800

    @ 50, 20 CVBROWSE oBr OF oWnd SIZE 560, 400 ;
        ON CHANGE ( oWnd:SetTitle( "Selected Index: " + Str( nIndex ) ) ) ;
        ON DBLCLICK MsgInfo( "Double Click on Item: " + Str( nIndex ) )

    // Init with some content
    oBr:AddDir( "/Library/Desktop Pictures" )

    // Use nValue supplied by SLIDER ON CHANGE codeblock
    @ 10, 20 SLIDER oSlide VALUE 100 OF oWnd SIZE 200, 20 
    oslide:SetMinMaxValue( 50, 500 )    
    oslide:setValue(100)     
    oSlide:bChange := {|| oBr:SetZoom( oSlide:GetValue() ) } 

    @ 10, 300 BUTTON oBtn PROMPT "Open..." OF oWnd ACTION oBr:OpenPanel()

    ACTIVATE WINDOW oWnd

return nil
