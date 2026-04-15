#include "fivemac.ch"

//----------------------------------------------------------------------------//

CLASS TSwiftAIChat FROM TSwiftControl

   DATA cApiKey
   DATA cModel
   DATA cApiUrl
   DATA cSystem

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cApiKey, cModel, cApiUrl, cSystem, cId )
   
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cApiKey, cModel, cApiUrl, cSystem, cId ) CLASS TSwiftAIChat

   local hParams

   DEFAULT nWidth := 300, nHeight := 400
   DEFAULT cModel := "llama-3.3-70b-versatile"
   DEFAULT cApiKey := ""
   DEFAULT cApiUrl := "https://api.groq.com/openai/v1/chat/completions"
   DEFAULT cSystem := "Eres un asistente experto en Harbour y FiveMac."
   DEFAULT oWnd := GetWndDefault()

   ::Super:New( nTop, nLeft, nWidth, nHeight, cId )

   ::cApiKey = cApiKey
   ::cModel  = cModel
   ::cApiUrl = cApiUrl
   ::cSystem = cSystem
   ::oWnd    = oWnd

   // Construimos el hash de parámetros para el JSON
   hParams := { "apikey" => ::cApiKey, ;
                "model"  => ::cModel, ;
                "apiurl" => ::cApiUrl, ;
                "system" => ::cSystem }

   // Registramos y creamos el control nativo
   ::Register( SD_SW_AICHAT_CREATE( nTop, nLeft, nWidth, nHeight, hb_jsonEncode( hParams ), oWnd:hWnd, ::cId ) )
   
   oWnd:AddControl( Self )

return Self

//----------------------------------------------------------------------------//
