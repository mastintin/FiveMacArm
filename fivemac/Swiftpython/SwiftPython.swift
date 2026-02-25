import Foundation

@objc public class TSwiftPython: NSObject {
    
    @objc public static func Eval(_ code: String) {
        do {
            let sys = try Python.attemptImport("sys")
            let builtins = try Python.attemptImport("builtins")
            
            // Creamos un diccionario vacío para los globals y locals
            let globals = Python.dict()
            
            // Usamos builtins.exec aportando el entorno necesario para evitar "globals cannot be NULL"
            try builtins.exec.throwing.dynamicallyCall(withArguments: [code, globals])
            
        } catch {
            print("Error ejecutando Python: \(error)")
        }
    }
    
    @objc public static func RunScript(_ code: String) {
        // Ejecución de un bloque puro de Python usando exec
         do {
            let builtins = try Python.attemptImport("builtins")
            let dict = Python.dict()
            try builtins.exec.throwing.dynamicallyCall(withArguments: [code, dict])
        } catch {
            print("Error ejecutando script: \(error)")
        }
    }
    
    @objc public static func Evaluate(_ code: String) -> String {
        do {
            let builtins = try Python.attemptImport("builtins")
            let dict = Python.dict()
            let result = try builtins.eval.throwing.dynamicallyCall(withArguments: [code, dict])
            return String(describing: result)
        } catch {
            return "Error: \(error)"
        }
    }
}

