#include "swfive.ch"

function Main()
   HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
   local oWnd
   
   SW_LOG( "TestSimple: DEFINE WINDOW" )
   DEFINE WINDOW oWnd TITLE "Test Simple" SIZE 400, 300
   
   SW_LOG( "TestSimple: Center" )
   oWnd:Center()
   
   SW_LOG( "TestSimple: Activate" )
   oWnd:Activate()
   SW_LOG( "TestSimple: Done" )
return nil
