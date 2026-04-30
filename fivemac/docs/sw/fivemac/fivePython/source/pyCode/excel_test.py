import sys
import os

# 1. Configuración automática de rutas al cargar el módulo
base_dir = os.path.dirname(__file__)

# Buscamos 'python-stdl' en dos sitios posibles:
# 1. Al mismo nivel (como en un App Bundle en Resources/)
# 2. Un nivel arriba (como en el entorno de desarrollo samples/)
path_bundle = os.path.join(base_dir, "python-stdl")
path_dev = os.path.abspath(os.path.join(base_dir, "..", "python-stdl"))

if os.path.exists(path_bundle):
    stdl_path = path_bundle
else:
    stdl_path = path_dev

if stdl_path not in sys.path:
    sys.path.append(stdl_path)

# 2. Variable global para estado de dependencias
HAS_PANDAS = False
PANDAS_ERROR = ""

try:
    import pandas as pd
    import openpyxl
    HAS_PANDAS = True
except ImportError as e:
    PANDAS_ERROR = str(e)

def is_ready():
    """Devuelve el estado de las dependencias para que Harbour lo consulte."""
    if HAS_PANDAS:
        return f"OK: Pandas {pd.__version__} listo."
    return f"ERROR: Dependencias faltantes ({PANDAS_ERROR}). Verifique la librería python-stdl."

def create_sample_excel(filename="test.xlsx"):
    if not HAS_PANDAS:
        return is_ready()
        
    try:
        # Hoja 1: Ventas
        df1 = pd.DataFrame({
            "Producto": ["Manzanas", "Peras"],
            "Ventas": [100, 200]
        })
        # Hoja 2: Inventario (con datos desplazados)
        df2 = pd.DataFrame({
            "SKU": ["A01", "A02", "A03"],
            "Stock": [10, 20, 30]
        })
        
        with pd.ExcelWriter(filename) as writer:
            df1.to_excel(writer, sheet_name="Ventas", index=False)
            df2.to_excel(writer, sheet_name="Inventario", index=False, startrow=2, startcol=1)
            
        return "SUCCESS: Excel generado correctamente."
    except Exception as e:
        return f"ERROR_PY: {str(e)}"

def excel_range_to_pandas(range_string):
    """
    Convierte un rango de Excel (ej. 'B5:C25') a parámetros de pandas.
    Retorna (usecols, skiprows, nrows)
    """
    if not range_string or ":" not in range_string:
        return None, 0, None
        
    try:
        import re
        parts = range_string.split(":")
        start = parts[0].upper()
        end = parts[1].upper()
        
        # Extraer letras y números
        start_col = re.findall(r'[A-Z]+', start)[0]
        start_row = int(re.findall(r'\d+', start)[0])
        end_col = re.findall(r'[A-Z]+', end)[0]
        end_row = int(re.findall(r'\d+', end)[0])
        
        usecols = f"{start_col}:{end_col}"
        
        # skiprows: si ponemos B5, pandas salta 4 líneas y la 5 es CABECERA.
        # Si el usuario quiere datos DESDE la 5 incluyendo la 5 como datos, 
        # hay que tener cuidado. Normalmente en Excel, la primera fila del rango es la cabecera.
        skiprows = start_row - 1 
        
        # nrows: si es B5:C11 -> 11 - 5 = 6. 
        # Pero pandas lee la primera como cabecera, así que lee 7 totales para devolver 6 de datos.
        # Vamos a ajustar para que el número de filas de DATOS sea exacto.
        nrows = end_row - start_row 
        
        return usecols, skiprows, nrows
    except:
        return None, 0, None

def read_excel_adv(filename, sheet="Sheet1", range_str=None):
    if not HAS_PANDAS:
        return f'{{ "error": "{is_ready()}" }}'
        
    try:
        if not os.path.exists(filename):
            return f'{{ "error": "Archivo {filename} no encontrado" }}'

        usecols, skiprows, nrows = excel_range_to_pandas(range_str)
        print(f"DEBUG_PY: Leyendo {filename} [Hoja: {sheet}, Rango: {range_str}] -> usecols={usecols}, skiprows={skiprows}, nrows={nrows}")
        
        df = pd.read_excel(filename, sheet_name=sheet, usecols=usecols, skiprows=skiprows, nrows=nrows)
        print(f"DEBUG_PY: Filas leídas: {len(df)}")
        # force_ascii=False para que caracteres como 'ñ' no se escapen como \u00f1
        return df.to_json(orient="records", force_ascii=False)
    except Exception as e:
        # Usamos repr() para evitar errores de codificación al convertir la excepción a string
        err_msg = repr(e)
        print(f"DEBUG_PY: ERROR: {err_msg}")
        import json
        return json.dumps({"error": err_msg})
