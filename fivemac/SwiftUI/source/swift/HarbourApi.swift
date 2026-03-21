import Foundation
import Darwin 

// Lectura de parámetros (Getters de C)
@_silgen_name("hb_parc") func hb_parc(_ i: Int32) -> UnsafePointer<Int8>?
@_silgen_name("hb_parl") func hb_parl(_ i: Int32) -> Int32
@_silgen_name("hb_parni") func hb_parni(_ i: Int32) -> Int32
@_silgen_name("hb_parnd") func hb_parnd(_ i: Int32) -> Double

@_silgen_name("hb_parnll") func hb_parnll(_ i: Int32) -> Int64
@_silgen_name("hb_retnll") func hb_retnll(_ n: Int64)


// Devolución de valores (Setters de C para Harbour)
@_silgen_name("hb_retc") func hb_retc(_ s: UnsafePointer<Int8>?)
@_silgen_name("hb_retl") func hb_retl(_ l: Int32)
@_silgen_name("hb_retni") func hb_retni(_ i: Int32)
@_silgen_name("hb_retnd") func hb_retnd(_ d: Double)

@_silgen_name("hb_param")
func hb_param(_ iParam: Int32, _ iMask: Int32) -> UnsafeMutableRawPointer?

@_silgen_name("hb_dynsymFindName") func hb_dynsymFindName(_ name: UnsafePointer<Int8>) -> UnsafeMutableRawPointer?
@_silgen_name("hb_dynsymSymbol") func hb_dynsymSymbol(_ p: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer?
@_silgen_name("hb_vmPushSymbol") func hb_vmPushSymbol(_ s: UnsafeMutableRawPointer?)
@_silgen_name("hb_vmPushNil") func hb_vmPushNil()
@_silgen_name("hb_vmPushNLL") func hb_vmPushNLL(_ n: Int64)
@_silgen_name("hb_vmPushLogical") func hb_vmPushLogical(_ b: Int32)
@_silgen_name("hb_vmDo") func hb_vmDo(_ nArgs: Int32)
@_silgen_name("hb_vmPushNumber") func hb_vmPushNumber(_ n: Double, _ dec: Int32)
@_silgen_name("hb_vmPushDouble") func hb_vmPushDouble(_ n: Double, _ dec: Int32)
@_silgen_name("hb_vmPushString") func _hb_vmPushString(_ s: UnsafePointer<Int8>, _ len: Int)


public func hb_vmPushString(_ s: String) {
    s.withCString { cStr in
        _hb_vmPushString(cStr, s.utf8.count)
    }
}




public typealias PHB_ITEM = UnsafeMutableRawPointer
//typealias HB_SIZE = Int 
public typealias HB_SIZE = CUnsignedLong



// Funciones esenciales de la API de Harbour
@_silgen_name("hb_arrayLen") func hb_arrayLen(_ pArray: PHB_ITEM?) -> HB_SIZE

@_silgen_name("hb_arrayGetItemPtr") func hb_arrayGetItemPtr(_ pArray: PHB_ITEM?, _ index: HB_SIZE) -> PHB_ITEM?



@_silgen_name("hb_hashLen") 
func hb_hashLen(_ pHash: PHB_ITEM?) -> HB_SIZE

@_silgen_name("hb_itemType") 
func hb_itemType(_ pItem: PHB_ITEM?) -> Int32 // Los flags de tipo suelen ser Int32 (HB_IT_*)

// --- HASH KEY ---//
/*
@_silgen_name("hb_hashGetKeyPtr") 
func _hb_hashGetKeyPtr(_ pHash: PHB_ITEM?, _ nPos: HB_SIZE) -> PHB_ITEM?

public func hb_hashGetKeyPtr(_ pHash: PHB_ITEM?, _ nPos: HB_SIZE) -> PHB_ITEM? {
    return _hb_hashGetKeyPtr(pHash, nPos)
}
*/
// --- HASH VALUE ---
/*
@_silgen_name("hb_hashGetValuePtr") 
func _hb_hashGetValuePtr(_ pHash: PHB_ITEM?, _ nPos: HB_SIZE) -> PHB_ITEM?

public func hb_hashGetValuePtr(_ pHash: PHB_ITEM?, _ nPos: HB_SIZE) -> PHB_ITEM? {
    return _hb_hashGetValuePtr(pHash, nPos)
}
*/

// 1. Declaración de la función interna de Harbour (C)
@_silgen_name("hb_itemGetCPtr") 
func _hb_itemGetCPtr(_ pItem: PHB_ITEM?) -> UnsafePointer<Int8>?

// 2. Función pública de Swift que la encapsula
public func hb_itemGetCPtr(_ pItem: PHB_ITEM?) -> String? {
    // Intentamos obtener el puntero crudo de la función interna
    if let cStr = _hb_itemGetCPtr(pItem) {
        // Si existe, lo convertimos a String de Swift
        return String(validatingCString: cStr)
    }
    
    // Si el puntero era nil o la conversión falló, devolvemos nil
    return nil
}

//----------------- viene de hbapi.h ----------------------

public let HB_IT_NIL:       Int32 = 0x00000
public let HB_IT_POINTER:   Int32 = 0x00001
public let HB_IT_INTEGER:   Int32 = 0x00002
public let HB_IT_HASH:      Int32 = 0x00004
public let HB_IT_LONG:      Int32 = 0x00008
public let HB_IT_DOUBLE:    Int32 = 0x00010
public let HB_IT_DATE:      Int32 = 0x00020
public let HB_IT_TIMESTAMP: Int32 = 0x00040
public let HB_IT_LOGICAL:   Int32 = 0x00080
public let HB_IT_STRING:    Int32 = 0x00400
public let HB_IT_ARRAY:     Int32 = 0x08000  
public let HB_IT_ANY: Int32 = Int32(bitPattern: 0xFFFFFFFF)

//public let HB_IT_ANY:       Int32 = 0xFFFFFFFF    
// Máscaras combinadas útiles
//public let HB_IT_NUMERIC: Int32 = (0x00002 | 0x00008 | 0x00010)

public let HB_IT_SYMBOL:    Int32 = 0x00100
public let HB_IT_ALIAS:     Int32 = 0x00200
public let HB_IT_MEMOFLAG:  Int32 = 0x00800
public let HB_IT_MEMO:      Int32 = ( HB_IT_MEMOFLAG | HB_IT_STRING )
public let HB_IT_BLOCK:     Int32 = 0x01000
public let HB_IT_BYREF:     Int32 = 0x02000
public let HB_IT_MEMVAR:    Int32 = 0x04000
public let HB_IT_ENUM:      Int32 = 0x10000
public let HB_IT_EXTREF:    Int32 = 0x20000
public let HB_IT_DEFAULT:   Int32 = 0x40000
public let HB_IT_RECOVER:   Int32 = 0x80000
public let HB_IT_OBJECT:    Int32 = HB_IT_ARRAY

public let HB_IT_NUMINT:    Int32 = ( HB_IT_INTEGER | HB_IT_LONG )
public let HB_IT_DATETIME:  Int32 = ( HB_IT_DATE | HB_IT_TIMESTAMP )

public let HB_IT_COMPLEX:   Int32 = ( HB_IT_BLOCK | HB_IT_ARRAY | HB_IT_HASH | HB_IT_POINTER | /* HB_IT_MEMVAR | HB_IT_ENUM | HB_IT_EXTREF |*/ HB_IT_BYREF | HB_IT_STRING )
public let HB_IT_GCITEM:    Int32 = ( HB_IT_BLOCK | HB_IT_ARRAY | HB_IT_HASH | HB_IT_POINTER | HB_IT_BYREF )
public let HB_IT_EVALITEM:  Int32 = ( HB_IT_BLOCK | HB_IT_SYMBOL )
public let HB_IT_HASHKEY:   Int32 = ( HB_IT_INTEGER | HB_IT_LONG | HB_IT_DOUBLE | HB_IT_DATE | HB_IT_TIMESTAMP | HB_IT_STRING | HB_IT_POINTER )


public struct Harbour {
    public static func ret(_ value: String) {
        hb_retc((value as NSString).utf8String)
    }

    public static func ret(_ value: String?) {
        if let v = value {
            hb_retc((v as NSString).utf8String)
        } else {
             hb_retc(nil)
        }
    }
    
    // Para devolver Int64 (Punteros)
    public static func ret(_ value: Int64) {
        hb_retnll(value)
    }
    
  // Para Double (Coordenadas, Opacidad, Sliders)
    public static func ret(_ value: Double) {
        hb_retnd(value)
    }

    // Para devolver Bools
    public static func ret(_ value: Bool) {
        hb_retl(value ? 1 : 0)
    }
    
    // Para devolver Ints
    public static func ret(_ value: Int) {
        hb_retni(Int32(value))
    }

    // Caso de seguridad: Si no es nada de lo anterior, no hacemos nada
    public static func ret(_ value: Any) {
        print("Aviso: Tipo de retorno no soportado por Harbour: \(type(of: value))")
    }
}

//---------------------------------------

public struct HarbourBridgeSupport {
    // Convierte String de Swift a puntero para C
    public static func toC(_ value: String) -> UnsafePointer<Int8>? {
        return (value as NSString).utf8String
    }
    
    public static func toC(_ value: String?) -> UnsafePointer<Int8>? {
        guard let value = value else { return nil }
        return (value as NSString).utf8String
    }

    // Convierte Bool de Swift a Int32 de C
    public static func toC(_ value: Bool) -> Int32 {
        return value ? 1 : 0
    }

    // Convierte Int de Swift a Int32 de C
    public static func toC(_ value: Int) -> Int32 {
        return Int32(value)
    }
    
    // Convierte Double de Swift a Double de C
    public static func toC(_ value: Double) -> Double {
        return value
    }
}

//---------------------------------------------
public struct SwiftPickerArray {
    
    /// Convierte un puntero Int64 de Harbour directamente en un [String] nativo
    public static func from(harbourPtr: Int64) -> [String] {
        // 1. Casting de Int64 a Puntero de Memoria
        let pArray = UnsafeMutableRawPointer(bitPattern: Int(harbourPtr))
        
        // 2. Ejecutar la extracción segura
        return getSwiftArray(from: pArray)
    }

    /// Función interna que recorre la memoria de Harbour
        /// Función interna que recorre la memoria de Harbour
    /// Función interna que convierte un Array de Harbour en un Array de Strings de Swift
private static func getSwiftArray(from pArray: PHB_ITEM?) -> [String] {
    var result: [String] = []
    
    // 1. Validar que el puntero no sea nulo y que sea un tipo Array de Harbour
    guard let pArray = pArray, (hb_itemType(pArray) & HB_IT_ARRAY) != 0 else {
        return result
    }

    // 2. Obtener la longitud del array (HB_SIZE suele ser UInt)
    let nLen = Int(hb_arrayLen(pArray))
    
    if nLen > 0 {
        // 3. Recorrer el array (Recordar: Harbour usa base 1)
        for i in 1...nLen {
            // Obtenemos el puntero al ítem en la posición 'i'
            if let pItem = hb_arrayGetItemPtr(pArray, HB_SIZE(i)) {
                
                // 4. Verificamos si el ítem es una cadena (String)
                if (hb_itemType(pItem) & HB_IT_STRING) != 0 {
                    
                    // Intentamos obtener el puntero C (char *) del ítem
                    if let cStr = hb_itemGetCPtr(pItem) {
                        result.append(cStr)
                    }
                }
            }
        }
    }
    
    return result
}


}



