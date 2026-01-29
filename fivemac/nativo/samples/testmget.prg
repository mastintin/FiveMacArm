#include "FiveMac.ch"

function Main()

   local oWnd, oBtnOk
   local cTest := "Hello world!"
   local oGEt
   local cTekst := "äñê"
   local cText := ""
   local cAanteken
   
   DEFINE WINDOW oWnd TITLE "TestGet" FROM 300, 300 TO 800, 900
   
   @ 150, 40 SAY "Name:" OF oWnd
   
   @ 65, 90 GET oget VAR cTest MEMO OF oWnd ;
      SIZE oWnd:nWidth - 140, oWnd:nHeight - 120
  
      oGET:SetRichText(.t.)
      oGet:AddHRuler()
      oGet:SetImportGraf(.t.)
      oget:SetUndo(.t.)      
      
           IF LEN(ALLTRIM(cTekst)) > 0
          cText := cTekst
          
          //oGet:SetAttributedString(cTekst)
          oGet:setutf8Text( cTekst )
      ENDIF
     // oGet:GoTop()
           

          @ 30, 150 BUTTON oBtnOk PROMPT "Ok" OF oWnd ACTION cAanteken := oGet:GetRTF(), oWnd:END()
          oBtnOk:SetFont( 'Arial', 14 )
   
   
   ACTIVATE WINDOW oWnd
         
return nil     


