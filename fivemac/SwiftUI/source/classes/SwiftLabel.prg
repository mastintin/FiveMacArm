#include "FiveMac.ch"
#include "SwiftControls.ch"

static aSwiftLabels := {}

CLASS TSwiftLabel FROM TControl

    DATA cID

    METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd )
    METHOD SetText( cText )
    METHOD SetFont( nSize )
    METHOD SetColor( nColor )
    METHOD SetAutoResize( nAutoResize ) INLINE  if(nAutoResize != 0 , SWIFTAUTORESIZE( ::hWnd, nAutoResize ), )
    METHOD SetAlignment( nAlign )
    METHOD End()   
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cText, oWnd, nAutoResize ) CLASS TSwiftLabel

    DEFAULT nWidth := 100, nHeight := 20, oWnd := GetWndDefault(), cText := "Swift Label", nAutoResize := 0

    ::oWnd    = oWnd
    // ::nId     = ::GetCtrlIndex()
    ::cID      = hb_UUID()

    AAdd( aSwiftLabels, Self )
    

    // Pass ::cID (Param 7)
    ::hWnd = SD_SWIFT_LABEL_CREATE( nTop, nLeft, nWidth, nHeight, cText, oWnd:hWnd, ::cID )

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD SetText( cText ) CLASS TSwiftLabel
    SD_LBL_SET_TEXT( ::cID, cText )
return nil

METHOD SetFont( uVal ) CLASS TSwiftLabel
    if ValType( uVal ) == "N"
        SD_LBL_SET_FONT( ::cId, uVal )
    else
        SD_LBL_SET_FONT_STYLE( ::cId, uVal )
    endif
return nil


METHOD SetColor( nText, nAlpha ) CLASS TSwiftLabel
    LOCAL nAcc, nTxt
   
    DEFAULT nAlpha := 255 // Opaco por defecto
    DEFAULT nText   := 0   // Negro por defecto si no se pasa nada
 
    if !Empty( ::cId )
        // CASO 1: Colores numéricos (nRGB)
        if ValType( nText ) == "N"
            // Si queremos transparencia, usamos el macro de RGBA enviando un Int32
            // Construimos un ARGB o RGBA. Usemos el bridge tgl_set_colors_int
            SD_LBL_SET_COLORS_RGBA( ::cId, nText , nAlpha)  
         
            // CASO 2: Colores Hexadecimales (pueden traer el alfa en el string)
        elseif ValType( nText ) == "C"
            SD_LBL_SET_COLORS_HEX( ::cId, nText , nAlpha )
        endif
    endif
return self

//----------------------------------------

METHOD SetAlignment( nAlign ) CLASS TSwiftLabel
    if !Empty( ::cId )
        // 0: Left, 1: Center, 2: Right
        SD_LBL_SET_ALIGN( ::cId, nAlign )
    endif
return self

METHOD End() CLASS TSwiftLabel
    local nPos 
    if !Empty( ::hWnd )
        SD_LBL_DESTROY( ::cId, ::hWnd )
        nPos := AScan( aSwiftLabels, { |o| o != nil .and. o:cID == ::cID } )
        if nPos > 0
            aSwiftLabels[ nPos ] := nil
        endif
        ::hWnd := 0
        ::cID := ""
    endif
return ::Super:End()
