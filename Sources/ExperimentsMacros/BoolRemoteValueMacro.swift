import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct BoolRemoteValueMacro {
    enum DiagnosticError: String, DiagnosticMessage {

        var severity: DiagnosticSeverity {
            switch self {
            case .doubleDefault:
                    .warning
            default:
                    .error
            }
        }

        case incorrectType
        case unsupportedEnum
        case doubleDefault

        var message: String {
            switch self {
            case .incorrectType:
                "@BoolRemoteValue should be applied to enum"
            case .unsupportedEnum:
                "@BoolRemoteValue can't have String rawValue"
            case .doubleDefault:
                "enabledByDefault parameter is ignored as `default` property is already declared"
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "Experiments", id: rawValue)
        }
    }
}

extension BoolRemoteValueMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // Check that applied to enum

        guard let declaration = declaration.as(EnumDeclSyntax.self) else {
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.incorrectType)
            context.diagnose(diagnostic)
            return []
        }

        // Check that enum doesn't have String rawValue

        if let inheritanceClause = declaration.inheritanceClause,
           let firstType = inheritanceClause.inheritedTypes.first?.type.as(IdentifierTypeSyntax.self),
           firstType.name.text == "String" {
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.unsupportedEnum)
            context.diagnose(diagnostic)
            return []
        }

        let enabled = try EnumCaseDeclSyntax("case enabled")
        let disabled = try EnumCaseDeclSyntax("case disabled")
        let initializer = try InitializerDeclSyntax("init(booleanLiteral value: Bool)") {
            "self = value ? .enabled : .disabled"
        }
        let rawValue: SyntaxNodeString =
                """
                var rawValue: Bool {
                    switch self {
                    case .enabled:
                        true
                    case .disabled:
                        false
                    }
                }
                """

        return [
            DeclSyntax(enabled),
            DeclSyntax(disabled),
            DeclSyntax(initializer),
            DeclSyntax(try VariableDeclSyntax(rawValue))
        ]
    }
}

extension BoolRemoteValueMacro: ExtensionMacro {

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {

        // Check that applied to enum

        guard let declaration = declaration.as(EnumDeclSyntax.self) else {
            // Otherwise, should NOT work
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.incorrectType)
            context.diagnose(diagnostic)
            return []
        }

        // Check that enum doesn't have String rawValue

        if let inheritanceClause = declaration.inheritanceClause,
           let firstType = inheritanceClause.inheritedTypes.first?.type.as(IdentifierTypeSyntax.self),
           firstType.name.text == "String" {
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.unsupportedEnum)
            context.diagnose(diagnostic)
            return []
        }

        // Get inheritance, conformances
        let inheritedTypes = declaration.inheritanceClause?.inheritedTypes.compactMap {
            $0.type.as(IdentifierTypeSyntax.self)?.name.text
        } ?? []

        let missingExtensions = Set(["CaseIterable", "BoolRemoteValue"]).subtracting(inheritedTypes)

        let member: MemberBlockItemListSyntax? = try defaultDeclaration(
            of: node,
            providingMembersOf: declaration,
            in: context
        ).flatMap { defaultDeclaration in
            let defaultCase = defaultDeclaration ? ".enabled" : ".disabled"

            return try MemberBlockItemListSyntax {
                 try VariableDeclSyntax("static let `default`: Self = \(raw: defaultCase)")
            }
        }

        switch (missingExtensions.isEmpty, member) {
        case (true, nil):
            return []
        case (true, let .some(member)):
            let ext = try ExtensionDeclSyntax("extension \(type.trimmed)") {
                    member
                }
            return [ext]
        case (false, nil):
            let joined = missingExtensions.sorted().joined(separator: ", ")
            let ext = try ExtensionDeclSyntax("extension \(type.trimmed): \(raw: joined) {}")
            return [ext]
        case (false, let .some(member)):
            let joined = missingExtensions.sorted().joined(separator: ", ")
            let ext = try ExtensionDeclSyntax("extension \(type.trimmed): \(raw: joined)") {
                member
            }
            return [ext]
        }
    }

    private static func defaultDeclaration(
        of node: AttributeSyntax,
        providingMembersOf declaration: EnumDeclSyntax,
        in context: some MacroExpansionContext
    ) -> Bool? {
        
        let variables = declaration.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let bindings = variables.flatMap { $0.bindings }.compactMap { $0.as(PatternBindingSyntax.self) }
        let hasDefault = bindings.contains { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "`default`" }
        
        let isEnabledByDefault: Bool? = if case let .argumentList(arguments) = node.arguments,
            let expression = arguments.first?.expression.as(BooleanLiteralExprSyntax.self) {
                expression.literal.text == "true" ? true : false
            } else {
                nil
            }
        
        switch (isEnabledByDefault, hasDefault) {
        case (.some, true):
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.doubleDefault)
            context.diagnose(diagnostic)
            return nil
        case (let .some(enabled), false):
            return enabled
        case (nil, true):
            return nil
        case (nil, false):
            return false
        }
    }
}
