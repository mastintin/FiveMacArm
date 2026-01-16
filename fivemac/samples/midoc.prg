#include "FiveMac.ch"

function BuildWindow()

   local oForm2, oBtn1, oBtn2, oWeb1

   DEFINE WINDOW oForm2 ;
      TITLE "Form2" ;
      SIZE 1037, 844 FLIPPED

   @ 781, 891 BUTTON oBtn1 PROMPT "Button" OF oForm2 ;
      SIZE 90, 30

   @ 781, 771 BUTTON oBtn2 PROMPT "Button" OF oForm2 ;
      SIZE 90, 30

   ACTIVATE WINDOW oForm2 CENTERED 

return oForm2