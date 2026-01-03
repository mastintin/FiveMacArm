#include "FiveMac.ch"

function Main()
   local oDlg
   
   DEFINE DIALOG oDlg TITLE "Screen Capture to Clipboard Test" SIZE 400, 200

   @ 40, 40 BUTTON "Capture Screen" OF oDlg ;
      ACTION CaptureScreen() ;
      SIZE 320, 40
      
   @ 100, 150 BUTTON "Close" OF oDlg ACTION oDlg:End()

   ACTIVATE DIALOG oDlg CENTERED
return nil

function CaptureScreen()
   local oClip := TClipBoard():New()
   
   MsgInfo( "About to capture screen... (will take ~1-2 seconds)" )
   
   if oClip:ScreenShot()
      MsgInfo( "Screen captured to Clipboard!" )
   else
      MsgAlert( "Capture Failed." )
   endif
   
return nil
