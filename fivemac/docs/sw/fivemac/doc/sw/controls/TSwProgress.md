# TSwProgress

El componente **TSwProgress** es el indicador visual de avance de tareas. Soporta modos determinados e indeterminados, subtítulos y personalización de color.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> PROGRESS [ <oPrg> ] ;
   [ VAR <nValue> ] ;
   [ MIN <nMin> ] ;
   [ MAX <nMax> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ PROMPT <cPrompt> ] ;
   [ SUBTITLE <cSubtitle> ] ;
   [ ICON <cIcon> ] ;
   [ COLOR <cColor> ] ;
   [ INDETERMINATE ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `nValue` | Numérico | Valor actual del progreso. |
| `nMin` | Numérico | Valor mínimo. |
| `nMax` | Numérico | Valor máximo. |
| `cPrompt` | String | Título descriptivo superior. |
| `cSubtitle` | String | Subtítulo descriptivo inferior. |
| `cIcon` | String | Icono (SF Symbol) de cabecera. |
| `cColor` | String | Color de la barra. |
| `lIndeterminate`| Lógico | Si es .T., muestra una animación de carga infinita. |
| `nStyle` | Numérico | Estilo visual (0: Bar, 1: Circular). |
| `lShowValue` | Lógico | Si es .T., muestra el porcentaje o valor numérico. |

## Ejemplo de uso

```harbour
@ 50, 50 PROGRESS oPrg VAR nValue OF oWnd ;
   PROMPT "Cargando datos..." ;
   SUBTITLE "Por favor espere" ;
   COLOR "Blue" ;
   INDETERMINATE
```
