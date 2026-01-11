#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TForm FROM TWindow

   CLASSDATA aForms INIT {}
   
   CLASSDATA aProps INIT { "nTop", "nLeft", "nWidth", "nHeight", "cText",;
   	                       "cVarName", "lFlipped" }

   DATA   oSelControl // current dragged control
   
   DATA   oLastControl
   DATA   lCtrlResize INIT .F.
   
   DATA   nRowStart, nColStart
   DATA   oRect
   DATA   oRectBlue
  
   DATA nRow0  
   DATA nCol0  
   DATA nTop0  
   DATA nLeft0 
 
   DATA nWidth0
   DATA nHeight0

   DATA lDrag INIT .F.

   DATA   oInspector
   
   DATA   lCtrlResize INIT .F.
   

   METHOD New()

   METHOD Initiate()
   
   METHOD LButtonDown( nRow, nCol )
   
   METHOD MouseMove( nRow, nCol )
   
   METHOD LButtonUp( nRow, nCol )
   
   METHOD DelControl()
   
   METHOD ShowPopup( nRow, nCol )
   
   METHOD KeyDown( nKey )

   METHOD CheckCursor( nRow, nCol )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS TForm

   ::Super:New()
   
   AAdd( ::aForms, Self )
   
   ::SetTitle( "Form" + AllTrim( Str( Len( ::aForms ) ) ) )
 //  ::lFlipped = .T.
   ::SetPos( 190, 530 )
   ::SetSize( 500, 356 )
 
   ::Initiate()

   ::oRect := TRect():NewFromArray( { ::nTop0, ::nLeft0, ::nWidth0, ::nHeight0 } )
   ::oRect:AddBottomRightCorner()
   ::oRectBlue := ::oRect:GetBottomRightCorner()
   
   ::cVarName = "oForm" + AllTrim( Str( Len( ::aForms ) ) )

return Self

//----------------------------------------------------------------------------//

METHOD Initiate() CLASS TForm
      
   ::bResized = { || If( ::oInspector != nil, ::oInspector:Refresh(),) }
   ::bRClicked = { | nRow, nCol | ::ShowPopup( nRow, nCol ) }

return self

//----------------------------------------------------------------------------//

METHOD KeyDown( nKey ) CLASS TForm

   do case
      case nKey == 63232 // VK_UP
           if ::oLastControl != nil
              ::oLastControl:nTop--
           endif

      case nKey == 63233 // VK_DOWN
           if ::oLastControl != nil
              ::oLastControl:nTop++
           endif

      case nKey == 63234 // VK_LEFT
           if ::oLastControl != nil
              ::oLastControl:nLeft--
           endif

      case nKey == 63235 // VK_RIGHT
           if ::oLastControl != nil
              ::oLastControl:nLeft++
           endif
      
      otherwise
           MsgInfo( nKey )
   endcase           

   if ::oInspector != nil
      ::oInspector:Refresh()
   endif   

return 1

//----------------------------------------------------------------------------//

