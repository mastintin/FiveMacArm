#include "FiveMac.ch"
#include "SwiftControls.ch"

static aSwiftImages := {}

CLASS TSwiftImage FROM TControl

    DATA bAction
    DATA nIndex

    METHOD New( nTop, nLeft, nWidth, nHeight, cName, oWnd, bAction, lResizable )
    METHOD Click()
    
    METHOD SetSystemName( cName )
    METHOD SetName( cName )
    METHOD SetColor( nColor )
    METHOD SetResizable( lResizable )
    METHOD SetFile( cFile )
    METHOD SetAspectRatio( nMode )
    METHOD SetImage( pImage )

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, cName, oWnd, bAction, lResizable ) CLASS TSwiftImage

    DEFAULT nWidth := 40, nHeight := 40, oWnd := GetWndDefault(), cName := "star.fill"
    DEFAULT lResizable := .T.

    ::oWnd    = oWnd
    ::bAction = bAction
    ::nId     = ::GetCtrlIndex()
    
    AAdd( aSwiftImages, Self )
    ::nIndex  = Len( aSwiftImages )
    
    ::hWnd = SWIFTIMAGECREATE( nTop, nLeft, nWidth, nHeight, cName, oWnd:hWnd, ::nIndex )
    
    if !lResizable
    ::SetResizable( .t. )
    endif

    oWnd:AddControl( Self )

return Self

METHOD Click() CLASS TSwiftImage
   
    if ::bAction != nil
    Eval( ::bAction, Self )
    endif

return nil

METHOD SetSystemName( cName ) CLASS TSwiftImage
    SWIFTIMAGESETSYSTEMNAME( cName )
return nil

METHOD SetName( cName ) CLASS TSwiftImage
    SWIFTIMAGESETNAME( cName )
return nil

METHOD SetColor( nColor ) CLASS TSwiftImage
    SWIFTIMAGESETCOLOR( nColor )
return nil

METHOD SetResizable( lResizable ) CLASS TSwiftImage
    SWIFTIMAGESETRESIZABLE( lResizable )
return nil

METHOD SetFile( cFile ) CLASS TSwiftImage
    SWIFTIMAGESETFILE( cFile )
return nil

METHOD SetAspectRatio( nMode ) CLASS TSwiftImage
    SWIFTIMAGESETASPECTRATIO( nMode )
return nil

METHOD SetImage( pImage ) CLASS TSwiftImage
    SWIFTIMAGESETNSIMAGE( pImage )
return nil

// Called from C callback
function SwiftImageOnClick( nIndex )
   
    if nIndex > 0 .and. nIndex <= Len( aSwiftImages )
    aSwiftImages[ nIndex ]:Click()
    endif
   
return nil
