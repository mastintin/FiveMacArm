#include "FiveMac.ch"

// wrapper class for Areas.m (NSRect handling)

CLASS TRect

   DATA hRect
   DATA hSubRects

   DATA lMoveChildren 
   DATA nOldTop
   DATA nOldLeft
   DATA nDetectionCorner 
   

   METHOD New( nTop, nLeft, nWidth, nHeight ) CONSTRUCTOR
   METHOD NewFromArray( aRect ) CONSTRUCTOR
   METHOD End()

   METHOD AsArray() INLINE NSRectToArray( ::hRect )
   METHOD Contains( nRow, nCol ) INLINE NSPointInRect( nRow, nCol, ::hRect )
   
   METHOD Set( nTop, nLeft, nWidth, nHeight, lMoveChildren )

   METHOD AddHotCorner( nTop, nLeft, nWidth, nHeight , cName )

   METHOD AddBottomRightCorner() 

   METHOD AjustaHijoMove( oHijo )

   METHOD AjustaAllHijoMove()
  
   METHOD GetBottomRightCorner() INLINE ::GetArea("HotBottomRightCorner")
   
   METHOD SetBottomRightCornerLeft() 
  

   METHOD nTop( nNew ) 
   METHOD nLeft( nNew ) 
   METHOD nWidth( nNew ) 
   METHOD nHeight( nNew ) 
   
   METHOD SubRect( nTop, nLeft, nWidth, nHeight )
   METHOD AddArea( cName, nTop, nLeft, nWidth, nHeight )
   METHOD GetArea( cName ) INLINE ::hSubRects[ cName ]
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight ) CLASS TRect

   DEFAULT nTop := 0, nLeft := 0, nWidth := 0, nHeight := 0
   
   ::lMoveChildren := .t.
   ::nDetectionCorner := 40

   ::hRect = NSRectNew( nLeft, nTop, nWidth, nHeight )
   ::hSubRects = {=>}
   
return Self

//----------------------------------------------------------------------------//

METHOD NewFromArray( aRect ) CLASS TRect
   
   // Expects { x, y, w, h } or { Left, Top, Width, Height }
   // Areas.m NSRECTFROMARRAY expects { x, y, w, h }

   ::lMoveChildren := .t.
   ::nDetectionCorner := 20
   ::hRect = NSRectFromArray( aRect )
   ::hSubRects = {=>}
     
return Self

//----------------------------------------------------------------------------//

METHOD AddArea( cName, nTop, nLeft, nWidth, nHeight ) CLASS TRect
   
   local oArea
   
   oArea = ::SubRect( nTop, nLeft, nWidth, nHeight )
   ::hSubRects[ cName ] = oArea
   
return oArea

//----------------------------------------------------------------------------//

METHOD SubRect( nTop, nLeft, nWidth, nHeight ) CLASS TRect

   local oSub := TRect():New()
   
   // Create new internal rect relative to self
   if oSub:hRect != nil
      NSRectRelease( oSub:hRect )
   endif
   
   oSub:hRect = NSRectOffset( ::hRect, nTop, nLeft, nWidth, nHeight )
   
return oSub

//----------------------------------------------------------------------------//
METHOD AddHotCorner( nTop, nLeft, nWidth, nHeight , cName ) CLASS TRect

    local oArea
   
   DEFAULT cName := "HotCorner"
    
   oArea = ::SubRect( nTop, nLeft, nWidth, nHeight )
   ::hSubRects[ cName ] = oArea
   
return oArea

//----------------------------------------------------------------------------//

METHOD AddBottomRightCorner() CLASS TRect

   local nWidth := ::nHeight() - ::nDetectionCorner
   ::AddHotCorner( 0, nWidth , ::nDetectionCorner, ::nDetectionCorner, "HotBottomRightCorner" )

return nil


//----------------------------------------------------------------------------//
METHOD SetBottomRightCornerLeft() CLASS TRect
   local nleft := ::nLeft + ::nWidth - ::nDetectionCorner
   ::hSubRects[ "HotBottomRightCorner" ]:nLeft( nleft )
Return nil

//----------------------------------------------------------------------------//

METHOD AjustaHijoMove( oHijo ) CLASS TRect

   local ndTop, ndLeft
  
   if ::nOldTop != nil .and. ::nOldLeft != nil

      ndTop  := ::nTop - ::nOldTop
      ndLeft := ::nLeft - ::nOldLeft

      // Move child (maintain relative size/pos)
      NSRectSetY( oHijo:hRect, NSRectGetY( oHijo:hRect ) + ndTop )
      NSRectSetX( oHijo:hRect, NSRectGetX( oHijo:hRect ) + ndLeft )

   endif
 
return nil

//----------------------------------------------------------------------------//

METHOD AjustaAllHijoMove( ) CLASS TRect

   local oHijo
   local ndTop, ndLeft
 
if ::nOldTop != nil .and. ::nOldLeft != nil

   ndTop  := ::nTop - ::nOldTop
   ndLeft := ::nLeft - ::nOldLeft

   if ndTop != 0 .or. ndLeft != 0
      if ! Empty( ::hSubRects )
         for each oHijo in ::hSubRects
               ::AjustaHijoMove( oHijo )
         next
      endif
   endif
endif

return nil

//----------------------------------------------------------------------------//

METHOD Set( nTop, nLeft, nWidth, nHeight ) CLASS TRect

  // local nOldTop, nOldLeft
   local ndTop, ndLeft
   local oChild

   // Get old pos
   ::nOldTop  := NSRectGetY( ::hRect )
   ::nOldLeft := NSRectGetX( ::hRect )

   // Set new pos (and size)
   NSRectSet( ::hRect, nTop, nLeft, nWidth, nHeight )

   if ::lMoveChildren

      // Propagate displacement to children
      if nTop != nil .and. nLeft != nil
         ::AjustaAllHijoMove()
      endif
   endif
   
return nil

//----------------------------------------------------------------------------//

METHOD nTop( nNew ) CLASS TRect
   if nNew != nil
      NSRectSetY( ::hRect, nNew )
   endif
return NSRectGetY( ::hRect )

//----------------------------------------------------------------------------//

METHOD nLeft( nNew ) CLASS TRect
   if nNew != nil
      NSRectSetX( ::hRect, nNew )
   endif
return NSRectGetX( ::hRect )

//----------------------------------------------------------------------------//

METHOD nWidth( nNew ) CLASS TRect
   if nNew != nil
      NSRectSetWidth( ::hRect, nNew )
   endif
return NSRectGetWidth( ::hRect )

//----------------------------------------------------------------------------//

METHOD nHeight( nNew ) CLASS TRect
   if nNew != nil
      NSRectSetHeight( ::hRect, nNew )
   endif
return NSRectGetHeight( ::hRect )

//----------------------------------------------------------------------------//

METHOD End() CLASS TRect

   local oRect

   if ! Empty( ::hSubRects )
      for each oRect in ::hSubRects
          oRect:End()
      next
      ::hSubRects = nil
   endif

   if ::hRect != nil
      NSRectRelease( ::hRect )
      ::hRect = nil
   endif
   
return nil

//----------------------------------------------------------------------------//
