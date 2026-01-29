#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TStackItem FROM TControl

    DATA nIndex
    DATA bAction
   
    METHOD New( hWnd, oWnd, bAction )
   
    METHOD Click() INLINE If( ::bAction != nil, Eval( ::bAction, Self ), nil )
   
    // Dummy methods required by TWindow/TControl interaction
    METHOD SetFocus() INLINE nil
    METHOD LostFocus() INLINE nil
    METHOD KeyDown() INLINE nil
    METHOD Initiate() INLINE nil
    METHOD GenLocals() INLINE ""
    METHOD cGenPrg() INLINE ""
    METHOD End() INLINE nil
   
ENDCLASS


METHOD New( hWnd, oWnd, bAction ) CLASS TStackItem

    ::hWnd    := hWnd
    ::oWnd    := oWnd
    ::bAction := bAction
   
    oWnd:AddControl( Self )
   
return Self

//----------------------------------------------------------------------------//
