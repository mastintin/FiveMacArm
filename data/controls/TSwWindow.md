# TSwWindow

La clase **TSwWindow** es la base de toda interfaz en SW. A diferencia de las ventanas clásicas de Fivemac, las ventanas SW operan en una arquitectura de doble hilo (Hilo 0 para UI e Hilo 1 para Harbour), lo que garantiza una interfaz siempre fluida y sin bloqueos.

## Sintaxis del Comando
```harbour
DEFINE WINDOW [ <oWnd> ] ;
   TITLE <cTitle> ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ ID <cId> ] ;
   [ OF <oParent> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `cTitle` | String | El título de la ventana. |
| `cBackColor`| String | Color de fondo de la ventana. |
| `bOnInit` | Block | Acción a ejecutar cuando la ventana se ha inicializado en Swift. |
| `bOnEnd` | Block | Acción a ejecutar justo antes de cerrar la ventana. |
| `lVisible` | Lógico | Estado de visibilidad (gestionado internamente por el bucle de eventos). |

## Métodos Especiales
- **Activate( lModal )**: Muestra la ventana e inicia el bucle de eventos HSW.
- **Close() / End()**: Cierra la ventana y libera los recursos en ambos hilos.

## Ejemplo de uso

```harbour
function Main()
   local oWnd
   
   DEFINE WINDOW oWnd TITLE "Mi Primera Ventana SW" SIZE 800, 600
   
   @ 20, 20 LABEL "Hola Mundo desde La Isla" OF oWnd
   
   ACTIVATE WINDOW oWnd
return nil
```
