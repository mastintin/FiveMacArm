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
- **Menú Lateral**: `DEFINE NICE DRAWER` y sus elementos hijos (`NICE DRAWER ITEM`).
- **Pilas Fluids (Stacks)**: `DEFINE NICE HSTACK` (Horizontal) y `DEFINE NICE VSTACK` (Vertical). Controlan la alienación y espacios con cláusulas como `GAP`, `ALIGN`, `JUSTIFY`.
- **Tarjetas (Cards)**: Contenedores con sombra y bordes redondeados.
  ```harbour
  DEFINE NICE CARD oCard RADIUS 8 BORDER WIDTH 1 OF oPage
  ... // Elementos de la tarjeta
  END NICE CARD
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

👉 **[Ver ejemplo visual de estos controles (Stepper & Slider)](img/cap4.png)**

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

*(Nota: Adicionalmente existen comandos para diálogos web interactivos (`DEFINE NICE DIALOG`), controles de pasos o Wizards (`DEFINE NICE STEPPER`), rejillas CSS fluidas (`DEFINE NICE GRID`) y más).*
