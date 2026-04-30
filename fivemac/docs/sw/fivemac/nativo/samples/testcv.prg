#include "FiveMac.ch"

function Main()

    local oWnd, oBrw

    DEFINE WINDOW oWnd TITLE "NSCollectionView Test"  NOFLIPPED ;
        SIZE 800, 600

    oBrw = TCVBrowse():New( 20, 20, 760, 500, oWnd )

    @ 530, 20 BUTTON "Select Directory" OF oWnd ACTION oBrw:OpenPanel()
   
    @ 530, 160 BUTTON "Zoom In" OF oWnd ACTION oBrw:SetZoom( 150 )
    @ 530, 260 BUTTON "Zoom Out" OF oWnd ACTION oBrw:SetZoom( 80 )

    ACTIVATE WINDOW oWnd

return nil
