#include "FiveMac.ch"

function Main()

   local oWnd, oBrw
   local aData := {}

   DEFINE WINDOW oWnd TITLE "Testing Array Browse" SIZE 600, 400

   @ 20, 20 BROWSE oBrw OF oWnd SIZE 400, 300 ;
      HEADERS "Column 1", "Column 2" ;
      COLSIZES 150, 150

   oBrw:SetArray( aData )
   oBrw:bLine = { |n| { aData[n][1], aData[n][2] } }
   
   @ 330, 20 BUTTON "Add" OF oWnd ACTION AddItem( oBrw, aData )
   @ 330, 120 BUTTON "Delete" OF oWnd ACTION DelItem( oBrw, aData )
   @ 330, 220 BUTTON "Edit" OF oWnd ACTION EditItem( oBrw, aData )

   ACTIVATE WINDOW oWnd

return nil

function AddItem( oBrw, aData )
   AAdd( aData, { "New Item " + AllTrim( Str( Len(aData)+1 ) ), "Description" } )
   oBrw:Refresh()
return nil

function DelItem( oBrw, aData )
   if !Empty( aData )
      ADel( aData, oBrw:nArrayAt )
      ASize( aData, Len(aData) - 1 )
      oBrw:Refresh()
   endif
return nil

function EditItem( oBrw, aData )
   local nAt := oBrw:nArrayAt
   if nAt > 0 .and. nAt <= Len( aData )
      aData[ nAt ][ 1 ] += " (Edited)"
      oBrw:Refresh()
   endif
return nil
