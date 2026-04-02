#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TSwiftWebview FROM TControl

    DATA cId
    DATA cUrl
    DATA bOnMessage
    DATA nMagnification INIT 1.0

    ACCESS Value      INLINE ::cUrl
    ASSIGN Value( c ) INLINE ::Load( c )
    
    ASSIGN OnMessage( b ) INLINE ::bOnMessage := b
    ASSIGN OnAction( b )  INLINE ::bOnMessage := b
 
    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cUrlName, cId, nAutoResize )

    METHOD Load( cUrlName ) INLINE ( ::cUrl := cUrlName , SD_SW_WEBVIEW_LOAD( ::cId, ::cUrl ) )
    METHOD LoadHtml( cHtml, cBaseUrl ) INLINE SD_SW_WEBVIEW_LOAD_HTML( ::cId, cHtml, cBaseUrl )
    METHOD LoadFile( cPath ) INLINE SD_SW_WEBVIEW_LOAD_FILE( ::cId, cPath )
    
    METHOD GoBack() INLINE SD_SW_WEBVIEW_GO_BACK( ::cId )
    METHOD GoForward() INLINE SD_SW_WEBVIEW_GO_FORWARD( ::cId )
    METHOD Reload() INLINE SD_SW_WEBVIEW_RELOAD( ::cId )
    METHOD Stop()   INLINE SD_SW_WEBVIEW_STOP( ::cId )
    
    METHOD IsLoading() INLINE SD_SW_WEBVIEW_IS_LOADING( ::cId )
    METHOD Progress() INLINE SD_SW_WEBVIEW_PROGRESS( ::cId )
    
    METHOD Eval( cScript ) INLINE SD_SW_WEBVIEW_EVAL( ::cId, cScript )
    METHOD EvalArg( cMethod, cArg ) INLINE SD_SW_WEBVIEW_EVAL_ARG( ::cId, cMethod, cArg )
    
    METHOD SetZoom( nZoom ) INLINE ( ::nMagnification := nZoom, SD_SW_WEBVIEW_SET_ZOOM( ::cId, nZoom ) )
    METHOD SaveToPDF( cPath ) INLINE SD_SW_WEBVIEW_SAVE_PDF( ::cId, cPath )

    METHOD OnAction( cBody, cName )

ENDCLASS   

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cUrlName, cId, nAutoResize ) CLASS TSwiftWebview

    DEFAULT nWidth := 300, nHeight := 100, oWnd := GetWndDefault()
    DEFAULT cId := ""
    
    // Create the Swift View and get its pointer
    ::hWnd := SD_SW_WEBVIEW_CREATE( nTop, nLeft, nWidth, nHeight, oWnd:hWnd, Self, cId )
    
    ::cId := SW_GET_ID( ::hWnd )
    SwiftRegisterItem( ::cId, Self )
    ::oWnd := oWnd
    
    ::SetTag( GetNextTag() )
    
    if !Empty( cUrlName )
        ::Load( cUrlName )
    endif
    
    if nAutoResize != nil
        ::_nAutoResize( nAutoResize )
    endif
    
    oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//

METHOD OnAction( cBody, cName ) CLASS TSwiftWebview
    if ::bOnMessage != nil
        Eval( ::bOnMessage, cBody, cName, Self )
    endif
return nil
