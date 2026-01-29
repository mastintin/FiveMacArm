#include "FiveMac.ch"

CLASS TCard FROM TPanel

    DATA oBar
    DATA oIcon
    DATA oTitle 
    DATA oBody
    
    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, nClrBorder, cTitle, cIcon )
    METHOD SetBorderColor( nColor )
    METHOD SetCornerRadius( nRadius)    
   
ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, nClrBorder, cTitle, cIcon ) CLASS TCard

    DEFAULT nWidth := 300, nHeight := 200
    DEFAULT nClrBorder := nRGB( 99, 102, 241 ) // Default Indigo
    DEFAULT cTitle := "Card Title"
   
    ::Super:New( nTop, nLeft, nWidth, nHeight, oWnd )
   
    // CONTAINER (Shadow Layer)
    // ------------------------
    // 1. Background White (to cast shadow)
    ::SetColor( CLR_BLACK, CLR_WHITE )
    // 2. Round Corners (affects background shape)
    ::super:SetCornerRadius( 10 ) 
    // 3. Shadow (Forces masksToBounds=NO, so subviews would stick out if not contained)
    ::SetShadow( 30, 10, 0, 10 ) 
    ::SetVibrancy( .t. )

    // CONTENT BODY (Clipping Layer)
    // -----------------------------
    // This inner panel clips the content (like the top bar) to the rounded corners.
    // It must match the container size and resizing.
    ::oBody = TPanel():New( 0, 0, nWidth, nHeight, Self )
    ::oBody:SetCornerRadius( 10 ) // Implicitly sets masksToBounds=YES
    ::oBody:_nAutoResize( 18 )    // Resizes with Parent (2=W, 16=H)

    // 1. Top Border Bar (Inside Body)
    ::oBar = TPanel():New( 0, 0, nWidth, 6, ::oBody )
    ::oBar:SetColor( nClrBorder, nClrBorder )
    ::oBar:_nAutoResize( 2 ) // Width sizable
   
    // 2. Icon and Title (Inside Body)
    if !Empty( cTitle )
        if !Empty( cIcon )
            // Avoid IMAGE command syntax issues with expressions
            // TImage:New expects a filename string. ImgSymbols returns a handle.
            // So we create it empty first, then set the image handle.
            ::oIcon := TImage():New( 20, 20, 32, 32, ::oBody )
            ::oIcon:SetScaling( 3 ) // 3 = Scale Proportionally Up or Down
            ::oIcon:SetImage( ImgSymbols( cIcon ) )
        endif
      
        @ 20, 60 SAY ::oTitle PROMPT cTitle OF ::oBody SIZE ::oBody:nWidth() - 60, 25
        SetBoldSystemFont( ::oTitle:hWnd, 16 )
    endif

return Self

METHOD SetBorderColor( nColor ) CLASS TCard
    if ::oBar != nil
        ::oBar:SetColor( nColor, nColor )
    endif
return nil

METHOD SetCornerRadius( nRadius  ) CLASS TCard
    ::super:SetCornerRadius( nRadius )
    ::oBody:SetCornerRadius( nRadius )
    ::super:SetShadow( 30, 10 , 0, 10 ) 
return nil