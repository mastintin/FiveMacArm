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

        var bridgeParamsList: [String] = []
        var conversionLines: [String] = []
        var callArgsList: [String] = []
        
        for (index, param) in parameters.enumerated() {
            let pName = "p\(index)"
            bridgeParamsList.append("\(pName): UnsafePointer<Int8>?")
            
            let targetName = param.firstName.text
            let isOptionalParam = param.type.description.contains("?")
            
            if isOptionalParam {
                conversionLines.append("let s\(index) = \(pName) != nil ? String(cString: \(pName)!) : nil")
            } else {
                conversionLines.append("let s\(index) = \(pName) != nil ? String(cString: \(pName)!) : \"\"")
            }
            
            callArgsList.append("\(targetName): s\(index)")
        }
        
        let bridgeParams = bridgeParamsList.joined(separator: ", ")
        let bridgeBody = conversionLines.joined(separator: "\n    ")
        let callArgs = callArgsList.joined(separator: ", ")
        
        let isStringReturn = returnType.contains("String")
        let isOptionalReturn = returnType.contains("?")
        
        let bridgeReturn = isStringReturn ? " -> UnsafePointer<Int8>?" : ""
        let callPrefix = isStringReturn ? "let result = " : ""
        
        var returnStmt = ""
        if isStringReturn {
            if isOptionalReturn {
                returnStmt = "return (result != nil ? (result! as NSString).utf8String : nil)"
            } else {
                returnStmt = "return (result as NSString).utf8String"
            }
        }

        let bridgeCode: DeclSyntax = """
        @_cdecl("\(raw: cName)")
        public func _bridge_\(raw: funcName)(\(raw: bridgeParams))\(raw: bridgeReturn) {
            \(raw: bridgeBody)
            \(raw: callPrefix)\(raw: funcName)(\(raw: callArgs))
            \(raw: returnStmt)
        }
        """
        
        return [DeclSyntax(bridgeCode)]
    }
}

@main
struct HarbourMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        HarbourBridgeMacro.self
    ]
}