METHOD LButtonDown( nRow, nCol ) CLASS TForm

   local oCtrl := ::AtControl( nRow, nCol )
   local nDistRow, nDistCol
   local oRectBlue

   if ! ::SetDesign()
      if ! Empty( ::GetEventCode( "OnClick" ) )
         Eval( ::GetEventBlock( "OnClick" ), nRow, nCol, Self )
      endif
      return nil
   endif

   ::oSelControl  = oCtrl
   ::oLastControl = oCtrl

   if oCtrl != nil
      ::oRect:set( oCtrl:nTop, oCtrl:nLeft, oCtrl:nWidth, oCtrl:nHeight )
      ::oRect:SetBottomRightCornerLeft()
      oRectBlue := ::oRect:GetBottomRightCorner()
   endif

   if ::oInspector != nil
      if ::oSelControl != nil

         ::oInspector:SetControl( oCtrl )
                 
         // nRow is Bottom-Up, nDistRow converts to Top-Down relative to Control Top
         nDistRow = ::nHeight - nRow - oCtrl:nTop
         nDistCol = nCol - oCtrl:nLeft

         // Check against current Size for Hotspot detection
         // User Request: Exact match or -15px tolerance

       //  if nDistRow >= oCtrl:nHeight - ::tolerancia .and. nDistCol >= oCtrl:nWidth - ::tolerancia

     
        if oRectBlue != nil .and. oRectBlue:Contains( nRow, nCol )
            ::lDrag  := .f.
            ::lCtrlResize = .T.
            ::nWidth0 := oCtrl:nWidth
            ::nHeight0 := oCtrl:nHeight
            ::nRow0  := nRow
            ::nCol0  := nCol
            ::nTop0  := oCtrl:nTop
            ::nLeft0 := oCtrl:nLeft
            
            // Offset = Difference between Control Edge and Mouse Position
            // Used to maintain the relative grab point

            ::nRowStart = oCtrl:nHeight - nDistRow
            ::nColStart = oCtrl:nWidth  - nDistCol
         else
            if ::oRect:Contains( nRow, nCol )
                
               ::lDrag  := .T.
               ::lCtrlResize := .f.
               ::nRow0  := nRow
               ::nCol0  := nCol
               ::nTop0  := ::oSelControl:nTop
               ::nLeft0 := ::oSelControl:nLeft
               SetCursorCloseHand()
            else
               ::lCtrlResize = .F.
            endif   
         endif
      else   
         ::oInspector:SetForm( Self )
         ::lCtrlResize = .F.
         ::lDrag  := .f.
         if ! Empty( ::bLButtonDown )
            Eval( ::bLButtonDown, nRow, nCol, Self )
         endif   
      endif
   endif   
    
return nil

//----------------------------------------------------------------------------//

METHOD LButtonUp( nRow, nCol ) CLASS TForm
   ::nWidth0 := nil
   ::nHeight0 := nil
  // ::oSelControl = nil
   ::nRowStart   = nil
   ::nColStart   = nil
   ::lCtrlResize = .F.
   ::lDrag := .f.
   if ::oInspector != nil
      ::oInspector:Refresh()
   endif   

return nil

//----------------------------------------------------------------------------//


METHOD MouseMove( nRow, nCol ) CLASS TForm

   local oCtrl := ::oSelControl
   local nInspRow, nInspCol, nDistRow, nDistCol
   local lprime := .t. 
   local nNewTop, nNewLeft

 
   if oCtrl != nil
      // Calculate Internal Distances (Robust)
      nDistRow = ::nHeight - nRow - oCtrl:nTop
      nDistCol = nCol - oCtrl:nLeft
      
      // Calculate Inspector Coordinates (Legacy)
      nInspRow = oCtrl:nTop + oCtrl:nHeight - nRow
      nInspCol = nCol - oCtrl:nLeft

      if ::nRowStart == nil
         ::nRowStart = nRow - oCtrl:nTop 
         ::nColStart = nCol - oCtrl:nLeft 
      endif   
   
      if ::lDrag

         nNewTop  := ::nTop0 + ( nRow - ::nRow0 )
         nNewLeft := ::nLeft0 + ( nCol - ::nCol0 )
      
         oCtrl:SetPos( nNewTop, nNewLeft )
         ::oRect:Set( oCtrl:nTop, oCtrl:nLeft, oCtrl:nWidth, oCtrl:nHeight )

         ::CheckCursor( nRow, nCol )
         return nil
      endif
      if ::lCtrlResize
     
        nNewRow :=  - ( nRow - ::nRow0 )
        nNewCol :=    ( nCol - ::nCol0 )

        nNewTop  := ::nTop0 + ( nRow - ::nRow0 )
        nNewLeft := ::nLeft0 + ( nCol - ::nCol0 )
        
        oCtrl:SetSize( ::nWidth0 + nNewCol , ::nHeight0 + nNewRow  )
        oCtrl:SetPos( ::nTop0 - nNewRow , oCtrl:nLeft )

        oCtrl:refresh()
      
       ::oRect:Set( oCtrl:nTop, oCtrl:nLeft, oCtrl:nWidth, oCtrl:nHeight )
       ::oRect:SetBottomRightCornerLeft()
 
      endif  
      
      ::CheckCursor( nRow, nCol )
  
      if ::oInspector != nil
         ::oInspector:Refresh()
      endif   
  
   else
      
      if ( oCtrl := ::AtControl( nRow, nCol ) ) != nil

         ::oRect := TRect():NewFromArray( { oCtrl:nTop, oCtrl:nLeft, oCtrl:nWidth, oCtrl:nHeight } )
         ::oRect:AddBottomRightCorner()
         
         // Calculate Internal Coordinates (Robust detection 0..Height)
         nDistRow = ::nHeight - nRow - oCtrl:nTop
         nDistCol = nCol - oCtrl:nLeft
         
         // Calculate Inspector Coordinates (User Requested Legacy Formula)
         nInspRow = oCtrl:nTop + oCtrl:nHeight - nRow
         nInspCol = nCol - oCtrl:nLeft

         // Cursor Logic (Hover)
         // Check against Internal Robust Distances to ensure correct Bottom-Right detection

        if ::oInspector != nil
           // ::oInspector:SetPosInfo( Int( nInspRow ), Int( nInspCol ) )
            //::oInspector:setTitle( str(nInspRow) + " " + str(nInspCol) )
         endif
      else
         SetCursorArrow()   
      endif
   endif   

