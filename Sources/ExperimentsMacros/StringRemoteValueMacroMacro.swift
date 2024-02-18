import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct StringRemoteValueMacro {
    enum DiagnosticError: String, DiagnosticMessage {

        var severity: DiagnosticSeverity { .error }

        case incorrectType
        case unsupportedEnum

        var message: String {
            switch self {
            case .incorrectType:
                "@StringRemoteValue should be applied to enum"
            case .unsupportedEnum:
                "@StringRemoteValue needs enum that conforms to String"
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "Experiments", id: rawValue)
        }
    }
}

extension StringRemoteValueMacro: ExtensionMacro {

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

        guard let inheritanceClause = declaration.inheritanceClause,
              let firstType = inheritanceClause.inheritedTypes.first?.type.as(IdentifierTypeSyntax.self),
              firstType.name.text == "String" else {
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.unsupportedEnum)
            context.diagnose(diagnostic)
            return []
        }

        // Get inheritance, conformances

        let inheritedTypes = inheritanceClause.inheritedTypes.compactMap {
            $0.type.as(IdentifierTypeSyntax.self)?.name.text
        }

        let missingExtensions = Set(["CaseIterable", "StringRemoteValue", "Equatable"]).subtracting(inheritedTypes)

        if missingExtensions.isEmpty {
            return []
        } else {
            let joined = missingExtensions.sorted().joined(separator: ", ")
            let ext = try ExtensionDeclSyntax("extension \(type.trimmed): \(raw: joined) {}")
            return [ext]
        }
    }
}
