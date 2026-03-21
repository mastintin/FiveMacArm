#include "Fivemac.ch"

#define CF_TEXT              1
#define CF_PNG               2
//#define CF_SOUND            12
/*

#define CF_METAFILEPICT      3
#define CF_SYLK              4
#define CF_DIF               5
#define CF_TIFF              6
#define CF_OEMTEXT           7
#define CF_DIB               8
#define CF_PALETTE           9
#define CF_PENDATA          10
#define CF_RIFF             11
#define CF_WAVE             12
#define CF_UNICODETEXT      13
#define CF_ENHMETAFILE      14
#define CF_HDROP            15
*/

//----------------------------------------------------------------------------//

CLASS TClipBoard

    DATA hClip

    METHOD New() CONSTRUCTOR

    METHOD SetText( cText ) INLINE ClipBoardCopyString( ::hClip, cText )
    METHOD GetText()        INLINE ClipBoardPasteString ( ::hClip )
    METHOD GetName()        INLINE ClipBoardGetName ( ::hClip )
    METHOD Clear()          INLINE ClipBoardClear ( ::hClip )
    METHOD SetPNGImage( hImg )   INLINE CLIPBOARDCOPYPNG ( ::hClip, hImg )
    METHOD SetPNG( oBitmap )
    METHOD GetExtensions()
    METHOD ScreenShot()
    METHOD IsImage()
    METHOD ViewImageInClipboard()
    METHOD CopyFile( cFile )
    METHOD CopyImage( hImg )  INLINE CLIPBOARDCOPYIMAGE( ::hClip, hImg )     

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS TClipBoard

    ::hClip := ClipBoardNew()

return Self

//----------------------------------------------------------------------------//
METHOD SetPNG ( oBitmap ) CLASS TClipBoard
    
    local lResult := .f.
    SetClipBoardData( ::hClip, 2 )
    ::GetPng( NSIMAGEFROMIMAGEVIEW( oBitMap:hWnd ) )
        
return

//----------------------------------------------------------------------------//

METHOD ScreenShot() CLASS TClipBoard
    LOCAL lConcedido := .F.
    ::Clear()
    if Empty( hClip )
        hClip := ClipBoardNew()
    endif
    // 1. Comprobar si ya tenemos permiso
    IF ! HASSCREENRECORDINGPERMISSION()
      
        IF MSGYESNO( "¿Desea permitir que la aplicación capture la pantalla?" + HB_OsNewLine() + ;
                "Se abrirán los Ajustes del Sistema para conceder el permiso.", "Permiso Requerido" )
         
            // 2. Solicitar permiso (Esto abre Preferencias del Sistema > Seguridad y Privacidad)
            REQUESTSCREENRECORDINGPERMISSION()
         
            MSGINFO( "Una vez concedido el permiso, debe reiniciar la aplicación para que los cambios surtan efecto.", "Atención" )
            RETURN
        ENDIF
      
    ELSE
        lConcedido := .T.
    ENDIF

    // 3. Si tenemos permiso, procedemos con la captura
    IF lConcedido
        IF SCREENTOPASTEBOARD( ::hClip )
            MSGINFO( "Captura enviada al portapapeles con éxito." )
        ELSE
            MSGINFO( "Error al realizar la captura de pantalla." )
        ENDIF
    ENDIF

RETURN

//----------------------------------------------------------------------------//

METHOD GetExtensions() CLASS TClipBoard
RETURN CLIPBOARDGETEXTENSIONS( ::hClip )

//----------------------------------------------------------------------------//

METHOD IsImage() CLASS TClipBoard
    local aResult
    aResult := ::GetExtensions()
    if ! Empty( aResult )
        FOR EACH aItem IN aResult
            IF aItem[2] // Es imagen
                return .T.
            ENDIF
        NEXT
    endif    
return .F.

METHOD ViewImageInClipboard() CLASS TClipBoard
    LOCAL nPasteboard := CLIPBOARDNEW()
    LOCAL aArchivos   := {}
    LOCAL cRutaImagen := ""
    LOCAL lEncontrada := .F.
    local aFila 

    // 1. Obtenemos la lista de archivos que hay en el portapapeles
    // CLIPBOARDGETEXTENSIONS devuelve { { "ext", .T./.F. }, ... }
    aArchivos := CLIPBOARDGETEXTENSIONS( nPasteboard )

    IF Empty( aArchivos )
        MSGINFO( "No hay archivos en el portapapeles.", "Atención" )
        RETURN
    ENDIF

    // 2. Buscamos el primer archivo que sea una imagen
    FOR EACH aItem IN aArchivos
        // aFila[1] = Ruta completa
        // aFila[2] = Extensión
        // aFila[3] = .T. si es imagen

        IF aItem[3] // Si es_imagen es .T.
            IF MSGYESNO( "¿Desea previsualizar " + aFila[2] + "?" + HB_OsNewLine() + aFila[1] )
                CLIPBOARDPREVIEWIMAGE( aFila[1] )
            ENDIF
        ELSE
            ? "Archivo encontrado (no es imagen): " + aFila[1]
        ENDIF 
      
    NEXT
RETURN

METHOD CopiarFichero( cFile ) CLASS TClipBoard
    IF File( cFile )
        IF CLIPBOARDCOPYFILE( cFile )
            MSGINFO( "Archivo copiado. Ahora puede pegarlo en el Finder o en un Email.", "Éxito" )
        ELSE
            MSGINFO( "No se pudo copiar el archivo al portapapeles.", "Error" )
        ENDIF
    ELSE
        MSGINFO( "El archivo no existe: " + cFile )
    ENDIF
RETURN
