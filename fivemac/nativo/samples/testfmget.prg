#include "FiveMac.ch"

function Main()

   local oWnd, oGet, oGet2, oGet3, oGet4, oGet5, oGet6, oGet7, oGet8, oGet9
    local oGet10
   local cText := "Hello world"
   local nVal  := 123.45
   local dDate := Date()
   local nEuroNum := 12345.67
   local dEuroDate := Date()

   DEFINE WINDOW oWnd TITLE "Testing TFMGet" ;
      FROM 200, 200 TO 400, 600

   @ 40, 40 FMGET oGet VAR cText OF oWnd SIZE 200, 24 ;
      VALID ( MsgInfo( "Valid: " + cText ), .T. )


   @ 80, 40 FMGET oGet2 VAR nVal OF oWnd SIZE 200, 24 ;
      ON CHANGE MsgInfo( "Changed: " + Str( nVal ) )

   @ 130, 40 FMGET oGet3 VAR cText OF oWnd SIZE 200, 24 ;
      INCREMENTAL {| cChar, oGet | MsgInfo( cChar ), .T. }

   @ 180, 40 FMGET oGet4 VAR cText OF oWnd SIZE 200, 24 PICTURE "@!"

   @ 230, 40 FMGET oGet5 VAR cText OF oWnd SIZE 200, 24 PICTURE "@A"

   @ 280, 40 FMGET oGet6 VAR dDate OF oWnd SIZE 200, 24 PICTURE "@D"
   @ 280, 40 FMGET oGet6 VAR dDate OF oWnd SIZE 200, 24 PICTURE "@D"

   @ 330, 40 FMGET oGet7 VAR cText OF oWnd SIZE 200, 24 PICTURE "@R 999-999 999 999"

   @ 380, 40 FMGET oGet8 VAR nEuroNum OF oWnd SIZE 200, 24 PICTURE "@E 9,999.99"
   
   @ 430, 40 FMGET oGet9 VAR dEuroDate OF oWnd SIZE 200, 24 PICTURE "@E"

   @ 480, 40 FMGET oGet10 VAR nEuroNum OF oWnd SIZE 200, 24 PICTURE "999.99"
   
   @ 530, 40 SAY "Formatted Date:" OF oWnd SIZE 120, 20
   @ 530, 170 SAY dEuroDate OF oWnd SIZE 200, 20 PICTURE "@D"

   @ 560, 40 BUTTON "Check " OF oWnd ACTION MsgInfo( cText )

   ACTIVATE WINDOW oWnd

return nil
