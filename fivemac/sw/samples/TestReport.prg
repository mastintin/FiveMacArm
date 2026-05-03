#include "swfive.ch"

function Main()
    HSW_START_SWIFT( "AppMain" )
return nil

function AppMain()
    local oWnd, oBtn
    
    DEFINE WINDOW oWnd TITLE "Fivemac SW: Modern Reports" SIZE 400, 300
    
    @ 100, 100 BUTTON oBtn PROMPT "Generate Premium Report" SIZE 200, 40 OF oWnd ;
        ACTION CreateMyReport()
        
    ACTIVATE WINDOW oWnd CENTERED
return nil

function CreateMyReport()
    local oRpt := TSwReport():New( "Invoicing Report 2026" )
    
    oRpt:AddHeader( "TechSolutions Inc.", ".blue", "building.2.fill" )
    oRpt:AddText( "Date: " + DToC( Date() ), 12, ".gray" )
    oRpt:AddDivider()
    
    oRpt:AddText( "Customer: FiveTech Software", 16, ".primary" )
    oRpt:AddText( "Status: PAID", 14, ".green" )
    oRpt:AddDivider()
    
    oRpt:AddTable( { "Description", "Qty", "Price", "Total" }, ;
                   { { "Cloud Hosting", "1", "$500", "$500" }, ;
                     { "Consultancy", "5", "$200", "$1000" }, ;
                     { "Support Plan", "1", "$150", "$150" } } )
                     
    oRpt:AddDivider()
    oRpt:AddText( "TOTAL AMOUNT: $1650", 18, ".blue" )
    
    oRpt:Show()
return nil
