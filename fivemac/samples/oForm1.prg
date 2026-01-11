#include "FiveMac.ch"

function BuildWindow()

   local oForm1, oBtn1, oBtn2, oImg1

   DEFINE WINDOW oForm1 ;
      TITLE "Form1" ;
      SIZE 500, 356

   @ 19, 369 BUTTON oBtn1 PROMPT "aceptar" OF oForm1 ;
      SIZE 90, 30

   @ 20, 260 BUTTON oBtn2 PROMPT "Cancelar" OF oForm1 ;
      SIZE 90, 30

   @ 122, 75 IMAGE oImg1 OF oForm1 ;
      FILENAME "/Users/manuel/five/Fivemac/fivemac/samples/fivedit.app/Contents/Resources/bitmaps/fivetech.gif" ;
      SIZE 340, 162

   ACTIVATE WINDOW oForm1 CENTERED 

return oForm1