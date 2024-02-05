import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct RemoteValuesNamespaceMacro {

}

extension RemoteValuesNamespaceMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        if let member = member.as(EnumDeclSyntax.self) {
            if member.attributes.contains(where: {
                $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "RemoteValue"
            }) {
                []
            } else {
                ["@RemoteValue"]
            }
        } else if let member = member.as(StructDeclSyntax.self) {
            if member.attributes.contains(where: {
                $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "BaselineRemoteValue"
            }) {
                []
            } else {
                ["@BaselineRemoteValue"]
            }
        } else {
            []
        }
    }
}
