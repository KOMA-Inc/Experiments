import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct BaselineBoolRemoteValueMacro {
    enum DiagnosticError: String, DiagnosticMessage {

        var severity: DiagnosticSeverity { .error }

        case incorrectType
        case variantEnum

        var message: String {
            switch self {
            case .incorrectType:
                "@BaselineBoolRemoteValue should be applied to struct"
            case .variantEnum:
                "@BaselineBoolRemoteValue should be applied to empty struct"
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "Experiments", id: rawValue)
        }
    }
}

// MARK: - MemberMacro

extension BaselineBoolRemoteValueMacro: MemberMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // If applied to struct, should add properties and initializer

        guard declaration.as(StructDeclSyntax.self) != nil else {
            // Otherwise, should NOT work
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.incorrectType)
            context.diagnose(diagnostic)
            return []
        }

        // Should NOT contain Variant enum

        let members = declaration.memberBlock.members
        guard (members.first(where: { $0.decl.as(EnumDeclSyntax.self) != nil })?.decl.as(EnumDeclSyntax.self)) == nil else {
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.variantEnum)
            context.diagnose(diagnostic)
            return []
        }

        return try expansionForBaselineStringRemoteValue()
    }

    private static func expansionForBaselineStringRemoteValue() throws -> [DeclSyntax] {
        let baseline = try VariableDeclSyntax("let baseline: Bool")
        let variant = try VariableDeclSyntax("let isEnabled: Bool")
        let optionalInitializer = try InitializerDeclSyntax("init?(name: String)") {
            try VariableDeclSyntax(#"let baseline = name.hasSuffix("_baseline")"#)
            try VariableDeclSyntax(#"let name = baseline ? String(name.dropLast("_baseline".count)) : name"#)
            """
            let isEnabled: Bool? = if name == "true" {
                true
            } else if name == "false" {
                false
            } else {
                nil
            }
            """
            """
            guard let isEnabled else { return nil }
            """
            CodeBlockItemSyntax(stringLiteral: "self.baseline = baseline")
            CodeBlockItemSyntax(stringLiteral: "self.isEnabled = isEnabled")
        }

        let initializer = try InitializerDeclSyntax("init(baseline: Bool, isEnabled: Bool)") {
            CodeBlockItemSyntax(stringLiteral: "self.baseline = baseline")
            CodeBlockItemSyntax(stringLiteral: "self.isEnabled = isEnabled")
        }

        return [
            DeclSyntax(baseline),
            DeclSyntax(variant),
            DeclSyntax(optionalInitializer),
            DeclSyntax(initializer)
        ]
    }
}

// MARK: - ExtensionMacro

extension BaselineBoolRemoteValueMacro: ExtensionMacro {

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {

        // If applied to struct, should add extensions and computed properties

        guard let declaration = declaration.as(StructDeclSyntax.self) else {
            // Otherwise, should NOT work
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.incorrectType)
            context.diagnose(diagnostic)
            return []
        }

        // Should NOT contain Variant enum

        let members = declaration.memberBlock.members
        guard (members.first(where: { $0.decl.as(EnumDeclSyntax.self) != nil })?.decl.as(EnumDeclSyntax.self)) == nil else {
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.variantEnum)
            context.diagnose(diagnostic)
            return []
        }

        let defaultDeclaration = defaultDeclaration(of: node, providingMembersOf: declaration, in: context)
        let isEnabledByDefault = defaultDeclaration ? "true" : "false"

        let ext = try ExtensionDeclSyntax("extension \(type.trimmed): CaseIterable, StringRemoteValue, BaselineStringRemoteValue") {
            """
            static var allCases: [\(type.trimmed)] {
                [
                    \(type.trimmed)(baseline: true, isEnabled: false),
                    \(type.trimmed)(baseline: false, isEnabled: false),
                    \(type.trimmed)(baseline: true, isEnabled: true),
                    \(type.trimmed)(baseline: false, isEnabled: true),
                ]
            }

            var name: String {
                let status = isEnabled ? "Enabled" : "Disabled"
                return baseline ? status + "_baseline" : status
            }

            static var `default`: Self {
                \(type.trimmed)(baseline: true, isEnabled: \(raw: isEnabledByDefault))
            }
            """
        }

        return [ext]
    }

    private static func defaultDeclaration(
        of node: AttributeSyntax,
        providingMembersOf declaration: StructDeclSyntax,
        in context: some MacroExpansionContext
    ) -> Bool {

        let isEnabledByDefault: Bool? = if case let .argumentList(arguments) = node.arguments,
            let expression = arguments.first?.expression.as(BooleanLiteralExprSyntax.self) {
                expression.literal.text == "true" ? true : false
            } else {
                nil
            }

        return isEnabledByDefault ?? false

    }
}
