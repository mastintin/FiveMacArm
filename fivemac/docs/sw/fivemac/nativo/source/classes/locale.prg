#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS TLocale 

   DATA hWnd

   METHOD New(cId )
   
   METHOD isMetric() INLINE Locale_MesureIsMetric( ::hWnd )
   METHOD GetMesureSystem() INLINE LocaleGetMesureSystem( ::hWnd )
   METHOD GetPrefId() INLINE LocaleGetPrefID()
   METHOD GetName() INLINE LocaleGetName( ::hWnd )
   METHOD End() INLINE Locale_Release( ::hWnd )   
   METHOD GetLanguage() INLINE Locale_GetLanguage( ::hWnd )
   METHOD GetCountry() INLINE Locale_GetCountry( ::hWnd )
   method setLanguage( cLanguage ) INLINE Locale_SetLanguage( cLanguage ) 
   method setCountry( cCountry ) INLINE Locale_SetCountry( cCountry ) 
   METHOD GetCurrencySymbol() INLINE Locale_GetCurrencySymbol( ::hWnd )

ENDCLASS   

//----------------------------------------------------------------------------//

METHOD New( cId ) CLASS TLocale

   if Empty( cid )
      ::hWnd = LocaleCurrent()    
   else
      ::hWnd = LocaleCreateFromID( cId )
   endif  
          
return Self   

//----------------------------------------------------------------------------//
