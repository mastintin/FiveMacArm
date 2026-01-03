
#include "FiveMac.ch"

function Main()
   local oWnd, oMovie

   DEFINE WINDOW oWnd TITLE "Test AVFoundation" SIZE 800, 600

   @ 10, 10 MOVIE oMovie SIZE 780, 500 OF oWnd FILENAME "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"

   @ 530, 300 BUTTON "Play" OF oWnd ACTION oMovie:Play()
   @ 530, 400 BUTTON "Pause" OF oWnd ACTION oMovie:Pause()

   ACTIVATE WINDOW oWnd
return nil
