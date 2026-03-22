#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TMultiView FROM TControl

   DATA   aViews
   DATA   oToolbar
   DATA   lWndResize
   DATA   nHeight, nWidth
   DATA   bChange

   METHOD New( oWnd, lWndResize, lToolBar )
   METHOD AddView( nTop, nLeft, nWidth, nHeight, cTitle, cPrompt, cToolTip, cImage )
   METHOD SetView( nButton ) 
   METHOD End()
      
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oWnd, lWndResize, lToolBar ) CLASS TMultiView
   
   local n
   DEFAULT lToolBar := .t.
   DEFAULT lWndResize := .t.
   DEFAULT oWnd := GetWndDefault()
   
   ::oWnd := oWnd
  
   ::nHeight := ::oWnd:nHeight()
   ::nWidth := ::oWnd:nWidth()
   ::lWndResize := lWndResize  
   if lToolBar
      ::oToolbar := TToolBar():New( ::oWnd )
   endif
   ::aViews := {}
   oWnd:AddControl( Self )
   
return Self   

//----------------------------------------------------------------------------//

METHOD AddView( nTop, nLeft, nWidth, nHeight, cTitle, cPrompt, cToolTip, cImage ) CLASS TMultiView

   local oView := TView():New( nTop, nLeft, nWidth, nHeight, ::oWnd, cTitle )
   local nView, bAction, oBtn

   aAdd( ::aViews, oView )
   nView := len( ::aViews )

   if ! Empty( ::oToolBar )
      bAction := {|| ::SetView( nView ) }
      oBtn := ::oToolbar:AddButton( cPrompt, cToolTip, bAction, cImage, .t. ) 
   endif
        
return oView

//----------------------------------------------------------------------------//

METHOD SetView( nButton ) CLASS TMultiView

   local i, view, nWndHeight

   if Len( ::aViews ) > 0
      if ! Empty( ::bChange )
         eval( ::bChange, nButton )
      endif

      for i := 1 to Len( ::aViews )
         if i == nButton
            view := ::aViews[ i ]
            ::oWnd:SetTitle( view:cTitle )  
            view:Show()
         else
            ::aViews[ i ]:Hide()
         endif
      next
	   
      if ! Empty( ::oToolBar )
         if ::lWndResize
            nWndHeight := view:nHeight() + 78
            ::oWnd:SetSize( view:nWidth(), nWndHeight )
         endif	
      endif
   endif   
  
return nil

//----------------------------------------------------------------------------//

METHOD End() CLASS TMultiView
   if ! Empty( ::aViews )
      Aeval( ::aViews, { | o | If( o != nil, o:End(), ) } )
      ::aViews := {}
   endif
   if ::oToolbar != nil
      ::oToolbar:End()
      ::oToolbar := nil
   endif
   ::bChange := nil
return ::Super:End()

//----------------------------------------------------------------------------//

function MultiAddview( oMulti, nTop, nLeft, nWidth, nHeight, cTitle, cPrompt,;
      cToolTip, cImage )

   local oView := oMulti:AddView( nTop, nLeft, nWidth, nHeight, cTitle, cPrompt,;
      cToolTip, cImage ) 

return oView

//----------------------------------------------------------------------------//
