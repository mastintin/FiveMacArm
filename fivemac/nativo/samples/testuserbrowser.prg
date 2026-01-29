#include "FiveMac.ch"

// Test for User Provided NSCollectionView Code

function Main()

    local oWnd

    DEFINE WINDOW oWnd TITLE "User Test Browser (NSDiffableDataSource)" ;
        FROM 200, 200 TO 600, 800

    // Call the C function to create and attach the browser
    // Param: Window Handle
    TESTBROWSER_CREATE( oWnd:hWnd )

    ACTIVATE WINDOW oWnd

return nil
