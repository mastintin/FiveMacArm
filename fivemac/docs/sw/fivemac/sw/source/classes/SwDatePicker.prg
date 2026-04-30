#include "swfive.ch"

#define SW_TYPE_DATEPICKER 15

CLASS TSwDatePicker FROM TSwiftControl

   DATA bOnChange

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, dDate, nStyle )
   
   ACCESS dDate        INLINE ::GetDate()
   ASSIGN dDate( d )   INLINE ::SetDate( d )

   ACCESS nStyle       INLINE ::GetStyle()
   ASSIGN nStyle( n )  INLINE ::SetStyle( n )

   METHOD SetDate( dDate )
   METHOD GetDate()
   METHOD SetStyle( nStyle ) // 0: compact, 1: graphical, 2: wheel, 3: field
   METHOD GetStyle()
   
   METHOD Update( hNewState )

ENDCLASS

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, dDate, nStyle ) CLASS TSwDatePicker

   DEFAULT nWidth := 140, nHeight := 30, dDate := Date(), nStyle := 0

   ::Super:New( nTop, nLeft, nWidth, nHeight )
   
   ::oWnd := oWnd
   if hb_IsObject( oWnd )
      ::hState["parentid"] := oWnd:cId
   endif

   ::hState["type"]     := SW_TYPE_DATEPICKER
   ::hState["date"]     := dtos( dDate )
   ::hState["style"]    := nStyle
   ::hState["showdate"] := .t.
   ::hState["showtime"] := .f.

   ::Create()

return self

METHOD SetDate( dDate ) CLASS TSwDatePicker
   ::hState["date"] := dtos( dDate )
   ::Apply( { "date" => ::hState["date"] } )
return nil

METHOD GetDate() CLASS TSwDatePicker
   local uVal := ::Query():date 
   if !Empty( uVal ) .and. ValType( uVal ) == "C"
      ::hState["date"] := uVal
      return STOD( StrTran( Left( uVal, 10 ), "-", "" ) )
   endif
return STOD( StrTran( Left( hb_HGetDef( ::hState, "date", dtos(Date()) ), 10 ), "-", "" ) )

METHOD SetStyle( nStyle ) CLASS TSwDatePicker
   ::hState["style"] := nStyle
   ::Apply( { "style" => nStyle } )
return nil

METHOD GetStyle() CLASS TSwDatePicker
   local uVal := ::Query():style
   if !Empty( uVal ) .and. ValType( uVal ) == "N"
      ::hState["style"] := uVal
      return uVal
   endif
return hb_HGetDef( ::hState, "style", 0 )

METHOD Update( hNewState ) CLASS TSwDatePicker
   local cDate
   
   ::Super:Update( hNewState )
   
   if hb_HHasKey( hNewState, "event" ) .and. hNewState["event"] == "change"
      if hb_HHasKey( hNewState, "date" )
         cDate := hNewState["date"]
         ::hState["date"] := cDate
         if ::bOnChange != nil
            Eval( ::bOnChange, STOD( StrTran( Left( cDate, 10 ), "-", "" ) ), self )
         endif
      endif
   endif
   
return nil
