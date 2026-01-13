#include "FiveMac.ch"
#include "fmsgs.h"

CLASS TFMGet FROM TControl

   DATA   bSetGet
   DATA   bChanged
   DATA   bIncremental
   DATA   cPicture

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, bSetGet, bValid, bChanged, bIncremental, cPicture )
   
   METHOD SetText( cText ) INLINE FMGetSetText( ::hWnd, cText )
   METHOD GetText() INLINE FMGetGetText( ::hWnd )
   
   METHOD HandleEvent( nMsg, nSender, uParam1, uParam2, uParam3 )
   
   METHOD Assign()

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, bSetGet, bValid, bChanged, bIncremental, cPicture ) CLASS TFMGet

   local cText := "Ten"

   DEFAULT nWidth := 120, nHeight := 24, oWnd := GetWndDefault(),;
           bSetGet := bSETGET( cText )
   
   ::hWnd     = FMGetCreate( nTop, nLeft, nWidth, nHeight, oWnd:hWnd )
   ::oWnd     = oWnd
   ::bSetGet  = bSetGet
   ::bValid   = bValid
   ::bChanged = bChanged
   ::cPicture = cPicture
   
   if bIncremental != nil
      ::bIncremental = bIncremental
      FMGetSetFormatter( ::hWnd )
   endif

   if cPicture != nil
      if "@!" $ cPicture
         FMGetSetUpper( ::hWnd )
      endif
      if "@A" $ cPicture
         FMGetSetAlpha( ::hWnd )
      endif
      if "@D" $ cPicture
         FMGetSetDate( ::hWnd )
      endif
      if "@R" $ cPicture
         // Extract mask: "@R 99.99" -> "99.99"
         // Assumes @R is at the beginning or handled simply
         FMGetSetPicture( ::hWnd, StrTran( cPicture, "@R ", "" ) )
      endif
      if "@E" $ cPicture
         if ValType( Eval( bSetGet ) ) == "N"
            FMGetSetEuroNumber( ::hWnd, StrTran( cPicture, "@E", "" ) )
         elseif ValType( Eval( bSetGet ) ) == "D"
            FMGetSetEuroDate( ::hWnd )
         endif
      elseif "9" $ cPicture // Simple mask like "999"
          FMGetSetPicture( ::hWnd, cPicture )
      endif
   endif
   
   oWnd:AddControl( Self )
   
   if cPicture != nil
      ::SetText( Transform( Eval( bSetGet ), cPicture ) )
   else
      ::SetText( cValToChar( Eval( bSetGet ) ) )
   endif
   
return Self
return Self

METHOD HandleEvent( nMsg, uParam1, uParam2, uParam3 ) CLASS TFMGet

   do case
      case nMsg == WM_GETCHANGED
           if ! Empty( ::bChanged )
              Eval( ::bChanged, Self )
           endif
           ::Assign()
           return nil

      case nMsg == WM_GETVALID
           ::Assign()
           if ! Empty( ::bValid )
              return Eval( ::bValid, Self )
           endif
           return nil

      case nMsg == WM_GETPARTEVALUE
           if ! Empty( ::bIncremental )
              return Eval( ::bIncremental, uParam1, Self )
           endif
           return .T.     
   endcase
   
return Super:HandleEvent( nMsg, uParam1, uParam2, uParam3 )

METHOD Assign() CLASS TFMGet

   local cText := ::GetText()
   local cMask, n, cChar
   
   if ::cPicture != nil .and. "@R" $ ::cPicture
      cMask = StrTran( ::cPicture, "@R ", "" )
      cText = ""
      for n = 1 to Len( ::GetText() )
         cChar = SubStr( ::GetText(), n, 1 )
         if SubStr( cMask, n, 1 ) $ "9#A!LNXY"
            cText += cChar
         endif
      next
   endif
   
   if ValType( Eval( ::bSetGet ) ) == "N"
      if ::cPicture != nil .and. "@E" $ ::cPicture
         // "1.234,56" -> "1234.56" (Remove grouping dots, replace comma with dot)
         cText = StrTran( cText, ".", "" )
         cText = StrTran( cText, ",", "." )
      endif
      cText = Val( cText )
   endif

   if ValType( Eval( ::bSetGet ) ) == "D"
      cText = CToD( cText ) // TODO: This depends on correct date format settings
   endif
   
   Eval( ::bSetGet, cText )

return nil
