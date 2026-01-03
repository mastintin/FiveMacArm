// Building our first window

#include "FiveMac.ch"


#define CLR_BLACK             0             
#define CLR_BLUE        8388608   
          
//----------------------------------------------------------------------------//

function Main()

   local oWnd, oSay,oSay2, osay3
   local oDbf, n
    local oGetFirst, oGetLast, oGetStreet
    local cAlias

  //PUBLIC cDbfpath:= apppath()+"/dbf/"
  
PUBLIC   cDbfPath := Path()+"/"

PUBLIC oProg


//USE ( cDbfPath+"Test.dbf" )

USE ( cDbfPath+"lin_cli.dbf" )

cAlias= Alias()



DATABASE oDbf

DEFINE WINDOW oWnd TITLE "Tutor02" ;
FROM 200, 200 TO 600, 900

   DEFINE MSGBAR OF oWnd



 @ 400,10 SAY osayBar PROMPT "A FiveMac MsgBar" OF oWnd SIZE 150, 20    

 @ 350, 10 PROGRESS oProg SIZE 510, 20 OF oWnd AUTORESIZE 9
 
 
         

oProg:Update( 0 )


/*
@ 0, 10 SAY "A FiveMac MsgBar" OF oWnd SIZE 150, 20 RAISED
   
   @ 70,10 SAY osay PROMPT "A FiveMac MsgBar" OF oWnd SIZE 150, 20    
   osay:setTextColor(0,255,0,100)
   
      @ 140,10 SAY osay2 PROMPT "A FiveMac MsgBar" OF oWnd SIZE 150, 20    
      
    osay2:setBkColor(0,0,128,100)
        
    osay2:setBezeled(.t.,.f.)   
   
   
    @ 200,10 SAY osay3 PROMPT "A FiveMac MsgBar" OF oWnd SIZE 150, 20    
      
    osay3:setColor(CLR_BLUE ,CLR_BLACK )
    osay3:setBezeled(.t.,.t.)  
    osay3:SetSizeFont(14) 
    osay3:setAlign(1)
*/


for n = 1 to FCount()
@ 390 - ( n * 30 ), 40 SAY FieldName( n ) + ":" OF oWnd SIZE 70, 20
@ 390 - ( n * 30 ), 120 GET oGet VAR oDbf:aBuffer[ n ] OF oWnd SIZE 250, 20
oGet:bSetGet = DbfBuffer( oDbf, n )
next

@ 15,  30 BUTTON "Top" OF oWnd SIZE 90, 30 ;
ACTION oDbf:GoTop(), AEval( oWnd:aControls, { | o | o:Refresh() } )

@ 15, 140 BUTTON "Prev" OF oWnd SIZE 90, 30 ;
ACTION oDbf:Skip( -1 ), AEval( oWnd:aControls, { | o | o:Refresh() } )

@ 15, 250 BUTTON "Next" OF oWnd SIZE 90, 30 ;
ACTION oDbf:Skip( 1 ), AEval( oWnd:aControls, { | o | o:Refresh() } )

@ 15, 360 BUTTON "Bottom" OF oWnd SIZE 90, 30 ;
ACTION oDbf:GoBottom(), AEval( oWnd:aControls, { | o | o:Refresh() } )

@ 15, 470 BUTTON "End" OF oWnd SIZE 90, 30 ACTION oWnd:End()

@ 15, 580 BUTTON "index" OF oWnd SIZE 90, 30 ACTION index(calias)



      ACTIVATE WINDOW oWnd ;
          VALID MsgYesNo( "Want to end ?" )

return nil


//----------------------------------------------------------------------------//

function DbfBuffer( oDbf, n )

return { | u | If( PCount() == 0, oDbf:aBuffer[ n ], oDbf:aBuffer[ n ] := u ) }



//----------------------------------------------------------------------------//



function index(calias)



INDEX ON (calias)->articulo TO (cDbfPath+"lin_cli1")  EVAL NtxProgress() EVERY LASTREC()/100

 

return nil



FUNCTION NtxProgress()

local wnd

LOCAL nComplete := INT((RECNO()/LASTREC()) * 100)

//MSGWAIT( "indice", ncomplete ,0.01 )

 RoundMsg(ncomplete,10)

oProg:Update( nComplete )

oSayBar:SetText('Gedaan: ' + ALLTRIM(STR(nComplete)) + ' %')




SysRefresh()

RETURN .T.








