#include "FiveMac.ch"

#define NSSplitViewDividerStyleThick 1
#define NSSplitViewDividerStyleThin  2
#define NSSplitViewDividerStylePaneSplitter  3

//----------------------------------------------------------------------------//

CLASS TSplitter FROM TControl

   DATA   lVertical
   
   DATA   aViews INIT {}  
   
   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, lVertical, nStyle, nAutoResize,;
      nViews )
   
   METHOD GetView( nView ) INLINE SplitGetSubview( ::hWnd, nView )  
   
   METHOD AddView() 
   
   METHOD SetVertical( lVertical ) INLINE ;
      ( ::lVertical := lVertical, SplitSetVertical( ::hWnd, ::lVertical ) )
   
   METHOD SetStyle( nStyle ) INLINE SplitSetStyle( ::hWnd, nStyle ) 
   
   METHOD SetPane( nPane, oControl, lFill ) 
   
   METHOD View( n ) INLINE If( n > 0 .and. n <= Len( ::aViews ), ::aViews[ n ], nil )
    
   METHOD SetPosition( nDivider, nPos ) INLINE ;
      SplitSetPosition( ::hWnd, nDivider - 1, nPos )    
   						   			   	       
ENDCLASS   

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, lVertical, nStyle, nAutoResize,;
      nViews ) CLASS TSplitter 

   local n

   DEFAULT nWidth := 100, nHeight := 200, oWnd := GetWndDefault()
   DEFAULT lvertical := .F., nAutoResize := 0 ,nStyle := 1
   
   ::hWnd =  SplitCreate( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )
   
   ::oWnd = oWnd
   
   ::SetVertical( lVertical )
   
   ::nAutoResize = nAutoResize
   ::SetStyle( nStyle ) 
   
   if ! Empty( nViews )
   for n = 1 to nViews
   ::AddView()
   next
   endif
      
   oWnd:AddControl( Self )
   
return Self

//----------------------------------------------------------------------------//

METHOD AddView() CLASS TSplitter 
 
   local oSplitItem := TSplitItem():New( self )
      
   AAdd( ::aViews, oSplitItem ) 
  
return oSplitItem

//----------------------------------------------------------------------------//

METHOD SetPane( nPane, oControl, lFill ) CLASS TSplitter

   local oView
   
   DEFAULT lFill := .T.

   if nPane > Len( ::aViews )
   while Len( ::aViews ) < nPane
   ::AddView()
   enddo
   endif

   oView := ::aViews[ nPane ]
   
   if oControl != nil
   oControl:oWnd := oView
   oView:AddControl( oControl )
      
   oControl:SetPos( 0, 0 )
      
   if lFill
   oControl:SetSize( oView:nWidth, oView:nHeight )
   oControl:nAutoResize := 18 // Width (2) | Height (16)
   endif
   endif

return oView

//----------------------------------------------------------------------------//
