import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct HarbourBridgeMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard let function = declaration.as(FunctionDeclSyntax.self) else { return [] }
        
        let funcName = function.name.text
        let cName = funcName.hasPrefix("swift_") ? funcName : "SW_\(funcName.uppercased())"
        
        let parameters = function.signature.parameterClause.parameters
        let returnType = function.signature.returnClause?.type.description.trimmingCharacters(in: .whitespaces) ?? "Void"
        let isVoid = returnType == "Void"

        var bridgeParamsList: [String] = []
        var conversionLines: [String] = []
        var callArgsList: [String] = []
        
        for (index, param) in parameters.enumerated() {
            let pName = "p\(index)"
            let targetName = param.firstName.text
            let typeName = param.type.description.trimmingCharacters(in: .whitespaces)
            
            // 1. MAPEADO DE PARÁMETROS (C -> Swift)
            switch typeName {
            case let t where t.contains("String"):
                bridgeParamsList.append("\(pName): UnsafePointer<Int8>?")
                let isOptional = t.contains("?")
                conversionLines.append("let s\(index) = \(pName) != nil ? String(cString: \(pName)!) : \(isOptional ? "nil" : "\"\"")")
            case "Bool":
                bridgeParamsList.append("\(pName): Int32")
                conversionLines.append("let s\(index) = \(pName) != 0")
            case "Int":
                bridgeParamsList.append("\(pName): Int32")
                conversionLines.append("let s\(index) = Int(\(pName))")
            case "Double":
                bridgeParamsList.append("\(pName): Double")
                conversionLines.append("let s\(index) = \(pName)")
            default:
                bridgeParamsList.append("\(pName): UnsafeRawPointer?")
                conversionLines.append("let s\(index) = \(pName)!") // Fallback
            }
            
            callArgsList.append("\(targetName): s\(index)")
        }
        
        let bridgeParams = bridgeParamsList.joined(separator: ", ")
        let bridgeBody = conversionLines.joined(separator: "\n    ")
        let callArgs = callArgsList.joined(separator: ", ")
        
        // --- Lógica de RETORNO para HarbourBridge ---
        var bridgeReturn = ""
        var executionBlock = ""

        if isVoid {
            executionBlock = """
                DispatchQueue.main.async {
                    \(funcName)(\(callArgs))
                }
            """
        } else {
            // Detectamos el tipo de retorno para la firma del @_cdecl
            switch returnType {
            case let t where t.contains("String"):
                bridgeReturn = " -> UnsafePointer<Int8>?"
            case "Bool", "Int":
                bridgeReturn = " -> Int32"
            case "Double":
                bridgeReturn = " -> Double"
            case "Int64":
                bridgeReturn = " -> Int64"
            default:
                bridgeReturn = ""
            }
            // La macro ahora solo escribe una línea de puente
            executionBlock = "return HarbourBridgeSupport.toC(\(funcName)(\(callArgs)))"
        }

        let bridgeCode: DeclSyntax = """
        @_cdecl("\(raw: cName)")
        public func _bridge_\(raw: funcName)(\(raw: bridgeParams))\(raw: bridgeReturn) {
            \(raw: bridgeBody)
            \(raw: executionBlock)
        }
        """        
        return [DeclSyntax(bridgeCode)]
    }
}

public struct HarbourDirectMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard let function = declaration.as(FunctionDeclSyntax.self) else { return [] }
        
        let funcName = function.name.text
       // let cName = funcName.hasPrefix("swift_") ? funcName : "HB_FUN_SD_\(funcName.uppercased())"
        let cName = "HB_FUN_SD_\(funcName.uppercased())"
      
         let bridgeName = "_bridge_\(funcName)"
        
         let returnType = function.signature.returnClause?.type.description.trimmingCharacters(in: .whitespaces) ?? "Void"
        let isVoid = returnType == "Void"
        
        let parameters = function.signature.parameterClause.parameters
        var extractionLines: [String] = []
        var callArgsList: [String] = []
        
        for (index, param) in parameters.enumerated() {
            let hbIndex = index + 1
            let targetName = param.firstName.text
            let typeName = param.type.description.trimmingCharacters(in: .whitespaces)
            
            switch typeName {
            case "String":
                extractionLines.append("let arg\(index) = hb_parc(\(hbIndex)).map { String(cString: $0) } ?? \"\"")
            case "Bool":
                extractionLines.append("let arg\(index) = hb_parl(\(hbIndex)) != 0")
            case "Int":
                extractionLines.append("let arg\(index) = Int(hb_parni(\(hbIndex)))")
            case "Int64":
            // Para punteros, hWnd y HB_LONGLONG (64 bits)
                extractionLines.append("let arg\(index) = hb_parnll(\(hbIndex))")
            case "Double":
                extractionLines.append("let arg\(index) = hb_parnd(\(hbIndex))")
            default:
                extractionLines.append("let arg\(index) = \"\"")
            }
            callArgsList.append("\(targetName): arg\(index)")
        }
        
        let extractionBody = extractionLines.joined(separator: "\n    ")
        let callArgs = callArgsList.joined(separator: ", ")

        // --- LÓGICA DE RETORNO INTELIGENTE ---

     // Sustituye tu switch de retornos por esta lógica limpia:
        let finalBody: String
        if isVoid {
            finalBody = """
                DispatchQueue.main.async {
                \(funcName)(\(callArgs))
                }
            """
        } else {
            // La macro ya no "escribe" lógica compleja, solo llama a tu soporte
            finalBody = "Harbour.ret(\(funcName)(\(callArgs)))"
        }

       let bridgeCode: DeclSyntax = """
        @_cdecl("\(raw: cName)")
        public func \(raw: bridgeName)(_ p: UnsafeMutableRawPointer?) {
            \(raw: extractionBody)
            \(raw: finalBody)
        }
        """     
        return [DeclSyntax(bridgeCode)]
    }
}


@main
struct HarbourMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        HarbourBridgeMacro.self ,
        HarbourDirectMacro.self  // Registramos la nueva macro aquí
    ]
}


