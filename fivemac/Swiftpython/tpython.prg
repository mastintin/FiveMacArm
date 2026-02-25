#include "hbclass.ch"

REQUEST C_PY_CALL

CLASS TPython
    DATA  cPythonHome

    METHOD New( cPath ) CONSTRUCTOR
    METHOD End()
    METHOD Run( cScript )
    METHOD Call( cModule, cFunc, ... )
ENDCLASS

METHOD New( cPath ) CLASS TPython
    ::cPythonHome := cPath
    C_PY_INITIALIZE( ::cPythonHome )
return Self

METHOD End() CLASS TPython
    C_PY_FINALIZE()
return nil

METHOD Run( cScript ) CLASS TPython
    C_PY_RUN_SCRIPT( cScript )
return nil

METHOD Call( cModule, cFunc, ... ) CLASS TPython
    // Los parametros variables ... se envían intactos (by reference/value dependiendo)
    // hacia la funcion C_PY_CALL que desempaquetará dinámicamente usando hb_pcount()
    local ret
    
    // hb_execFromArray permite invocar dinámicamente pasando nuestro array de argumentos
    // hb_aParams() devuelve TODOS los argumentos pasados al método, incluyendo cModule y cFunc
    ret := hb_execFromArray( "C_PY_CALL", hb_aParams() )
return ret
