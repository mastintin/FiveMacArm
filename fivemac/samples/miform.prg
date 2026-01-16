#include "FiveMac.ch"
function Main()

   local oForm1, oWeb1, oBtn1, oBtn2

   DEFINE WINDOW oForm1 ;
      TITLE "Form1" ;
      SIZE 882, 641 FLIPPED

   @ 50, 30 WEBVIEW oWeb1 OF oForm1 SIZE 813, 505

   @ 586, 758 BUTTON oBtn1 PROMPT "Button" OF oForm1 ;
      SIZE 90, 30

   @ 586, 650 BUTTON oBtn2 PROMPT "Button" OF oForm1 ;
      SIZE 90, 30

   ACTIVATE WINDOW oForm1 CENTERED 
   
return oForm1