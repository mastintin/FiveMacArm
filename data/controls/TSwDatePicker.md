# TSwDatePicker

El componente **TSwDatePicker** proporciona un selector de fecha nativo de macOS con soporte para múltiples estilos visuales, desde compactos hasta calendarios completos.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> DATEPICKER [ <oDate> ] ;
   [ VAR <dDate> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ STYLE <nStyle> ] ;
   [ ON CHANGE <uAction> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `dDate` | Fecha | La fecha seleccionada en el control. |
| `nStyle` | Numérico | Estilo visual del selector: <br>0: Compacto (Default) <br>1: Gráfico (Calendario abierto) <br>2: Rueda (Wheel) <br>3: Campo de texto |
| `bOnChange` | Block | Acción a ejecutar cuando el usuario cambia la fecha. |

## Ejemplo de uso

```harbour
@ 50, 50 DATEPICKER oDate VAR dHoy OF oWnd ;
   STYLE 1 ; // Calendario gráfico
   ON CHANGE ( msgInfo( "Fecha seleccionada: " + DToC( oDate:dDate ) ) )
```
