import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import Experiments

#if canImport(ExperimentsMacros)
import ExperimentsMacros

private let testMacros: [String: Macro.Type] = ["RemoteValue": RemoteValueMacro.self]
#endif


final class RemoteValueMacroTests: XCTestCase {

    func testExpansionOnStringRawRepresentableEnum() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @RemoteValue
        enum RemoteValue: String {
            case a, b
            case c = "c_test", d, e = "sd"
            case f
        }
        """,
        expandedSource:
        """

        enum RemoteValue: String {
            case a, b
            case c = "c_test", d, e = "sd"
            case f
        }

        extension RemoteValue: CaseIterable, StringRemoteValue {
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnStringRawRepresentableEnumWithConforms() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @RemoteValue
        enum RemoteValue: String, CaseIterable, StringRemoteValue {
            case a, b
            case c = "c_test", d, e = "sd"
            case f
        }
        """,
        expandedSource:
        """

        enum RemoteValue: String, CaseIterable, StringRemoteValue {
            case a, b
            case c = "c_test", d, e = "sd"
            case f
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnIntRawRepresentableEnum() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @RemoteValue
        enum RemoteValue {
        }
        """,
        expandedSource:
        """

        enum RemoteValue {

            case enabled

            case disabled

            var rawValue: Int {
                switch self {
                case .enabled:
                    1
                case .disabled:
                    0
                }
            }
        }

        extension RemoteValue: CaseIterable, BoolRemoteValue {
        }
        """,
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
        @RemoteValue
        class RemoteValue {

        }

        """,
        expandedSource:
        """

        class RemoteValue {

        }
        """,
        diagnostics: [
            DiagnosticSpec(message: "@RemoteValue should be applied to enum", line: 1, column: 1),
            DiagnosticSpec(message: "@RemoteValue should be applied to enum", line: 1, column: 1)
        ],
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorOnUnsupportedEnum() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @RemoteValue
        enum RemoteValue: Int {

        }

        """,
        expandedSource:
        """

        enum RemoteValue: Int {

        }
        """,
        diagnostics: [
            DiagnosticSpec(message: "@RemoteValue needs enum that conforms to String or nothing", line: 1, column: 1),
            DiagnosticSpec(message: "@RemoteValue needs enum that conforms to String or nothing", line: 1, column: 1)
        ],
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
