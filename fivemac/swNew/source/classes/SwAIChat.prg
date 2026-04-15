#include "FiveMac.ch"

//----------------------------------------------------------------------------//

CLASS SwAIChat FROM TSwControl

   DATA cApiKey
   DATA cModel
   DATA cApiUrl
   DATA cSystem

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cApiKey, cModel, cApiUrl, cSystem, cId )
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cApiKey, cModel, cApiUrl, cSystem, cId ) CLASS SwAIChat

   local hParams

   DEFAULT nWidth := 400, nHeight := 300, oWnd := GetWndDefault(), ;
           cApiKey := "", cModel := "llama-3.3-70b-versatile", ;
           cApiUrl := "https://api.groq.com/openai/v1/chat/completions", ;
           cSystem := "You are a helpful assistant."

   if Empty( cId ) 
      cId := "AIC_" + AllTrim( Str( hb_RandomInt( 1, 99999 ) ) )
   endif

   ::Super:New( nTop, nLeft, nWidth, nHeight, cId )
   ::oWnd := oWnd

   hParams := { "apiKey" => cApiKey, "model" => cModel, "apiUrl" => cApiUrl, "system" => cSystem }
   
   SD_SW_AICHAT_CREATE( nTop, nLeft, nWidth, nHeight, hb_jsonEncode( hParams ), oWnd:hWnd, ::cId )

   if !Empty( oWnd ) .and. oWnd:IsKindOf( "TSWWINDOW" )
      oWnd:AddControl( Self )
   endif

return Self
