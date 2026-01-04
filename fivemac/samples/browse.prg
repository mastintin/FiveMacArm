#include "FiveMac.ch"

static oBrw


extern dbfcdx, DBCloseArea, DbUseArea, DbGoTo, OrdSetFocus

function Main()

   local oWnd, oBrw
   local cpath:=Path()
   local cAlias 
   // local cpath:=CurrentPath()
   //local cpath:= "/Volumes/Escritorio/cuadrosapp"
   local cImgPath := UserPath() + "/five/Fivemac/fivemac/bitmaps/"
   local oPopUp,nHandle
   local nBrowRowActive

 RddSetDefault( "DBFCDX" )
   SET DELETED ON

//   USE ( cpath+"/test.dbf" )

 if file(  cpath+"/test.dbf")
    msginfo( "si")
 else
    msginfo( "no")
 endif
 
 
USE ( cpath+"/test.dbf" )  EXCLUSIVE
cAlias := alias()

msginfo(cAlias)

 
   DEFINE WINDOW oWnd TITLE "DBF Browse" ;
      FROM 213, 109 TO 650, 820
      @ 48, 20 BROWSE oBrw ;
      FIELDS If( Int( (cAlias)->(RecNo()) % 2 ) == 0, cImgPath+"ok.png", cImgPath+"alert.png" ),(cAlias)->Last, (cAlias)->First ;
       HEADERS "image", "Last", "First" ;
            OF oWnd SIZE 672, 363  AUTORESIZE 18 ;

   @ 8,  10 BUTTON "Top"    OF oWnd ACTION oBrw:GoTop()
   @ 8, 130 BUTTON "Bottom" OF oWnd ACTION oBrw:GoBottom()
   @ 8, 250 BUTTON "Delete" OF oWnd ACTION oBrw:SetColWidth( 2, 300 )
   @ 8, 370 BUTTON "Search" OF oWnd ACTION MsgAlertSheet( oBrw:GetColWidth( 2 ), oWnd:hWnd )
   @ 8, 490 BUTTON "Grid"  OF oWnd ACTION ( oBrw:SetGridLines( 2 ), MsgInfo( oBrw:GetGridLines() ) )
   @ 8, 610 BUTTON "Exit"   OF oWnd ACTION oWnd:End()

   oBrw:SetColBmp( 1 ) // Column 1 will display images

   oBrw:setFont("arial", 20 )
   oBrw:Anclaje( nOr( 16, 2 ) )
   oBrw:SetRowHeight(40)

   oBrw:bHeadClick:= { | obj , nindex| if(nindex== 1, msginfo("clickada cabecera"+str(nindex)),)  } 
 
   oBrw:bDrawRect:=  { | nRow | (cAlias)->(dbskip()),;
                  if(left((cAlias)->Last,1) =="L", BRWSETGRADICOLOR(oBrw:hWnd,nRow,ETIQUETGRADCOLORS("orange") ), ) , (cAlias)->(dbskip(-1)) }


   oBrw:bClrText = { | pColumn, nRowIndex | ColorFromNRGB( If( nRowIndex % 2 == 0, CLR_RED, CLR_GREEN ) ) }

   // oBrw:bAction = { | obj, nindex |  MsgInfo( oBrw:nColPos() ) }

   oBrw:bMouseDown = { | nRow, nCol, oControl |  MsgInfo( Str( nCol ) ) }

   oBrw:bRClicked := { | nRow,nCol, nRowBrw, nColBrw, oControl | (  oBrw:Select( nRowBrw + 1 ), ShowPop( nRow, nCol, opopUp, oBrw:oWnd ) ) }
   
   oPopup = BuildMenu(oBrw )
   
   ACTIVATE WINDOW oWnd



return nil

//----------------------------------------------------------------------------//

function BuildMenu( oBrw )

local oMenu
local cImgPath := UserPath() + "/five/Fivemac/fivemac/bitmaps/"

MENU oMenu POPUP
MENUITEM "Go bottom" ACTION  oBrw:GoBottom()
MENUITEM "About" ACTION MsgInfo( "FiveMac sample" )
SEPARATOR
MENUITEM "Help"  ACTION MsgInfo( "Help" ) IMAGE "ColorPanel"
ENDMENU

return oMenu

//----------------------------------------------------------------------------//

function ShowPop( nRow, nCol , oPopUP, oWnd )

  ACTIVATE POPUP oPopup OF oWnd AT nRow, nCol

return nil
