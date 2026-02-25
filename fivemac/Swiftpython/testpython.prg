#include "FiveMac.ch"

function Main()
    local oWnd, oBtn
    local cPythonPath := hb_DirBase() + "Python.xcframework/macos-arm64_x86_64/Python.framework/Versions/3.14"

    // Inicializa Python usando el framework embebido
    SET_PYTHON_HOME( cPythonPath )

    DEFINE WINDOW oWnd TITLE "FiveMac + Python Experimental" SIZE 400, 300
   
    @ 100, 100 BUTTON oBtn PROMPT "Test Python Home" OF oWnd SIZE 200, 40 ;
        ACTION MsgInfo( "PythonHome configurado a: " + cPythonPath )

    @ 150, 100 BUTTON oBtn2 PROMPT "Run Python Script" OF oWnd SIZE 200, 40 ;
        ACTION SWIFTPYTHON_EVAL( 'import sys; print("Versión Python embebida activa:", sys.version)' )

    @ 200, 100 BUTTON oBtn3 PROMPT "Eval Python Expr" OF oWnd SIZE 200, 40 ;
        ACTION MsgInfo( "Resultado de Python: " + SWIFTPYTHON_EVALUATE( "'Hola desde Python. ' + str(5 * 8)" ), "Retorno SwiftPython" )

    ACTIVATE WINDOW oWnd

return nil
