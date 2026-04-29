# TSwSlider

El componente **TSwSlider** permite la selección de valores numéricos dentro de un rango determinado de forma visual y fluida.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> SLIDER [ <oSlider> ] ;
   [ VAR <nValue> ] ;
   [ MIN <nMin> ] ;
   [ MAX <nMax> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ACTION <uAction> ] ;
   [ PROMPT <cPrompt> ] ;
   [ ICONMIN <cIconMin> ] ;
   [ ICONMAX <cIconMax> ] ;
   [ COLOR <cColor> ] ;
   [ STEP <nStep> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `Value` | Numérico | Valor actual del slider. |
| `Min` | Numérico | Valor mínimo del rango. |
| `Max` | Numérico | Valor máximo del rango. |
| `Prompt` | String | Etiqueta descriptiva opcional. |
| `IconMin` | String | SF Symbol para el extremo inferior. |
| `IconMax` | String | SF Symbol para el extremo superior. |
| `TintColor` | String | Color de la barra de progreso. |
| `Step` | Numérico | Incremento mínimo del valor (0 para continuo). |
| `bAction` | Block | Acción a ejecutar mientras se desliza. |

## Ejemplo de uso

```harbour
@ 100, 50 SLIDER oSld VAR nVol MIN 0 MAX 100 OF oWnd ;
   ICONMIN "speaker.fill" ;
   ICONMAX "speaker.wave.3.fill" ;
   COLOR "Orange" ;
   STEP 5 ;
   ACTION ( oLabel:Caption := "Volumen: " + Str( oSld:Value ) )
```
