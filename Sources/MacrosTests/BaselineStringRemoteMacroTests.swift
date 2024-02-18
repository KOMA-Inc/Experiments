import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import Experiments

#if canImport(ExperimentsMacros)
import ExperimentsMacros

private let testMacros: [String: Macro.Type] = ["BaselineStringRemoteValue": BaselineStringRemoteValueMacro.self]
#endif

final class BaselineStringRemoteValueMacroTests: XCTestCase {

    func testExpansionOnStruct() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BaselineStringRemoteValue
        struct RemoteValue {

            enum Variant: String {
                case a, b
                case c = "c_test", d, e = "sd"
                case f
            }
        }

        """,
        expandedSource:
        """
        struct RemoteValue {
            @StringRemoteValue

            enum Variant: String {
                case a, b
                case c = "c_test", d, e = "sd"
                case f
            }

            let baseline: Bool

            let variant: Variant

            init?(name: String) {
                let baseline = name.hasSuffix("_baseline")
                let name = baseline ? String(name.dropLast("_baseline".count)) : name
                guard let variant = Variant(name: name) else {
                    return nil
                }
                self.baseline = baseline
                self.variant = variant
            }

            init(baseline: Bool, variant: Variant) {
                self.baseline = baseline
                self.variant = variant
            }
        }

        extension RemoteValue: CaseIterable, BaselineStringRemoteValue {
            static var allCases: [RemoteValue] {
                Variant.allCases.flatMap {
                    [
                        RemoteValue(baseline: true, variant: $0),
                        RemoteValue(baseline: false, variant: $0)
                    ]
                }
            }

            var name: String {
                baseline ? variant.name + "_baseline" : variant.name
            }

            static var `default`: Self {
                RemoteValue(baseline: true, variant: .default)
            }
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnStructWithPresentMacro() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BaselineStringRemoteValue
        struct RemoteValue {

            @StringRemoteValue
            enum Variant: String {
                case a, b
                case c = "c_test", d, e = "sd"
                case f
            }
        }

        """,
        expandedSource:
        """
        struct RemoteValue {

            @StringRemoteValue
            enum Variant: String {
                case a, b
                case c = "c_test", d, e = "sd"
                case f
            }

            let baseline: Bool

            let variant: Variant

            init?(name: String) {
                let baseline = name.hasSuffix("_baseline")
                let name = baseline ? String(name.dropLast("_baseline".count)) : name
                guard let variant = Variant(name: name) else {
                    return nil
                }
                self.baseline = baseline
                self.variant = variant
            }

            init(baseline: Bool, variant: Variant) {
                self.baseline = baseline
                self.variant = variant
            }
        }

        extension RemoteValue: CaseIterable, BaselineStringRemoteValue {
            static var allCases: [RemoteValue] {
                Variant.allCases.flatMap {
                    [
                        RemoteValue(baseline: true, variant: $0),
                        RemoteValue(baseline: false, variant: $0)
                    ]
                }
            }

            var name: String {
                baseline ? variant.name + "_baseline" : variant.name
            }

            static var `default`: Self {
                RemoteValue(baseline: true, variant: .default)
            }
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
        @BaselineStringRemoteValue
        enum Value {
        }
        """,
        expandedSource:
        """

        enum Value {
        }
        """,
        diagnostics: [
            DiagnosticSpec(message: "@BaselineStringRemoteValue should be applied to struct", line: 1, column: 1),
            DiagnosticSpec(message: "@BaselineStringRemoteValue should be applied to struct", line: 1, column: 1)
        ],
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorOnIncorrectStruct() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BaselineStringRemoteValue
        struct RemoteValue {
        }
        """,
        expandedSource:
        """

        struct RemoteValue {
        }
        """,
        diagnostics: [
            DiagnosticSpec(message: "No Variant enum was found in @BaselineStringRemoteValue struct", line: 1, column: 1),
            DiagnosticSpec(message: "No Variant enum was found in @BaselineStringRemoteValue struct", line: 1, column: 1)
        ],
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
