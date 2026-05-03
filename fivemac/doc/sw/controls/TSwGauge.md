# TSwGauge

Indicador visual circular/linear para mostrar valores porcentuales o métricas.

## Definición

```clipper
@ nRow, nCol GAUGE [ oGauge ] ;
    [ VALUE nValue ] [ RANGE nMin, nMax ] ;
    [ OF oWnd ] ;
    [ SIZE nWidth, nHeight ] ;
    [ PROMPT cPrompt ] [ SUBTITLE cSubtitle ] ;
    [ ICON cIcon ] [ COLOR cColor ] ;
    [ STYLE nStyle ] [ UNIT cUnit ] ;
    [ DISABLED ] ;
    [ SHOWVALUE ]
```

## Propiedades

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `Value` | Numeric | Valor actual del gauge |
| `Min` | Numeric | Valor mínimo del rango |
| `Max` | Numeric | Valor máximo del rango |
| `Prompt` | Character | Etiqueta superior |
| `Subtitle` | Character | Texto inferior secundario |
| `Icon` | Character | SF Symbol icon |
| `TintColor` | Character | Color de acento (hex o `.blue`, `.red`, etc.) |
| `Style` | Numeric | `SW_GAUGE_CIRCULAR` (0), `SW_GAUGE_LINEAR` (1), `SW_GAUGE_CAPACITY` (2) |
| `UnitText` | Character | Texto de unidad (ej: `%`, `°C`, `GB`) |
| `lShowValueLabel` | Logical | Mostrar etiqueta de valor (default `.T.`) |

## Métodos

| Método | Descripción |
|--------|-------------|
| `SetValue( nVal, lSync )` | Actualiza valor. Si `lSync=.T.` espera confirmación |
| `SetStyle( nStyle )` | Cambia estilo visual dinámicamente |
| `SetEnabled( lEnabled )` | Habilita/deshabilita |
| `SetVisible( lVisible )` | Muestra/oculta |

## Estilos

- `SW_GAUGE_CIRCULAR` (0): Gauge circular compacto con valor centrado
- `SW_GAUGE_LINEAR` (1): Barra linear con valor lateral
- `SW_GAUGE_CAPACITY` (2): Gauge circular grande (escala 2x)

## Ejemplo

```clipper
DEFINE WINDOW oWnd TITLE "Gauges" SIZE 400, 200

@ 20, 40 GAUGE oGauge VALUE 75 RANGE 0, 100 ;
   PROMPT "CPU" ICON "cpu" COLOR ".blue" UNIT "%"

@ 20, 160 GAUGE oGauge2 VALUE 3.2 RANGE 0, 5 ;
   PROMPT "Temp" COLOR ".orange" UNIT "°C" STYLE SW_GAUGE_LINEAR

oGauge:Value := 90
oGauge:SetColor( ".red" )

ACTIVATE WINDOW oWnd CENTERED
```
