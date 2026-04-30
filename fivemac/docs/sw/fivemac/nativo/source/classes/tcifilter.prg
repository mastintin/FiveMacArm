#include "FiveMac.ch"

CLASS TCIFilter
    DATA aFilters  INIT {} // Array para guardar los punteros (handles)

    METHOD New( cFilterName )
    METHOD Add( cFilterName ) // Añade un nuevo filtro a la pila    
    METHOD SetValue( cKey, uValue )
    METHOD Apply( oImage ) 
    METHOD Clear(oImage) // Limpia todos los filtros
    METHOD Destroy()
    METHOD End() INLINE ::Destroy()
    METHOD Release() INLINE ::Destroy()
ENDCLASS

METHOD New( cFilterName ) CLASS TCIFilter
    if !Empty(cFilterName)
    AAdd(::aFilters,CIFilterCreate( cFilterName ))
    endif
RETURN Self

METHOD Add( cFilterName ) CLASS TCIFilter
    local hFilter
    if !Empty(cFilterName)
    hFilter := CIFilterCreate( cFilterName )
    if !Empty(hFilter)
    AAdd(::aFilters,hFilter)
    endif
    endif
RETURN len(::aFilters)


METHOD SetValue( nIndex, cKey, uValue ) CLASS TCIFilter
    IF nIndex > 0 .AND. nIndex <= len(::aFilters)
    CIFilterSetValue( ::aFilters[nIndex], cKey, uValue )
    ENDIF
RETURN nil

METHOD Apply( oImage ) CLASS TCIFilter

    SIMAGESETFILTERSTACK(oImage:hWnd,::aFilters)  
RETURN nil

METHOD Clear( oImage ) CLASS TCIFilter
    local hFilter
    for each hFilter in ::aFilters
    CIFilterRelease( hFilter )
    next
    ::aFilters := {}
    if !Empty( oImage )
    SIMAGESETFILTERSTACK(oImage:hWnd,nil)  
    endif
RETURN nil

METHOD Destroy() CLASS TCIFilter
    local hFilter
    for each hFilter in ::aFilters
    CIFilterRelease( hFilter )
    next
    ::aFilters := {}
RETURN nil
