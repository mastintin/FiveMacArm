#include "FiveMac.ch"

static aSwiftToggles := {}

CLASS TSwiftToggle FROM TControl

    DATA cID
    DATA nIndex
    DATA nTglIndex
    DATA cCaption
    DATA bChange
    DATA lOn
    DATA lSwitch
    DATA nColorAcc   AS NUMERIC
    DATA nColorText  AS NUMERIC

    METHOD New( nTop, nLeft, nWidth, nHeight, cCaption, lOn, lSwitch, oWnd, bChange )
    METHOD Set( lOn )
    METHOD Get()
    METHOD Value()    
    METHOD SetColor( nAccent, nText )
    METHOD SetCaption(cCaption ) 
    METHOD End() 
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cCaption, lOn, lSwitch, oWnd, bChange, nAutoResize ) CLASS TSwiftToggle

    DEFAULT nWidth := 100, nHeight := 30
    DEFAULT lOn := .F.
    DEFAULT cCaption := ""
    DEFAULT lSwitch := .F.
    DEFAULT nAutoResize := 0

    ::nTop     = nTop
    ::nLeft    = nLeft
    ::nWidth   = nWidth
    ::nHeight  = nHeight
    ::cCaption = cCaption
    ::lOn      = lOn
    ::lSwitch  = lSwitch
   
    ::bChange  = bChange
    ::oWnd     = oWnd
    ::cID      = hb_UUID()
   
    AAdd( aSwiftToggles, Self )
    ::nTglIndex   = Len( aSwiftToggles )
    
    //::nIndex := Len( oWnd:aControls )

    ::hWnd = SD_SWIFT_TOGGLE_CREATE( nTop, nLeft, nWidth, nHeight, cCaption, lOn, oWnd:hWnd, ::nTglIndex, ::cID, ::lSwitch )

    //  ::hWnd = SWIFTTOGGLECREATE( nTop, nLeft, nWidth, nHeight, cCaption, lOn, oWnd:hWnd, ::nIndex, ::cID, ::lSwitch )

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

//------------------------------------------
METHOD Set( lOn ) CLASS TSwiftToggle
    
    if ::lOn != lOn  // Solo actuamos si el valor es diferente
        ::lOn := lOn
        
        // Llamamos al macro de Swift (usando el Bool directo)
        SD_TGL_SET_VALUE( ::cId, ::lOn )
        
        // Opcional: Ejecutar el callback también cuando se cambia por código
        if ::bChange != nil
            Eval( ::bChange, ::lOn, self )
        endif
    endif

return nil

//----------------------------------------

METHOD Get() CLASS TSwiftToggle
    ::lOn = SD_TGL_GET_VALUE( ::cID )
return ::lOn

//-----------------------------------------
METHOD VALUE( lNewValue )

    if lNewValue != nil
        ::Set( lNewValue )
    else
        ::lOn = SD_TGL_GET_VALUE( ::cID )
    endif
return ::lOn

//-----------------------------------------

METHOD SetCaption( cCaption ) CLASS TSwiftToggle
    ::cCaption := cCaption
    SD_TGL_SET_CAPTION( ::cId, cCaption )
return nil

//------------------------------
METHOD SetColor( nAccent, nText, nAlpha ) CLASS TSwiftToggle
    LOCAL nAcc, nTxt
   
    DEFAULT nAlpha := 255 // Opaco por defecto

    if !Empty( ::cId )
        // CASO 1: Colores numéricos (nRGB)
        if ValType( nAccent ) == "N"
            // Si queremos transparencia, usamos el macro de RGBA enviando un Int32
            // Construimos un ARGB o RGBA. Usemos el bridge tgl_set_colors_int
            SD_TGL_SET_COLORS_RGBA( ::cId, nAccent, nText , nAlpha)  
         
            // CASO 2: Colores Hexadecimales (pueden traer el alfa en el string)
        elseif ValType( nAccent ) == "C"
            SD_TGL_SET_COLORS_HEX( ::cId, nAccent, nText )
        endif
    endif
return self


// ---------------------------------------------------------------------------

METHOD End() CLASS TSwiftToggle
    if !Empty( ::hWnd )
        // Llamamos al macro de Swift
        SD_TGL_DESTROY( ::cId, ::nTglIndex, ::hWnd )
        if ::nTglIndex > 0 .and. ::nTglIndex <= Len( aSwiftToggles )
            aSwiftToggles[ ::nTglIndex ] := nil
        endif
        ::hWnd := 0
        ::cID := ""
    endif
return ::Super:End()

//-----------------------------------------
// --- FUNCION DE EVENTO (CALLBACK DESDE SWIFT) ---
function SwiftToggleOnChange( nTglIndex, lOn )
    local oControl
    
    // Acceso directo al array de Toggles
    if nTglIndex > 0 .and. nTglIndex <= Len( aSwiftToggles )
        oControl := aSwiftToggles[ nTglIndex ]
      
        if oControl != nil
            oControl:lOn := lOn
            if oControl:bChange != nil
                Eval( oControl:bChange, lOn, oControl ) // <--- AQUÍ SE DISPARA EL LABEL
            endif
        endif
    endif
return nil

//-----------------------------------

function GetSwiftToggles() 
return aSwiftToggles



