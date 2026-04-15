#include "FiveMac.ch"

// Tipo 0 en SwCommon.swift
#define SW_TYPE_TEXT 0

CLASS TSwLabel FROM TSwiftControl

    ACCESS Caption      INLINE ::hState["Caption"]
    ASSIGN Caption( c ) INLINE ::SetText( c )

    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId )
    METHOD SetText( cText )
    METHOD Refresh() INLINE nil

ENDCLASS

METHOD SetText( cText, lSync ) CLASS TSwLabel
    DEFAULT lSync := .F.
    
    SW_LOG( "TSwLabel:SetText -> ID: " + ::cId + " Text: " + cText + " Sync: " + hb_ValToStr( lSync ) )

    if lSync
        SDS:Text( ::cId, cText )
    else    
        SD:Text( ::cId, cText )
    endif
    ::hState["Caption"] := cText
return nil

METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, cId ) CLASS TSwLabel

    default nWidth := 100, nHeight := 20, cText := ""
    
    if Empty( cId ) ; cId := hb_UUID() ; endif

    ::Super:New( nTop, nLeft, nWidth, nHeight, cId )
    
    ::hState["Caption"] := cText
    ::oWnd     := oWnd

    // 1. Crear el ítem en Swift con su autorregistro de capacidades
    SW_LABEL_CREATE( ::cId, cText )

    // 2. Registrar en el almacén de Harbour (para el Tren de Vuelta)
    SwiftRegisterItem( ::cId, Self )

    if !Empty( oWnd )
        oWnd:AddControl( Self, nTop, nLeft, SW_TYPE_TEXT )
    endif

return Self
