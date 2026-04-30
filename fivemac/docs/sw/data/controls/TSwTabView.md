# TSwTabView

El componente **TSwTabView** permite organizar la interfaz en pestañas nativas, facilitando la navegación entre diferentes secciones de la aplicación.

## Sintaxis del Comando
```harbour
@ <nRow>, <nCol> TABVIEW [ <oTabs> ] ;
   [ OF <oParent> ] ;
   [ SIZE <nWidth>, <nHeight> ] ;
   [ STYLE <nStyle> ]
```

## Propiedades (DATA / ACCESS / ASSIGN)

| Propiedad | Tipo | Descripción |
| :--- | :--- | :--- |
| `nStyle` | Numérico | Estilo visual de las pestañas (0: Default, 1: PageStyle). |

## Métodos Especiales
- **SetSelection( cId )**: Cambia programáticamente la pestaña activa al ID del componente hijo indicado.

## Comportamiento
Al igual que los Stacks, el **TabView** actúa como un contenedor. Cada control directo que se añada al TabView se convertirá automáticamente en una pestaña individual. Se recomienda usar Stacks (`VStack`) como hijos directos para organizar el contenido de cada pestaña.

## Ejemplo de uso

```harbour
@ 20, 20 TABVIEW oTabs OF oWnd SIZE 400, 300
   
   @ 0, 0 VSTACK oTab1 OF oTabs ;
      PROMPT "General" ICON "gear"
      @ 0, 0 LABEL "Configuración General" OF oTab1
      
   @ 0, 0 VSTACK oTab2 OF oTabs ;
      PROMPT "Usuarios" ICON "person.2"
      @ 0, 0 LABEL "Gestión de Usuarios" OF oTab2
      
ACTIVATE TABVIEW oTabs
```
