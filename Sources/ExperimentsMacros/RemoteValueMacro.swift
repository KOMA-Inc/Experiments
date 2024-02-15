import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct RemoteValueMacro {
    enum DiagnosticError: String, DiagnosticMessage {

        var severity: DiagnosticSeverity { .error }

        case incorrectType
        case unsupportedEnum

        var message: String {
            switch self {
            case .incorrectType:
                "@RemoteValue should be applied to enum"
            case .unsupportedEnum:
                "@RemoteValue needs enum that conforms to String or nothing"
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "Experiments", id: rawValue)
        }
    }
}

extension RemoteValueMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // If applied to enum

        guard let declaration = declaration.as(EnumDeclSyntax.self) else {
            // Otherwise, should NOT work
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.incorrectType)
            context.diagnose(diagnostic)
            return []
        }

        // If enum has RawValue String, should NOT do anything

        if let inheritanceClause = declaration.inheritanceClause,
           let firstType = inheritanceClause.inheritedTypes.first?.type.as(IdentifierTypeSyntax.self),
           firstType.name.text == "String" {
            return []
        }

        // If enum has no conformances, add properties

        guard declaration.inheritanceClause == nil else {
            // Else unsupported case
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.unsupportedEnum)
            context.diagnose(diagnostic)
            return []
        }

        let enabled = try EnumCaseDeclSyntax("case enabled")
        let disabled = try EnumCaseDeclSyntax("case disabled")
        let rawValue: SyntaxNodeString =
                """
                var rawValue: Int {
                    switch self {
                    case .enabled:
                        1
                    case .disabled:
                        0
                    }
                }
                """

        return [
            DeclSyntax(enabled),
            DeclSyntax(disabled),
            DeclSyntax(try VariableDeclSyntax(rawValue))
        ]
    }
}

extension RemoteValueMacro: ExtensionMacro {

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {

        // If applied to enum

        guard let declaration = declaration.as(EnumDeclSyntax.self) else {
            // Otherwise, should NOT work
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.incorrectType)
            context.diagnose(diagnostic)
            return []
        }

        // If enum has RawValue String

        if let inheritanceClause = declaration.inheritanceClause,
           let firstType = inheritanceClause.inheritedTypes.first?.type.as(IdentifierTypeSyntax.self),
           firstType.name.text == "String" {
            //  If enum has no other conformances, add StringRemoteValue extension
            guard inheritanceClause.inheritedTypes.count == 1 else {
                return []
            }
            let ext = try ExtensionDeclSyntax("extension \(type.trimmed): CaseIterable, StringRemoteValue, Equatable {}")
            return [ext]
        }

        // If enum has no conformances, add some

        guard declaration.inheritanceClause == nil else {
            // Else unsupported case
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.unsupportedEnum)
            context.diagnose(diagnostic)
            return []
        }


        let ext = try ExtensionDeclSyntax("extension \(type.trimmed): CaseIterable, BoolRemoteValue, Equatable { }")
        return [ext]
    }
}