return nil    



//----------------------------------------------------------------------------//

METHOD DelControl() CLASS TForm

   local oCtrl := ::oLastControl

   if ! Empty( oCtrl ) .and. ;
      MsgYesNo( "Do you want to delete control " + oCtrl:cVarName + " ?" )

      if ::oInspector != nil
         ::oInspector:DelControl( oCtrl )
      endif   

      oCtrl:End()
      ::oLastControl = nil
             
   endif

return nil

//----------------------------------------------------------------------------//

METHOD CheckCursor( nRow, nCol ) CLASS TForm

   local oHotRect 
  
   if ::oRect != nil
      oHotRect := ::oRect:GetBottomRightCorner()
      if ::lDrag
         SetCursorCloseHand()
         return nil
      endif

      if oHotRect != nil .and. oHotRect:Contains( nRow, nCol )
         GetCursorPosiDirec()
      elseif ::oRect:Contains( nRow, nCol )
         SetCursorHand()
      else
         SetCursorArrow()
      endif
   endif   
return nil

//----------------------------------------------------------------------------//

METHOD ShowPopup( nRow, nCol ) CLASS TForm

   local oPopup, oCtrl := ::oLastControl
   
   MENU oPopup POPUP
      MENUITEM "Selected control"
      MENU
         MENUITEM "Horizontal center" ACTION If( oCtrl != nil,;
                     oCtrl:SetPos( oCtrl:nTop,;
                     oCtrl:oWnd:nWidth / 2 - oCtrl:nWidth / 2 ),)
                     
         MENUITEM "Vertical center" ACTION If( oCtrl != nil,;
                     oCtrl:SetPos( oCtrl:oWnd:nHeight / 2 - ;
                     oCtrl:nHeight / 2, oCtrl:nLeft ),)
         
         SEPARATOR
         
         MENUITEM "Delete control" ACTION ::DelControl()
      ENDMENU
      
      SEPARATOR
      
      if ::SetDesign()
         MENUITEM "Test mode" ACTION ::SetDesign( .F. )
      else
         MENUITEM "Design mode" ACTION ::SetDesign( .T. )
      endif
      
      SEPARATOR  
      
      MENUITEM "PRG source code" ;
         ACTION SourceEdit( ::cGenPrg(), "Source code" )
   ENDMENU
   
   ACTIVATE POPUP oPopup OF Self AT nRow, nCol

return nil

//----------------------------------------------------------------------------//