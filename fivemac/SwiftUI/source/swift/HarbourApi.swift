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

@_silgen_name("hb_pcount")
func hb_pcount() -> Int32

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


@_silgen_name("hb_itemNew") func hb_itemNew(_ pItem: PHB_ITEM?) -> PHB_ITEM?
@_silgen_name("hb_itemRelease") func hb_itemRelease(_ pItem: PHB_ITEM?) -> Void
@_silgen_name("hb_itemReturn") func hb_itemReturn(_ pItem: PHB_ITEM?) -> Void
@_silgen_name("hb_jsonDecode") func hb_jsonDecode(_ szJSON: UnsafePointer<Int8>?, _ pItem: PHB_ITEM?) -> Void

@_silgen_name("hb_itemType") func hb_itemType(_ pItem: PHB_ITEM?) -> Int32 // Los flags de tipo suelen ser Int32 (HB_IT_*)
@_silgen_name("hb_arrayLen") func hb_arrayLen(_ pArray: PHB_ITEM?) -> HB_SIZE
@_silgen_name("hb_arrayGetItemPtr") func hb_arrayGetItemPtr(_ pArray: PHB_ITEM?, _ index: HB_SIZE) -> PHB_ITEM?

@_silgen_name("hb_itemGetCPtr") 
private func _hb_itemGetCPtr(_ pItem: PHB_ITEM?) -> UnsafePointer<Int8>?

public func hb_itemGetCPtr(_ pItem: PHB_ITEM?) -> String? {
    // Intentamos obtener el puntero crudo
    guard let cStr = _hb_itemGetCPtr(pItem) else {
        return nil
    }
    
    // 'validatingCString' es la opción más segura en Swift 6.3
    // porque devuelve nil si la cadena de C tiene basura (caracteres inválidos)
    return String(validatingUTF8: cStr) 
}


@_silgen_name("hb_hashLen") 
func hb_hashLen(_ pHash: PHB_ITEM?) -> HB_SIZE


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


//----------------------------------------------------------------------------//


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


//----------------------------------------------------------------------------//
// Extructura harbour de retorno de valores


public struct Harbour {
      public static func ret(_ value: String) {
        value.withCString { ptr in
            hb_retc(ptr)
        }
    }

    public static func ret(_ value: String?) {
        if let v = value {
            v.withCString { ptr in
                hb_retc(ptr)
            }
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

    public static func ret(_ value: Any) {
        // 1. Si es un tipo básico, usamos los métodos que ya tienes
        if let s = value as? String { self.ret(s); return }
        if let i = value as? Int { self.ret(i); return }
        if let b = value as? Bool { self.ret(b); return }
        if let d = value as? Double { self.ret(d); return }

        // 2. Si es un objeto complejo (Diccionario o Array), lo enviamos como HASH/ARRAY
        if JSONSerialization.isValidJSONObject(value) {
            do {
                let data = try JSONSerialization.data(withJSONObject: value, options: [])
                if let jsonString = String(data: data, encoding: .utf8) {
                    
                    // Creamos el ítem de Harbour que recibirá el objeto
                    let pItem = hb_itemNew(nil)
                    
                    // Usamos hb_jsonDecode para que Harbour cree el Hash/Array interno
                    jsonString.withCString { ptr in
                        hb_jsonDecode(ptr, pItem)
                    }
                    
                    // Devolvemos el objeto a la VM de Harbour
                    hb_itemReturn(pItem)
                    
                    // ¡Importante! Liberamos nuestra referencia local
                    hb_itemRelease(pItem)
                    return
                }
            } catch {
                print("Error serializando JSON para Harbour: \(error)")
            }
        }

        // 3. Si llega aquí, es que no sabemos qué es
        print("Aviso: Tipo de retorno no soportado por Harbour: \(type(of: value))")
        hb_retc(nil) 
    }

    /*
    // Caso de seguridad: Si no es nada de lo anterior, no hacemos nada
    public static func ret(_ value: Any) {
        print("Aviso: Tipo de retorno no soportado por Harbour: \(type(of: value))")
    }
    */
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

// --- 1. DECLARACIONES DE BAJO NIVEL (Puente con Harbour) ---
// Usamos Int32 para HB_SIZE por estabilidad en 64 bits como hablamos

// 1. Declaraciones usando tu PHB_ITEM (que es UnsafeMutableRawPointer)

@_silgen_name("hb_itemType") 
private func _hb_itemType(_ pItem: PHB_ITEM?) -> Int32

@_silgen_name("hb_arrayGetItemPtr") 
private func _hb_arrayGetItemPtr(_ pArray: PHB_ITEM?, _ nPos: HB_SIZE) -> PHB_ITEM?

@_silgen_name("hb_arrayLen") 
private func _hb_arrayLen(_ pArray: PHB_ITEM?) -> UInt32


// --- 2. ESTRUCTURA DE EXTRACCIÓN ---

public struct HarbourArray {
    
    /// Recorre el array de Harbour y extrae solo los elementos que son String
    public static func getSwiftArray(from pArray: PHB_ITEM?) -> [String] {
        guard let pArray = pArray else { return [] }
        
        let type = _hb_itemType(pArray)
        guard (type & HB_IT_ARRAY) != 0 else { return [] }

        let nLen = _hb_arrayLen(pArray)
        if nLen == 0 { return [] }

        return (1...Int(nLen)).compactMap { i in
            guard let pItem = _hb_arrayGetItemPtr(pArray, HB_SIZE(i)) else { return nil }
            
            let itemType = _hb_itemType(pItem)
            guard (itemType & HB_IT_STRING) != 0 else { return nil }
            
            guard let cStr = _hb_itemGetCPtr(pItem) else { return nil }
            return String(validatingUTF8: cStr)
        }
    }
}
