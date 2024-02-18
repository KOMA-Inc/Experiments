import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import Experiments

#if canImport(ExperimentsMacros)
import ExperimentsMacros

private let testMacros: [String: Macro.Type] = ["StringRemoteValue": StringRemoteValueMacro.self]
#endif


final class StringRemoteValueMacroTests: XCTestCase {

    func testExpansionOnStringRawRepresentableEnum() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @StringRemoteValue
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

        extension RemoteValue: CaseIterable, Equatable, StringRemoteValue {
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnStringRawRepresentableEnumWithSeveralConforms() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @StringRemoteValue
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

        extension RemoteValue: Equatable {
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnStringRawRepresentableEnumWithCaseIterableConform() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @StringRemoteValue
        enum RemoteValue: String, CaseIterable {
            case a, b
            case c = "c_test", d, e = "sd"
            case f
        }
        """,
        expandedSource:
        """

        enum RemoteValue: String, CaseIterable {
            case a, b
            case c = "c_test", d, e = "sd"
            case f
        }

        extension RemoteValue: Equatable, StringRemoteValue {
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnStringRawRepresentableEnumWithStringRemoteValueConform() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @StringRemoteValue
        enum RemoteValue: String, StringRemoteValue {
            case a, b
            case c = "c_test", d, e = "sd"
            case f
        }
        """,
        expandedSource:
        """

        enum RemoteValue: String, StringRemoteValue {
            case a, b
            case c = "c_test", d, e = "sd"
            case f
        }

        extension RemoteValue: CaseIterable, Equatable {
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
        @StringRemoteValue
        enum RemoteValue {
        }
        """,
        expandedSource:
        """

        enum RemoteValue {
        }
        """,
        diagnostics: [
            DiagnosticSpec(message: "@StringRemoteValue needs enum that conforms to String", line: 1, column: 1)
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
        @StringRemoteValue
        class RemoteValue {

        }

        """,
        expandedSource:
        """

        class RemoteValue {

        }
        """,
        diagnostics: [
            DiagnosticSpec(message: "@StringRemoteValue should be applied to enum", line: 1, column: 1)
        ],
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
