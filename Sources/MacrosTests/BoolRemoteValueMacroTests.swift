import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import Experiments

#if canImport(ExperimentsMacros)
import ExperimentsMacros

private let testMacros: [String: Macro.Type] = ["BoolRemoteValue": BoolRemoteValueMacro.self]
#endif


final class BoolRemoteValueMacroTests: XCTestCase {

    func testExpansionOnEmptyBoolEnum() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BoolRemoteValue
        enum RemoteValue {
        }
        """,
        expandedSource:
        """

        enum RemoteValue {

            case enabled

            case disabled

            init(booleanLiteral value: Bool) {
                self = value ? .enabled : .disabled
            }

            var isEnabled: Bool {
                switch self {
                case .enabled:
                    true
                case .disabled:
                    false
                }
            }
        }

        extension RemoteValue: BoolRemoteValue, CaseIterable, Equatable {
            static let `default`: Self = .disabled
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnEmptyBoolEnumWWithDefault() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BoolRemoteValue
        enum RemoteValue {
            static let `default`: Self = .enabled
        }
        """,
        expandedSource:
        """

        enum RemoteValue {
            static let `default`: Self = .enabled

            case enabled

            case disabled

            init(booleanLiteral value: Bool) {
                self = value ? .enabled : .disabled
            }

            var isEnabled: Bool {
                switch self {
                case .enabled:
                    true
                case .disabled:
                    false
                }
            }
        }

        extension RemoteValue: BoolRemoteValue, CaseIterable, Equatable {
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnEmptyBoolEnumWithParameter() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BoolRemoteValue(enabledByDefault: true)
        enum RemoteValue {
        }
        """,
        expandedSource:
        """

        enum RemoteValue {

            case enabled

            case disabled

            init(booleanLiteral value: Bool) {
                self = value ? .enabled : .disabled
            }

            var isEnabled: Bool {
                switch self {
                case .enabled:
                    true
                case .disabled:
                    false
                }
            }
        }

        extension RemoteValue: BoolRemoteValue, CaseIterable, Equatable {
            static let `default`: Self = .enabled
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnEmptyBoolEnumWithParameterAndDefault() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BoolRemoteValue(enabledByDefault: true)
        enum RemoteValue {
            static let `default`: Self = .disabled
        }
        """,
        expandedSource:
        """

        enum RemoteValue {
            static let `default`: Self = .disabled

            case enabled

            case disabled

            init(booleanLiteral value: Bool) {
                self = value ? .enabled : .disabled
            }

            var isEnabled: Bool {
                switch self {
                case .enabled:
                    true
                case .disabled:
                    false
                }
            }
        }

        extension RemoteValue: BoolRemoteValue, CaseIterable, Equatable {
        }
        """,
        diagnostics: [
            DiagnosticSpec(message: "enabledByDefault parameter is ignored as `default` property is already declared", line: 1, column: 1, severity: .warning)
        ],
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnEmptyBoolEnumWithBoolRemoteValueConform() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BoolRemoteValue
        enum RemoteValue: BoolRemoteValue {
        }
        """,
        expandedSource:
        """

        enum RemoteValue: BoolRemoteValue {

            case enabled

            case disabled

            init(booleanLiteral value: Bool) {
                self = value ? .enabled : .disabled
            }

            var isEnabled: Bool {
                switch self {
                case .enabled:
                    true
                case .disabled:
                    false
                }
            }
        }

        extension RemoteValue: CaseIterable, Equatable {
            static let `default`: Self = .disabled
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnEmptyBoolEnumWithCaseIterableConform() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BoolRemoteValue
        enum RemoteValue: CaseIterable {
        }
        """,
        expandedSource:
        """

        enum RemoteValue: CaseIterable {

            case enabled

            case disabled

            init(booleanLiteral value: Bool) {
                self = value ? .enabled : .disabled
            }

            var isEnabled: Bool {
                switch self {
                case .enabled:
                    true
                case .disabled:
                    false
                }
            }
        }

        extension RemoteValue: BoolRemoteValue, Equatable {
            static let `default`: Self = .disabled
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnEmptyBoolEnumWithSeveralConforms() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BoolRemoteValue
        enum RemoteValue: CaseIterable, BoolRemoteValue {
        }
        """,
        expandedSource:
        """

        enum RemoteValue: CaseIterable, BoolRemoteValue {

            case enabled

            case disabled

            init(booleanLiteral value: Bool) {
                self = value ? .enabled : .disabled
            }

            var isEnabled: Bool {
                switch self {
                case .enabled:
                    true
                case .disabled:
                    false
                }
            }
        }

        extension RemoteValue: Equatable {
            static let `default`: Self = .disabled
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorOnIncorrectEnum() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BoolRemoteValue
        enum RemoteValue: String {

        }
        """,
        expandedSource:
        """

        enum RemoteValue: String {

        }
        """,
        diagnostics: [
            DiagnosticSpec(message: "@BoolRemoteValue can't have String rawValue", line: 1, column: 1),
            DiagnosticSpec(message: "@BoolRemoteValue can't have String rawValue", line: 1, column: 1)
        ],
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorOnIncorrectType() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BoolRemoteValue
        class RemoteValue {

        }
        """,
        expandedSource:
        """

        class RemoteValue {

        }
        """,
        diagnostics: [
            DiagnosticSpec(message: "@BoolRemoteValue should be applied to enum", line: 1, column: 1),
            DiagnosticSpec(message: "@BoolRemoteValue should be applied to enum", line: 1, column: 1)
        ],
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
