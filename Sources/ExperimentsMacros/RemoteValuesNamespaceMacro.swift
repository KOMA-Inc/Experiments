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
            try expansion(providingAttributesFor: member)
        } else if let member = member.as(StructDeclSyntax.self) {
            try expansion(providingAttributesFor: member)
        } else {
            []
        }
    }

    private static func expansion(providingAttributesFor member: EnumDeclSyntax) throws -> [AttributeSyntax] {
        // Get attributes names, aka existing @ annotations
        let attributeNames =  member.attributes.compactMap {
            $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text
        }

        // If there is already annotation, do nothing
        if Set(attributeNames).intersection(["StringRemoteValue", "BoolRemoteValue"]).isEmpty == false {
            return []
        }

        // Get inheritance, conformances
        let inheritedTypes = member.inheritanceClause?.inheritedTypes.compactMap {
            $0.type.as(IdentifierTypeSyntax.self)?.name.text
        } ?? []

        // If enum has rawValue String (enum Sth: String { ... }) set @StringRemoteValue, else @BoolRemoteValue
        return if inheritedTypes.contains("String") {
            ["@StringRemoteValue"]
        } else {
            ["@BoolRemoteValue"]
        }
    }

    private static func expansion(providingAttributesFor member: StructDeclSyntax) throws -> [AttributeSyntax] {
        // Get attributes names, aka existing @ annotations
        let attributeNames =  member.attributes.compactMap {
            $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text
        }

        // If there is already annotation, do nothing
        if Set(attributeNames).intersection(["BaselineStringRemoteValue", "BaselineBoolRemoteValue"]).isEmpty == false {
            return []
        }

        // If struct has enum inside it, it is probably @BaselineStringRemoteValue, otherwise - @BaselineBoolRemoteValue
        return if member.memberBlock.members.contains(where: {
            $0.decl.as(EnumDeclSyntax.self) != nil
        }) {
            ["@BaselineStringRemoteValue"]
        } else {
            ["@BaselineBoolRemoteValue"]
        }
    }
}
