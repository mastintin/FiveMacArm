#include "FiveMac.ch"

static oRect
static oSay
static lDrag := .F.
static nRow0, nCol0, nTop0, nLeft0
Static nWidth0,nHeight0
static lCtrlResize := .f.


function Main()

   local oWnd, oSayBlue
   local nBotton

   DEFINE WINDOW oWnd TITLE "Mouse Test" ;
      FROM 200, 200 TO 600, 600

   @ 100, 100 SAY oSay PROMPT "" SIZE 200, 200 OF oWnd
   oSay:SetBkColor( 128, 128, 128, 255 )

   oRect := RectInit( oSay )

   oWnd:bLButtonDown = { | nRow, nCol | LButtonDown( nRow, nCol, oWnd ) }
   oWnd:bLButtonUp   = { | nRow, nCol | LButtonUp( nRow, nCol, oWnd ) }
   oWnd:bMMoved      = { | nRow, nCol | MouseMove( nRow, nCol, oWnd ) }
   oWnd:bRClicked    = { | nRow, nCol | MsgInfo( "Right Click at: " + Str( nRow ) + ", " + Str( nCol ) ) }

   ACTIVATE WINDOW oWnd

   oRect:End()

return nil

//-----------------------------------------------------

function CheckCursor( nRow, nCol, oWnd )

   local oRectBlue := oRect:GetBottomRightCorner()

   local cInfo := "Pos: " + Str(nRow) + "," + Str(nCol)

   if lDrag
       SetCursorCloseHand()
       cInfo += " DRAGGING"
       if oWnd != nil
          oWnd:SetTitle( cInfo )
       endif
       return nil
   endif

   if oRectBlue != nil .and. oRectBlue:Contains( nRow, nCol )
      cInfo += " IN CORNER"
      GetCursorPosiDirec()
   elseif oRect:Contains( nRow, nCol )
      cInfo += " IN RECT"
      SetCursorHand()
   else
      SetCursorArrow()
   endif
   
return nil

function LButtonDown( nRow, nCol, oWnd )

   local oRectBlue := oRect:GetBottomRightCorner()

   if oRectBlue != nil .and. oRectBlue:Contains( nRow, nCol )
      lDrag  := .f.
      lCtrlResize := .t.
      nWidth0 := osay:nWidth
      nHeight0 := oSay:nHeight
      nRow0  := nRow
      nCol0  := nCol
      nTop0  := oSay:nTop
      nLeft0 := oSay:nLeft
      oWnd:SetText( "Resizing..." )
   else
      if oRect:Contains( nRow, nCol )
         lDrag  := .T.
         lCtrlResize := .f.
         nRow0  := nRow
         nCol0  := nCol
         nTop0  := oSay:nTop
         nLeft0 := oSay:nLeft
      
         SetCursorCloseHand()
         oWnd:SetText( "Dragging..." )
      else
         oWnd:SetText( "LButtonDown: " + Str( nRow ) + ", " + Str( nCol ) )
         lCtrlResize := .f.
      endif
   endif
return nil

//-----------------------------------------------------

function LButtonUp( nRow, nCol, oWnd )
   nWidth0 := nil
   nHeight0 := nil
     
   if lCtrlResize
      lCtrlResize := .f.
   endif 
   if lDrag
      lDrag := .F.
      oWnd:SetText( "Done Dragging" )
      CheckCursor( nRow, nCol, oWnd )
   else
      oWnd:SetText( "LButtonUp: " + Str( nRow ) + ", " + Str( nCol ) )
   endif
return nil

//-----------------------------------------------------

function MouseMove( nRow, nCol, oWnd )

   local nNewTop, nNewLeft
   local nNewRow, nNewCol

   if lDrag

      nNewTop  := nTop0 + ( nRow - nRow0 )
      nNewLeft := nLeft0 + ( nCol - nCol0 )
      
      oSay:SetPos( nNewTop, nNewLeft )
      
      RectRefresh( oSay )
      CheckCursor( nRow, nCol, oWnd )
      return nil
   endif

   if lCtrlResize
     
      nNewRow :=  - ( nRow - nRow0 )
      nNewCol :=    ( nCol - nCol0 )

      nNewTop  := nTop0 + ( nRow - nRow0 )
      nNewLeft := nLeft0 + ( nCol - nCol0 )
     
      oSay:setsize( nWidth0 + nNewCol , nHeight0 + nNewRow  )
      oSay:setpos( nTop0 - nNewRow , osay:nLeft )

      oSay:refresh()
      
      oWnd:SetText( "resizing 1" + str( nNewRow ) + " " + str( nNewCol ))
        
      RectRefresh( oSay )

   endif

   CheckCursor( nRow, nCol, oWnd )
   
return nil

Function RectInit ( oCtrl )

  local oNewRect:= TRect():NewFromArray( { oCtrl:nTop, oCtrl:nLeft, oCtrl:nWidth, oCtrl:nHeight } )
  
   oNewRect:AddBottomRightCorner()

Return oNewRect


Function RectRefresh( oCtrl )

   oRect:Set( oCtrl:nTop, oCtrl:nLeft, oCtrl:nWidth, oCtrl:nHeight )

   if lCtrlResize
      oRect:SetBottomRightCornerLeft()
   endif
Return nil
