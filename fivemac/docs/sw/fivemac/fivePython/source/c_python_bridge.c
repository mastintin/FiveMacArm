#include <Python/Python.h>
#include <hbapi.h>
#include <hbapiitm.h>
#include <hbmacro.h>
#include <hbvmpub.h>
// --- Forward Declarations ---
PyObject *Harbour_To_PyObject(PHB_ITEM pItem);
void PyObject_To_Harbour(PyObject *pyObj, PHB_ITEM pReturn);

// --- C-API Bridge ---

// --- Callbacks ( Python -> Harbour ) ---

// Esta función C es llamada desde Python cuando hacen "fivemac.eval('...')"
static PyObject *py_hb_eval(PyObject *self, PyObject *args) {
  const char *code;

  // Extraer el string pasado desde Python
  if (!PyArg_ParseTuple(args, "s", &code)) {
    return NULL; // PyArg_ParseTuple ya setea la excepción
  }

  // Macrocompilar y ejecutar el string como código Harbour
  PHB_MACRO pMacro = hb_macroCompile(code);
  PyObject *pPyResult = Py_None;

  if (pMacro) {
    hb_macroRun(pMacro);
    pPyResult = Harbour_To_PyObject(hb_param(-1, HB_IT_ANY));
    hb_macroDelete(pMacro);
  } else {
    pPyResult = Py_None;
    Py_INCREF(Py_None);
  }

  return pPyResult;
}

// Mapeo de métodos del módulo 'fivemac'
static PyMethodDef FivemacMethods[] = {
    {"eval", py_hb_eval, METH_VARARGS,
     "Evalua una cadena de código Harbour inyectado mediante hb_macroCompile."},
    {NULL, NULL, 0, NULL} /* Sentinel */
};

// Definición del módulo
static struct PyModuleDef fivemacmodule = {
    PyModuleDef_HEAD_INIT, "fivemac", /* name of module */
    NULL,                             /* module documentation, may be NULL */
    -1, /* size of per-interpreter state of the module, or -1 if the module
           keeps state in global variables. */
    FivemacMethods};

// Función de inicialización
PyMODINIT_FUNC PyInit_fivemac(void) { return PyModule_Create(&fivemacmodule); }

// --- C-API Bridge ---

HB_FUNC(C_PY_INITIALIZE) {
  const char *path = hb_parc(1);
  if (path) {
    setenv("PYTHONHOME", path, 1);
  }
  setenv("PYTHONUTF8", "1", 1);
  setenv("PYTHONIOENCODING", "utf-8", 1);

  // Agregar nuestro módulo C empaquetado antes de inicializar la VM
  PyImport_AppendInittab("fivemac", &PyInit_fivemac);

  Py_Initialize();
}

HB_FUNC(C_PY_FINALIZE) { Py_Finalize(); }

HB_FUNC(C_PY_RUN_SCRIPT) {
  const char *code = hb_parc(1);
  PyRun_SimpleString(code);
}

// Llama a una función dentro de un módulo de python (eg. C_PY_CALL("math",
// "pow", 2, 8))
HB_FUNC(C_PY_CALL) {
  const char *cModule = hb_parc(1);
  const char *cFunc = hb_parc(2);
  int iArgsCount = hb_pcount() - 2;

  if (!cModule || !cFunc) {
    hb_ret();
    return;
  }

  // 1. Cargar el Módulo
  PyObject *pName = PyUnicode_FromString(cModule);
  PyObject *pModule = PyImport_Import(pName);
  Py_DECREF(pName);

  if (pModule != NULL) {
    // 2. Localizar la Función
    PyObject *pFunc = PyObject_GetAttrString(pModule, cFunc);

    if (pFunc && PyCallable_Check(pFunc)) {
      // 3. Empaquetar Argumentos Harbour -> Python Tuple
      PyObject *pArgs = PyTuple_New(iArgsCount);
      for (int i = 0; i < iArgsCount; ++i) {
        PHB_ITEM pItem =
            hb_param(i + 3, HB_IT_ANY); // Offset 3 (Modulo, Func, Arg1..)
        PyObject *pValue = Harbour_To_PyObject(pItem);

        if (!pValue) {
          Py_DECREF(pArgs);
          Py_DECREF(pModule);
          hb_ret();
          return;
        }
        // PyTuple_SetItem "roba" la referencia, no necesitamos hacer DECREF de
        // pValue aquí
        PyTuple_SetItem(pArgs, i, pValue);
      }

      // 4. Invocar función
      PyObject *pValue = PyObject_CallObject(pFunc, pArgs);
      Py_DECREF(pArgs);

      if (pValue != NULL) {
        // 5. Convertir retorno Python -> Harbour
        PHB_ITEM pReturn = hb_itemNew(NULL);
        PyObject_To_Harbour(pValue, pReturn);
        hb_itemReturnRelease(pReturn);
        Py_DECREF(pValue);
      } else {
        PyErr_Print();
        hb_ret();
      }
    } else {
      if (PyErr_Occurred())
        PyErr_Print();
      hb_ret();
    }
    Py_XDECREF(pFunc);
    Py_DECREF(pModule);
  } else {
    PyErr_Print();
    hb_ret();
  }
}

