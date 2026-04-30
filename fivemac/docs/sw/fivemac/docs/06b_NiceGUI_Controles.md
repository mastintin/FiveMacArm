# NiceGUI: Controles

FiveMac proporciona un puente excepcionalmente productivo hacia el framework web moderno NiceGUI (basado en Python/Vue/Quasar). Todos los controles se definen mediante comandos de preprocesado que abstraen la complejidad web, permitiendo a los desarrolladores de Harbour construir interfaces responsivas como si fueran aplicaciones de escritorio clásicas.

## Filosofía: El Modelo DOM Orientado a Objetos
A diferencia del diseño por coordenadas absolutas clásico, NiceGUI en FiveMac usa un enfoque de diseño fluido basado en contenedores DOM (Páginas, Tarjetas, Stacks). Cada elemento se instancia usando la cláusula `OF <oParent>` para incrustarlo dentro del flujo de la interfaz.

---

## Estructura Principal

### NICE PAGE
El contenedor raíz absoluto de cualquier vista web NiceGUI lanzada desde FiveMac.
```harbour
DEFINE NICE PAGE <oPage> [ OF <oWndContainer> ]
ACTIVATE NICE PAGE <oPage>
```

### Contenedores de Layout y Zonas
NiceGUI soporta estructuras web ricas mediante directivas de bloque (abiertas con `DEFINE` y cerradas con `END`):
- **Cabeceras y Pies**: `DEFINE NICE HEADER` / `DEFINE NICE FOOTER`.
- **Menú Lateral (Drawer)**: Permite crear paneles laterales colapsables.
  ```harbour
  DEFINE NICE DRAWER oSide CLASS "bg-slate-100" OF oPage
      NICE DRAWER ITEM PROMPT "Inicio" ICON "dashboard" OF oSide
      NICE DRAWER ITEM PROMPT "Configuración" ICON "settings" OF oSide
  END NICE DRAWER
  
  // Tip: Puedes conmutar el drawer desde un botón con JS:
  NICE BUTTON PROMPT "" ICON "menu" JS "toggleDrawer()" OF oHeader
  ```
- **Pilas Fluids (Stacks)**: `DEFINE NICE HSTACK` (Horizontal) y `DEFINE NICE VSTACK` (Vertical). Controlan la alienación y espacios con cláusulas como `GAP`, `ALIGN`, `JUSTIFY`.
- **Tarjetas Avanzadas (Cards)**: Contenedores versátiles con sombras y bordes personalizables.
  ```harbour
  // Tarjeta con borde lateral grueso (estilo KPI)
  DEFINE NICE CARD oCard RADIUS 16 BORDER COLOR "#3b82f6" BORDER WIDTH 6 SIDE "left" OF oParent
  ```

---

## Controles de Datos e Interacción

### Botones y Textos
- **Botón**: `NICE BUTTON <oBtn> PROMPT "Guardar" ACTION {|| MsgInfo("Ok") } OF oCard`
- **Etiquetas**: `NICE SAY <oSay> PROMPT "Texto" CLASS "text-h6" OF oCard`
- **Campos de Entrada**: `NICE GET <oGet> PROMPT "Nombre:" VALUE cVar OF oCard`

*Nota: La potente cláusula `CLASS` permite aplicar directamente clases CSS utilitarias de Quasar framework (ej. `text-bold bg-primary text-white`).*

---

## Wizards y Selectores de Rango

### NICE STEPPER (Wizards)
Permite crear interfaces por pasos o flujos de trabajo (Wizards).
```harbour
DEFINE NICE STEPPER oStepper VALUE 1 OF oPage
    DEFINE NICE STEP STEP 1 TITLE "Datos Generales" ICON "person"
        NICE SAY PROMPT "Introduce tus datos" OF oStepper
    END NICE STEP
    
    DEFINE NICE STEP STEP 2 TITLE "Confirmación" ICON "check"
        NICE SAY PROMPT "¿Estás seguro?" OF oStepper
    END NICE STEP
END NICE STEPPER

// Navegación programática:
NICE STEPPER oStepper NEXT
NICE STEPPER oStepper PREVIOUS
```

### NICE SLIDER
Selector de rango numérico deslizable con previsualización de valor.
```harbour
NICE SLIDER oSlider VALUE 50 MIN 0 MAX 100 STEP 5 OF oPage
```

### Iconos e indicadores visuales
- **Iconos**: `NICE ICON NAME "person" SIZE "sm" COLOR "primary" OF oParent` (Soporta todos los iconos de Material Design).
- **Progreso (Linear)**: Útil para mostrar estados de carga o porcentajes de objetivos.
  ```harbour
  NICE PROGRESS VALUE 0.27 COLOR "indigo" OF oParent
  ```

👉 **[Ver ejemplo visual de estos controles (Stepper, Slider y Progress)](img/cap4.png)**

> [!TIP]
> Puedes ver los códigos de estos controles en funcionamiento real en los ejemplos:
> - [TestControls.prg](file:///Users/manuel/Fivemac/fivemac/NiceGui/samples/TestControls.prg) (Controles individuales).
> - [TestJubila.prg](file:///Users/manuel/Fivemac/fivemac/NiceGui/samples/TestJubila.prg) (Dashboard complejo con Drawer y Cards).

---

## Visualización de Datos Avanzada

### NICE TABLE
Renderiza un componente web Quasar Data Table interactivo.
```harbour
DEFINE NICE TABLE oTbl TITLE "Usuarios" OF oPage
    NICE ADD COL TO oTbl NAME "id" LABEL "ID" FIELD "id" WIDTH "50px"
    NICE ADD COL TO oTbl NAME "name" LABEL "Nombre" FIELD "nombre" EDITABLE
END NICE TABLE

// Para inyectar arrays multidimensionales o hash maps de Harbour directamente en la web:
NICE SET DATA OF oTbl TO aRegistros
```

### NICE CHART
Gráficas modernas incrustadas, ideales para paneles de administración (Dashboards), soportando ECharts de fondo.
```harbour
DEFINE NICE CHART oChart WIDTH 600 HEIGHT 400 OF oCard
    NICE CHART oChart SET TITLE "Ventas Mensuales"
    NICE CHART oChart SET XAXIS DATA {"Ene", "Feb", "Mar"}
    NICE CHART oChart ADD SERIES DATA {120, 200, 150} TYPE "bar"
END NICE CHART
```

### NICE GRID
Este componente implementa un sistema de rejilla fluido de Quasar. A diferencia de los Stacks (VStack/HStack), el Grid permite organizar elementos en columnas fijas (COLS) que se adaptan al ancho disponible.
```harbour
DEFINE NICE GRID oGrid COLS 2 CLASS "w-full gap-4" OF oParent
    NICE SAY PROMPT "Celda 1" OF oGrid
    NICE SAY PROMPT "Celda 2" OF oGrid
END NICE GRID
```

*(Nota: Adicionalmente existen comandos para diálogos web interactivos (`DEFINE NICE DIALOG`), controles de pasos o Wizards (`DEFINE NICE STEPPER`), y más).*
