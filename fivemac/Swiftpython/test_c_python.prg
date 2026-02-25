#include "FiveMac.ch"

function Main()
    local oWnd, oBtn, oPython
    local cPythonPath := hb_DirBase() + "Python.xcframework/macos-arm64_x86_64/Python.framework/Versions/3.14"

    // Inicializa la clase Wrapper TPython
    oPython := TPython():New( cPythonPath )

    DEFINE WINDOW oWnd TITLE "FiveMac + CPython C-API" SIZE 400, 300
   
    @ 100, 100 BUTTON oBtn PROMPT "Test Python Home" OF oWnd SIZE 200, 40 ;
        ACTION MsgInfo( "PythonHome configurado a: " + oPython:cPythonHome )

    @ 150, 100 BUTTON oBtn2 PROMPT "Run Python Script" OF oWnd SIZE 200, 40 ;
        ACTION oPython:Run( 'import sys; print("Versión CPython C-API embebida:", sys.version)' )

    @ 200, 100 BUTTON oBtn3 PROMPT "Eval Python Pow(2,8)" OF oWnd SIZE 200, 40 ;
        ACTION MsgInfo( "Resultado de Math.pow(2, 8): " + cValToChar( oPython:Call( "math", "pow", 2, 8 ) ), "Retorno Parametrizado CPython" )

    ACTIVATE WINDOW oWnd

    oPython:End()
return nil
