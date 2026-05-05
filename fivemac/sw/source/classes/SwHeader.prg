#include "swfive.ch"
 
 #define SW_TYPE_HEADER 33
 
 CLASS TSwHeader FROM TSwiftControl
 
    ACCESS cTitle           INLINE hb_HGetDef( ::hState, "title", "" )
    ASSIGN cTitle(c)        INLINE ( ::hState["title"] := c, ::Apply( "title", c ) )
 
    ACCESS cSubtitle        INLINE hb_HGetDef( ::hState, "subtitle", "" )
    ASSIGN cSubtitle(c)     INLINE ( ::hState["subtitle"] := c, ::Apply( "subtitle", c ) )
 
    ACCESS cImage           INLINE hb_HGetDef( ::hState, "image", "" )
    ASSIGN cImage(c)        INLINE ( ::hState["image"] := c, ::Apply( "image", c ) )
 
    ACCESS cColors          INLINE hb_HGetDef( ::hState, "colors", "" )
    ASSIGN cColors(c)       INLINE ( ::hState["colors"] := c, ::Apply( "colors", c ) )
 
    ACCESS cStatus          INLINE hb_HGetDef( ::hState, "status", "" )
    ASSIGN cStatus(c)       INLINE ( ::hState["status"] := c, ::Apply( "status", c ) )
 
    ACCESS cStatusIcon      INLINE hb_HGetDef( ::hState, "statusicon", "" )
    ASSIGN cStatusIcon(c)   INLINE ( ::hState["statusicon"] := c, ::Apply( "statusicon", c ) )
 
    METHOD New( nTop, nLeft, nWidth, nHeight, cTitle, cSubtitle, cImage, cColors, cStatus, cStatusIcon, oWnd, cId, nAutoResize )
   
 ENDCLASS
 
 // -------------------------------------------------------------------------------- //
 
 METHOD New( nTop, nLeft, nWidth, nHeight, cTitle, cSubtitle, cImage, cColors, cStatus, cStatusIcon, oWnd, cId, nAutoResize ) CLASS TSwHeader
 
    DEFAULT nWidth := 800, nHeight := 200
     
    ::Super:New( nTop, nLeft, nWidth, nHeight, cId, nAutoResize )
  
    ::hState["type"]        := SW_TYPE_HEADER
    ::hState["title"]       := cTitle
    ::hState["subtitle"]    := cSubtitle
    ::hState["image"]       := cImage
    ::hState["colors"]      := cColors
    ::hState["status"]      := cStatus
    ::hState["statusicon"]  := cStatusIcon
  
    ::oWnd     := oWnd
     
    if hb_IsObject( oWnd )
       ::hState["parentid"] := oWnd:cId
    endif
 
    ::Create()
  
 return self
