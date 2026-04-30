#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TFont

  DATA   hWnd
  
  METHOD New( cName, nSize  )
  METHOD GetName() INLINE FontGetName(::hWnd)
  METHOD isVertical() INLINE FontIsVertical(::hWnd)
  METHOD SetVertical() INLINE ::hWnd:= FontSetVertical(::hWnd)

  METHOD GetFontsArray() INLINE FontsArray()

  METHOD End() INLINE ::hWnd:= nil
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( cName, nSize ) CLASS TFont
  DEFAULT nsize := 0
  if Empty(cName)
    ::hWnd   = FontGetSystem(nSize)
  else       
    ::hWnd   = Createfont(cName,nSize )
  endif  
return Self

//----------------------------------------------------------------------------//

function FontsArray()
  local aFonts
  local oArray
  oArray := TArray():FromArray(FM_FontsArray() )
  aFonts := oArray:ToArray()
  oArray:End()
return aFonts   
