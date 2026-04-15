#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TListBox FROM TControl

   DATA   aItems
   DATA   aOriginal
   DATA   bActionBlock   // Dato interno real para evitar recursión
   DATA   nResult INIT 0

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, bAction )
   
    METHOD SetItems( aItems )

   METHOD SetSearch( oSearch ) INLINE ListSetSearch( ::hWnd, oSearch:hWnd )

   METHOD Filter( cText )
   
   METHOD GetPos() INLINE ListGetPos( ::hWnd )
   
   METHOD SetPos( nPos ) INLINE ListSetSelect( ::hWnd, nPos )
   
   METHOD Refresh()

   METHOD Rows() INLINE Len( ::aItems )
     
   METHOD Value() INLINE If( ::GetPos() > 0, ::aItems[ ::GetPos() ], nil )

   // Sistema ACCESS / ASSIGN para sincronizar con Cocoa
   ACCESS bAction INLINE ::bActionBlock
   ASSIGN bAction( bNew ) INLINE ( ::bActionBlock := bNew, ListSetDblAction( ::hWnd, bNew ) )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, aItems, bAction ) CLASS TListBox

   DEFAULT nWidth := 200, nHeight := 150, aItems := {}

   ::nTop    = nTop
   ::nLeft   = nLeft
   ::nWidth  = nWidth
   ::nHeight = nHeight
   ::oWnd    = oWnd
   
   ASort( aItems )
   
   ::aItems    = aItems
   ::aOriginal = AClone( aItems )
   
   ::hWnd = ListCreate( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )

   // Sincronizamos con Cocoa usando el ASSIGN
   ::bAction = bAction
   
   oWnd:AddControl( Self )
   
   ::Refresh()

return Self

//----------------------------------------------------------------------------//

METHOD SetItems( aItems ) CLASS TListBox

   ASort( aItems )
   ::aItems = aItems
   ::aOriginal = AClone( aItems )
   ::Refresh()

return nil

//----------------------------------------------------------------------------//

METHOD Refresh() CLASS TListBox
   ListSetItems( ::hWnd, ::aItems )
return nil

//----------------------------------------------------------------------------//

METHOD Filter( cText ) CLASS TListBox

   local x, aFiltrados := {}
   
   if Empty( cText )
      ::aItems = AClone( ::aOriginal )
   else
      for each x in ::aOriginal 
         if Upper( cText ) $ Upper( x ) 
            AAdd( aFiltrados, x ) 
         endif 
      next
      ::aItems = aFiltrados
   endif
   
   ::Refresh()

return nil

//----------------------------------------------------------------------------//
