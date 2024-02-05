import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct BaselineRemoteValueMacro {
    enum DiagnosticError: String, DiagnosticMessage {

        var severity: DiagnosticSeverity { .error }

        case incorrectType

        var message: String {
            switch self {
            case .incorrectType:
                "@BaselineRemoteValue should be applied to struct"
            }
        }

        var diagnosticID: MessageID {
            MessageID(domain: "Experiments", id: rawValue)
        }
    }
}

// MARK: - MemberMacro

extension BaselineRemoteValueMacro: MemberMacro {

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

extension BaselineRemoteValueMacro: ExtensionMacro {

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

        let members = declaration.memberBlock.members
        guard let enumBlock = members.first(where: { $0.decl.as(EnumDeclSyntax.self) != nil })?.decl.as(EnumDeclSyntax.self) else {
            return []
        }
        let enumMembers = enumBlock.memberBlock.members
        let caseDecls = enumMembers.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let elements = caseDecls.flatMap { $0.elements }
        let allCases = elements.flatMap { element in
            [
                "\(type.trimmed)(baseline: true, variant: .\(element.name.text))",
                "\(type.trimmed)(baseline: false, variant: .\(element.name.text))"
            ]
        }


        let ext = try ExtensionDeclSyntax("extension \(type.trimmed): CaseIterable, StringRemoteValue, BaselineStringRemoteValue") {
            """
            static var allCases: [\(type.trimmed)] {
                [
                    \(raw: allCases.joined(separator: ",\n"))
                ]
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

extension BaselineRemoteValueMacro: MemberAttributeMacro {
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
        } else {
            []
        }
    }
}
