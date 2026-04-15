#include "FiveMac.ch"

CLASS TSwAIChat FROM TSwiftControl

   METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cApiKey, cModel, cApiUrl )
   METHOD Clear()

ENDCLASS

METHOD Clear() CLASS TSwAIChat
   SwMsgInfo( "Harbour: Entrando en AIChat:Clear() para " + ::cId )
   SW_AICHAT_CLEAR( ::cId )
return nil

METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, cApiKey, cModel, cApiUrl ) CLASS TSwAIChat

   ::cId := hb_UUID()
   ::nTop := nTop
   ::nLeft := nLeft
   ::nWidth := nWidth
   ::nHeight := nHeight
   ::oWnd := oWnd

   // 1. Crear el estado en Swift
   SW_AICHAT_CREATE_STATE( ::cId, cApiKey, cModel, cApiUrl )

   // 2. Añadirlo a la ventana (Tipo 17)
   if !Empty( oWnd )
      oWnd:AddControl( Self, nTop, nLeft )
   endif

return Self
