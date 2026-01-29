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

   METHOD HCenter()
   METHOD VCenter()


ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS TForm

   ::Super:New()
   
   AAdd( ::aForms, Self )
   
   ::SetTitle( "Form" + AllTrim( Str( Len( ::aForms ) ) ) )
   ::lFlipped = .T.
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
         MENUITEM "Horizontal center" ACTION ::HCenter()
                     
         MENUITEM "Vertical center" ACTION ::VCenter()
         
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
          ACTION ( SourceEdit( CreaSourceFlipped( ::cGenPrg() , ::GetTitleHeight() ), "Source code" ))
   ENDMENU
   
   ACTIVATE POPUP oPopup OF Self AT nRow, nCol

return nil

//----------------------------------------------------------------------------//

METHOD HCenter( nRow, nCol ) CLASS TForm
local oCtrl := ::oLastControl
If oCtrl != nil
   oCtrl:SetPos( oCtrl:nTop,oCtrl:oWnd:nWidth / 2 - oCtrl:nWidth / 2 )
   ::oRect:Set( oCtrl:nTop, oCtrl:nLeft, oCtrl:nWidth, oCtrl:nHeight )
   ::oRect:SetBottomRightCornerLeft()
endif

Return nil 

Method VCenter()  CLASS TForm
local oCtrl := ::oLastControl
       If oCtrl != nil
          oCtrl:SetPos( oCtrl:oWnd:nHeight / 2 - oCtrl:nHeight / 2, oCtrl:nLeft )
          ::oRect:Set( oCtrl:nTop, oCtrl:nLeft, oCtrl:nWidth, oCtrl:nHeight )
          ::oRect:SetBottomRightCornerLeft()
       endif   
Return nil

//----------------------------------------------------------------------------//

function CreaSourceFlipped( cSource , nTitleHeight)

   local aLines := HB_ATokens( cSource, Chr( 10 ) )
   local nLine, cLine
   local lInDef := .F.
   local lFlipped := .F.
   local nWinHeight := 600
   local aTokens
   local nRow, nHeight
   local cNewSource := ""
   
   
   // First pass: Detect Flipped and Window Height
   for nLine := 1 to Len( aLines )
      cLine := AllTrim( aLines[ nLine ] )
      
      if Left( cLine, 1 ) == "*" .or. Left( cLine, 2 ) == "//"
         loop
      endif
      
      if "DEFINE WINDOW" $ Upper( cLine ) .or. "DEFINE DIALOG" $ Upper( cLine )
         lInDef := .T.
      endif
      
      if lInDef
         // Try to parse SIZE
         if "SIZE" $ Upper( cLine )
             // Check if there is a comma for Width (SIZE W, H)
             if "," $ SubStr( cLine, At( "SIZE", Upper( cLine ) ) + 5 )
                 // It's usually SIZE Width, Height
                 // We need Height (2nd param)
                 aTokens := HB_ATokens( SubStr( cLine, At( "SIZE", Upper( cLine ) ) + 5 ), "," )
                 if Len( aTokens ) > 1
                    nWinHeight := Val( aTokens[ 2 ] )
                 endif
             else
                 nWinHeight := Val( SubStr( cLine, At( "SIZE", Upper( cLine ) ) + 5 ) )
             endif
         endif
         
         if "FLIPPED" $ Upper( cLine )
            lFlipped := .T.
         endif
         
         if Right( cLine, 1 ) != ";"
            lInDef := .F.
         endif
      endif
   next
   
   if ! lFlipped
      return cSource
   endif
   
   // Second pass: Transform Controls
   for nLine := 1 to Len( aLines )
      cLine := aLines[ nLine ]
      // Preserve original structure, modify only @ lines
      
      if "@" $ cLine .and. ( "BUTTON" $ Upper( cLine ) .or. "GET" $ Upper( cLine ) .or. ;
                             "SAY" $ Upper( cLine ) .or. "IMAGE" $ Upper( cLine ) .or. ;
                             "CHECKBOX" $ Upper( cLine ) .or. "COMBOBOX" $ Upper( cLine ) .or. ;
                             "LISTBOX" $ Upper( cLine ) .or. "BROWSE" $ Upper( cLine ) .or. "BTNBMP" $ Upper( cLine ))
                             
          nRow := Val( SubStr( cLine, At( "@", cLine ) + 1 ) )
         
          nHeight := 30 // Default
          if "SIZE" $ Upper( cLine )
              // Parse Control Height
                 aTokens := HB_ATokens( SubStr( cLine, At( "SIZE", Upper( cLine ) ) + 5 ), "," )
                 if Len( aTokens ) > 1
                    nHeight := Val( aTokens[ 2 ] )
                 endif
          else 
            // Check subsequent lines for SIZE
            nNextLine := nLine + 1
            lFoundSize := .F.
            cLookAhead := cLine
            
            // Loop while line continues (ends with semicolon)
            while Right( AllTrim( cLookAhead ), 1 ) == ";" .and. nNextLine <= Len( aLines )
               cLookAhead := aLines[ nNextLine ]
               if "SIZE" $ Upper( cLookAhead )
                  aTokens := HB_ATokens( SubStr( cLookAhead, At( "SIZE", Upper( cLookAhead ) ) + 5 ), "," )
                  if Len( aTokens ) > 1
                     nHeight := Val( aTokens[ 2 ] )
                     lFoundSize := .T.
                  endif
               endif
               if lFoundSize
                  exit
               endif
               nNextLine++
            enddo
          endif
          
          nRow := nWinHeight - ( nRow + (1*nHeight) ) - if ( nTitleHeight > 0 , nTitleHeight , 30 )
          
          // Replace the number in the string
          cLine := StrTran( cLine, "@ " + AllTrim( Str( Val( SubStr( cLine, At( "@", cLine ) + 1 ) ) ) ), ;
                                   "@ " + AllTrim( Str( Int( nRow ) ) ) )

          cLine:= cLine + " //"+ str ( nWinHeight ) + " " + str(nHeight) + " " + str( nrow)                        
      endif
      
      cNewSource += cLine + Chr( 10 )
   next
   
return cNewSource
