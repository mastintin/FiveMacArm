#include "FiveMac.ch"

function Main()

   local oDlg   
   local cImgPath := UserPath() + "/five/Fivemac/fivemac/bitmaps/"
   local cFile
   local cTO:="mastintin@gmail.com"
   local cAsunto:= "primer intento"
   local cMensaje:=  "Hola como estas"
   local cFrom:= "manuel@telecable.es"
   local oMail
   
   
   DEFINE DIALOG oDlg TITLE "Testing mail" ;
      FROM 70, 50 TO 500, 740
      
             
  //   cfile:= cImgPath+"puerto.jpg"
     
     cfile:=choosefile(,"jpg")
  
                    
   DEFINE MAIL oMail TO cto SUBJECT cAsunto ;
                     FROM cFrom MESSAGE cMensaje

   ? cFile

   MAIL oMail ATTACH cFile
                    
  // oMail:=TMail():new(cTo,cAsunto,cFrom,cMensaje )

 //  oMail:addAttach(cFile)
           
                         
   @ 22, 83 BUTTON "Mailme" OF oDlg ACTION  oMail:send()
   
   @ 22, 218 BUTTON "Cancel" OF oDlg ACTION oDlg:End()
   
     
   ACTIVATE DIALOG oDlg CENTERED
   
   
   
return nil   
 
