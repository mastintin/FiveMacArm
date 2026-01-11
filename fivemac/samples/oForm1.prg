#include "FiveMac.ch"

function BuildWindow()

   local oForm1, oGrp1, oGet1, cGet1 := Space( 20 )

   DEFINE WINDOW oForm1 ;
      TITLE "Form1" ;
      SIZE 752, 409 FLIPPED

   @ 145, 434 GROUP oGrp1 PROMPT "Group" OF oForm1 ;
      SIZE 200, 200

   @ -43, -323 GET oGet1 VAR cGet1 OF oGrp1 ;
      SIZE 120, 20

   ACTIVATE WINDOW oForm1 CENTERED 

return oForm1