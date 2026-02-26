import sys

def check_libs_func():
    try:
        import pandas as pd
        import openpyxl
        return f"PANDAS_OK|{pd.__version__}|OPENPYXL_OK"
    except ImportError as e:
        return f"PANDAS_ERROR|{str(e)}|PATH:{sys.path}"
    except Exception as e:
        return f"GENERAL_ERROR|{str(e)}|PATH:{sys.path}"
