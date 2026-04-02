#include "FiveMac.ch"
#include "SwiftControls.ch"

static aSwiftImages := {}

CLASS TSwiftImage FROM TControl

    DATA bAction
    DATA cId

    METHOD New( nTop, nLeft, nWidth, nHeight, cName, oWnd, bAction, lResizable )
    METHOD OnAction()
    
    METHOD SetSystemName( cName )
    METHOD SetName( cName )
    METHOD SetColor( nColor )
    METHOD SetResizable( lResizable )
    METHOD SetFile( cFile )
    METHOD SetAspectRatio( nMode )
    METHOD SetImage( pImage )
    METHOD End()
    METHOD SetAutoResize( nAutoResize ) INLINE if( nAutoResize != 0 , SWIFTAUTORESIZE( ::hWnd, nAutoResize ), )
      
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cName, oWnd, bAction, lResizable, nAutoResize ) CLASS TSwiftImage

    DEFAULT nWidth := 40, nHeight := 40, oWnd := GetWndDefault(), cName := "star.fill"
    DEFAULT lResizable := .T., nAutoResize := 0

    ::oWnd    = oWnd
    ::bAction = bAction
    
    ::cId     := ""
    
    AAdd( aSwiftImages, Self )
    
    ::hWnd = SD_SWIFT_IMAGE_CREATE( nTop, nLeft, nWidth, nHeight, cName, oWnd:hWnd, ::cId )
    ::cId := SW_GET_ID( ::hWnd )
    SwiftRegisterItem( ::cId, Self )
    
    if !lResizable
        ::SetResizable( .F. )
    endif

    if nAutoResize != 0
        SWIFTAUTORESIZE( ::hWnd, nAutoResize )
    endif

    oWnd:AddControl( Self )

return Self

METHOD OnAction() CLASS TSwiftImage
   
    if ::bAction != nil
        Eval( ::bAction, Self )
    endif

return nil


METHOD SetSystemName( cName ) CLASS TSwiftImage
    SD_IMG_SET_SYSTEM_NAME( ::cId, cName )
return nil

METHOD SetName( cName ) CLASS TSwiftImage
    SD_IMG_SET_NAME( ::cId, cName )
return nil

METHOD SetColor( nColor ) CLASS TSwiftImage
    SD_IMG_SET_COLOR( ::cId, clrToHex( nColor ) )
return nil

METHOD SetResizable( lResizable ) CLASS TSwiftImage
    SD_IMG_SET_RESIZABLE( ::cId, lResizable )
return nil

METHOD SetFile( cFile ) CLASS TSwiftImage
    SD_IMG_SET_FILE( ::cId, cFile )
return nil

METHOD SetAspectRatio( nMode ) CLASS TSwiftImage
    SD_IMG_SET_ASPECT_RATIO( ::cId, nMode )
return nil

METHOD SetImage( pImage ) CLASS TSwiftImage
    SD_IMG_SET_NSIMAGE( ::cId, pImage )
return nil

METHOD End() CLASS TSwiftImage
    if !Empty( ::hWnd )
        SD_IMG_DESTROY( ::cId, ::hWnd )
        SwiftUnregisterItem( ::cId )
        AScan( aSwiftImages, { |o, i| If( o != nil .and. o:cId == ::cId, aSwiftImages[ i ] := nil, ) } )
        ::cId := ""
    endif
return ::Super:End()
