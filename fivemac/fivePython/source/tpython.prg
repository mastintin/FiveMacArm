#include "hbclass.ch"

REQUEST C_PY_CALL

CLASS TPython
    DATA  cPythonHome

    METHOD New( cPath ) CONSTRUCTOR
    METHOD End()
    METHOD Run( cScript )
    METHOD Call( cModule, cFunc, ... )
    METHOD IsReady() INLINE .T. // Por ahora devolvemos .T. si el objeto se pudo crear
ENDCLASS

METHOD New( cPath ) CLASS TPython
    local cInternalPy := hb_DirBase() + "../Frameworks/Python.framework/Versions/Current"
    
    if Empty( cPath ) .and. hb_DirExists( cInternalPy )
    cPath := hb_DirBase() + "../Frameworks/Python.framework/Versions/Current"
    endif

    ::cPythonHome := cPath
    C_PY_INITIALIZE( ::cPythonHome )
    
    // Aseguramos que Python encuentre módulos locales
    ::Run( "import sys; sys.path.append('" + hb_DirBase() + "')" )
    // Si estamos en un bundle, los recursos están en ../Resources
    if hb_DirExists( hb_DirBase() + "../Resources" )
    ::Run( "import sys; sys.path.append('" + hb_DirBase() + "../Resources" + "')" )
    endif
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
