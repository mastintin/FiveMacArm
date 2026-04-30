# TSwToggle

El componente **TSwToggle** es un interruptor nativo altamente personalizable. Además del estado On/Off, soporta subtítulos, iconos y el "efecto bounce" premium de macOS.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> TOGGLE [ <oToggle> ] ;
   [ VAR <lValue> ] ;
   [ PROMPT <cPrompt> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ACTION <uAction> ] ;
   [ STYLE <nStyle> ] ;
   [ SUBTITLE <cSubtitle> ] ;
   [ ICON <cIcon> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `Value` | Lógico | Estado del interruptor (.T. o .F.). |
| `Prompt` | String | Etiqueta principal. |
| `Subtitle` | String | Texto secundario descriptivo. |
| `Icon` | String | Símbolo SF Symbol a mostrar junto al texto. |
| `Style` | Numérico | 0: Botón (Checkbox), 1: Switch (Por defecto). |
| `Switch` | Lógico | Acceso directo para cambiar entre modo botón o switch. |
| `Color` | String | Color del interruptor cuando está activo. |
| `TextColor` | String | Color de la etiqueta de texto. |
| `bAction` | Block | Acción a ejecutar al cambiar el estado. |

## Ejemplo de uso

```harbour
@ 50, 50 TOGGLE oTog VAR lStatus PROMPT "Notificaciones" OF oWnd ;
   SUBTITLE "Recibir avisos en tiempo real" ;
   ICON "bell.fill" ;
   ACTION ( msgInfo( "Estado: " + hb_ValToStr( oTog:Value ) ) )
```
