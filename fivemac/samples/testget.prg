#include "FiveMac.ch"

function Main()

   local oDlg
   local oget, oget1, oget2, oGet3
   local oBtnOk
   local nTest := 12345.232
   local cText := "Hello world"
   local dTest := Date()
   local cPhone := "1234567890"
   
   SET DATE FRENCH
   
   DEFINE DIALOG oDlg TITLE "TestGet" SIZE 400, 200 

   @ 15, 30 SAY "Number:" OF oDlg
   
   @ 15, 90 GET oget VAr nTest OF oDlg  PICTURE "9999999.99"  TOOLTIP "a number"


   @ 45, 30 SAY "String:" OF oDlg

   @ 45, 90 GET oGet2 VAR cText OF oDlg TOOLTIP "a string" SIZE 200, 25

   // oGet2:bKeyDown := ... // Removed broken logic
   
   @ 75, 30 SAY "Date:" OF oDlg

   @ 75, 90 GET oget1 VAR dTest PICTURE "@D" OF oDlg TOOLTIP "a date"
   
   @ 105, 30 SAY "Phone:" OF oDlg
   @ 105, 90 GET oGet3 VAR cPhone PICTURE "@R (999) 999-9999" OF oDlg SIZE 150, 25 TOOLTIP "Phone number"
   
   @ 140, 150 BUTTON oBtnOk PROMPT "Ok" OF oDlg ACTION msginfo( valtype( nTest ) + CRLF + Str( nTest ) + CRLF + cText + CRLF + Dtoc( dTest ) ), oBtnOk:SetFocus()

   oget2:setfocus()

   ACTIVATE DIALOG oDlg CENTERED

return nil
