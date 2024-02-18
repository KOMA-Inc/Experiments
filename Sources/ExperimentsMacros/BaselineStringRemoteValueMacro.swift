import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct BaselineStringRemoteValueMacro {
    enum DiagnosticError: String, DiagnosticMessage {

        var severity: DiagnosticSeverity { .error }

        case incorrectType
        case noVariantEnum

        var message: String {
            switch self {
            case .incorrectType:
                "@BaselineStringRemoteValue should be applied to struct"
            case .noVariantEnum:
                "No Variant enum was found in @BaselineStringRemoteValue struct"
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "Experiments", id: rawValue)
        }
    }
}

// MARK: - MemberMacro

extension BaselineStringRemoteValueMacro: MemberMacro {

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

        // Should contain Variant enum

        let members = declaration.memberBlock.members
        guard (members.first(where: { $0.decl.as(EnumDeclSyntax.self) != nil })?.decl.as(EnumDeclSyntax.self)) != nil else {
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.noVariantEnum)
            context.diagnose(diagnostic)
            return []
        }

        return try expansionForBaselineStringRemoteValue()
    }

    private static func expansionForBaselineStringRemoteValue() throws -> [DeclSyntax] {
        let baseline = try VariableDeclSyntax("let baseline: Bool")
        let variant = try VariableDeclSyntax("let variant: Variant")
        let optionalInitializer = try InitializerDeclSyntax("init?(name: String)") {
            try VariableDeclSyntax(#"let baseline = name.hasSuffix("_baseline")"#)
            try VariableDeclSyntax(#"let name = baseline ? String(name.dropLast("_baseline".count)) : name"#)
            """
            guard let variant = Variant(name: name) else { return nil }
            """
            CodeBlockItemSyntax(stringLiteral: "self.baseline = baseline")
            CodeBlockItemSyntax(stringLiteral: "self.variant = variant")
        }

        let initializer = try InitializerDeclSyntax("init(baseline: Bool, variant: Variant)") {
            CodeBlockItemSyntax(stringLiteral: "self.baseline = baseline")
            CodeBlockItemSyntax(stringLiteral: "self.variant = variant")
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

extension BaselineStringRemoteValueMacro: ExtensionMacro {

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

        // Should contain Variant enum

        let members = declaration.memberBlock.members
        guard (members.first(where: { $0.decl.as(EnumDeclSyntax.self) != nil })?.decl.as(EnumDeclSyntax.self)) != nil else {
            let diagnostic = Diagnostic(node: node, message: DiagnosticError.noVariantEnum)
            context.diagnose(diagnostic)
            return []
        }

        let ext = try ExtensionDeclSyntax("extension \(type.trimmed): CaseIterable, BaselineStringRemoteValue") {
            """
            static var allCases: [\(type.trimmed)] {
                Variant.allCases.flatMap {
                    [
                        \(type.trimmed)(baseline: true, variant: $0),
                        \(type.trimmed)(baseline: false, variant: $0)
                    ]
                }
            }

            var name: String {
                baseline ? variant.name + "_baseline" : variant.name
            }

            static var `default`: Self {
                \(type.trimmed)(baseline: true, variant: .default)
            }
            """
        }

        return [ext]
    }
}

// MARK: - MemberAttributeMacro

extension BaselineStringRemoteValueMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        if let member = member.as(EnumDeclSyntax.self) {
            if member.attributes.contains(where: {
                $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "StringRemoteValue"
            }) {
                []
            } else {
                ["@StringRemoteValue"]
            }
        } else {
            []
        }
    }
}
