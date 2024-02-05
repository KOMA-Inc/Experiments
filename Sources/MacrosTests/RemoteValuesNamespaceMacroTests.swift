import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import Experiments

#if canImport(ExperimentsMacros)
import ExperimentsMacros

private let testMacros: [String: Macro.Type] = ["RemoteValuesNamespace": RemoteValuesNamespaceMacro.self]
#endif

final class RemoteValuesNamespaceMacroTests: XCTestCase {

    func testExpansionOnNamespace() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @RemoteValuesNamespace
        enum Value {

            enum SolvingFlow: String {
                case a
                case b
            }

            struct Paywall {

                enum Variant: String {
                    case a
                    case b = "b_var"
                }
            }

            enum TestEnabled {}
        }
        """,
        expandedSource:
        """

        enum Value {
            @RemoteValue

            enum SolvingFlow: String {
                case a
                case b
            }
            @BaselineRemoteValue

            struct Paywall {

                enum Variant: String {
                    case a
                    case b = "b_var"
                }
            }
            @RemoteValue

            enum TestEnabled {}
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnNamespaceWithPresentMacros() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @RemoteValuesNamespace
        enum Value {

            @RemoteValue
            enum SolvingFlow: String {
                case a
                case b
            }

            @BaselineRemoteValue
            struct Paywall {

                enum Variant: String {
                    case a
                    case b = "b_var"
                }
            }

            @RemoteValue
            enum TestEnabled {}
        }
        """,
        expandedSource:
        """

        enum Value {

            @RemoteValue
            enum SolvingFlow: String {
                case a
                case b
            }

            @BaselineRemoteValue
            struct Paywall {

                enum Variant: String {
                    case a
                    case b = "b_var"
                }
            }

            @RemoteValue
            enum TestEnabled {}
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