// --- Conversores Recursivos Bidireccionales ---

PyObject *Harbour_To_PyObject(PHB_ITEM pItem) {
  if (HB_IS_STRING(pItem)) {
    return PyUnicode_FromString(hb_itemGetC(pItem));
  } else if (HB_IS_NUMINT(pItem)) {
    return PyLong_FromLong(hb_itemGetNL(pItem));
  } else if (HB_IS_NUMERIC(pItem)) {
    return PyFloat_FromDouble(hb_itemGetND(pItem));
  } else if (HB_IS_LOGICAL(pItem)) {
    return PyBool_FromLong(hb_itemGetL(pItem) ? 1 : 0);
  } else if (HB_IS_ARRAY(pItem)) {
    HB_SIZE nCount = hb_arrayLen(pItem);
    PyObject *pList = PyList_New(nCount);
    for (HB_SIZE i = 1; i <= nCount; i++) {
      PHB_ITEM pSubItem = hb_arrayGetItemPtr(pItem, i);
      PyObject *pPySubItem = Harbour_To_PyObject(pSubItem);
      PyList_SetItem(pList, i - 1, pPySubItem); // Roba referencia
    }
    return pList;
  }
  Py_RETURN_NONE;
}

void PyObject_To_Harbour(PyObject *pyObj, PHB_ITEM pReturn) {
  if (pyObj == Py_None) {
    hb_itemClear(pReturn);
  } else if (PyBool_Check(pyObj)) {
    hb_itemPutL(pReturn, pyObj == Py_True);
  } else if (PyLong_Check(pyObj)) {
    hb_itemPutNL(pReturn, PyLong_AsLong(pyObj));
  } else if (PyFloat_Check(pyObj)) {
    hb_itemPutND(pReturn, PyFloat_AsDouble(pyObj));
  } else if (PyUnicode_Check(pyObj)) {
    const char *cStr = PyUnicode_AsUTF8(pyObj);
    hb_itemPutC(pReturn, cStr);
  } else if (PyList_Check(pyObj) || PyTuple_Check(pyObj)) {
    int isTuple = PyTuple_Check(pyObj);
    Py_ssize_t nCount = isTuple ? PyTuple_Size(pyObj) : PyList_Size(pyObj);

    hb_arrayNew(pReturn, nCount);
    for (Py_ssize_t i = 0; i < nCount; i++) {
      PyObject *pPySubObj = isTuple ? PyTuple_GetItem(pyObj, i)
                                    : PyList_GetItem(pyObj, i); // Item prestado
      PHB_ITEM pSubItem = hb_itemNew(NULL);

      PyObject_To_Harbour(pPySubObj, pSubItem);
      hb_arraySet(pReturn, i + 1, pSubItem);
      hb_itemRelease(pSubItem);
    }
  } else {
    // Fallback: tratar de pasarlo como string si no lo reconocemos
    PyObject *pStr = PyObject_Str(pyObj);
    if (pStr) {
      const char *cStr = PyUnicode_AsUTF8(pStr);
      hb_itemPutC(pReturn, cStr);
      Py_DECREF(pStr);
    } else {
      hb_itemClear(pReturn);
    }
  }
}
