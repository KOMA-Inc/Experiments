import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import Experiments

#if canImport(ExperimentsMacros)
import ExperimentsMacros

private let testMacros: [String: Macro.Type] = ["BaselineBoolRemoteValue": BaselineBoolRemoteValueMacro.self]
#endif

final class BaselineBoolRemoteValueMacroTests: XCTestCase {

    func testExpansionOnStruct() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BaselineBoolRemoteValue
        struct RemoteValue {

        }
        """,
        expandedSource:
        """
        struct RemoteValue {

            let baseline: Bool

            let isEnabled: Bool

            init?(name: String) {
                let baseline = name.hasSuffix("_baseline")
                let name = baseline ? String(name.dropLast("_baseline".count)) : name
                let isEnabled: Bool? = if name == "true" {
                    true
                } else if name == "false" {
                    false
                } else {
                    nil
                }
                guard let isEnabled else {
                    return nil
                }
                self.baseline = baseline
                self.isEnabled = isEnabled
            }

            init(baseline: Bool, isEnabled: Bool) {
                self.baseline = baseline
                self.isEnabled = isEnabled
            }

        }

        extension RemoteValue: CaseIterable, StringRemoteValue, BaselineStringRemoteValue {
            static var allCases: [RemoteValue] {
                [
                    RemoteValue(baseline: true, isEnabled: false),
                    RemoteValue(baseline: false, isEnabled: false),
                    RemoteValue(baseline: true, isEnabled: true),
                    RemoteValue(baseline: false, isEnabled: true),
                ]
            }

            var name: String {
                let status = isEnabled ? "Enabled" : "Disabled"
                return baseline ? status + "_baseline" : status
            }

            static var `default`: Self {
                RemoteValue(baseline: true, isEnabled: false)
            }
        }
        """,
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testExpansionOnStructWithDefaultArgument() throws {
        #if canImport(ExperimentsMacros)
        assertMacroExpansion(
        """
        @BaselineBoolRemoteValue(enabledByDefault: true)
        struct RemoteValue {

        }
        """,
        expandedSource:
        """
        struct RemoteValue {

            let baseline: Bool

            let isEnabled: Bool

            init?(name: String) {
                let baseline = name.hasSuffix("_baseline")
                let name = baseline ? String(name.dropLast("_baseline".count)) : name
                let isEnabled: Bool? = if name == "true" {
                    true
                } else if name == "false" {
                    false
                } else {
                    nil
                }
                guard let isEnabled else {
                    return nil
                }
                self.baseline = baseline
                self.isEnabled = isEnabled
            }

            init(baseline: Bool, isEnabled: Bool) {
                self.baseline = baseline
                self.isEnabled = isEnabled
            }

        }

        extension RemoteValue: CaseIterable, StringRemoteValue, BaselineStringRemoteValue {
            static var allCases: [RemoteValue] {
                [
                    RemoteValue(baseline: true, isEnabled: false),
                    RemoteValue(baseline: false, isEnabled: false),
                    RemoteValue(baseline: true, isEnabled: true),
                    RemoteValue(baseline: false, isEnabled: true),
                ]
            }

            var name: String {
                let status = isEnabled ? "Enabled" : "Disabled"
                return baseline ? status + "_baseline" : status
            }

            static var `default`: Self {
                RemoteValue(baseline: true, isEnabled: true)
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
        @BaselineBoolRemoteValue
        enum Value {
        }
        """,
        expandedSource:
        """

        enum Value {
        }
        """,
        diagnostics: [
            DiagnosticSpec(message: "@BaselineBoolRemoteValue should be applied to struct", line: 1, column: 1),
            DiagnosticSpec(message: "@BaselineBoolRemoteValue should be applied to struct", line: 1, column: 1)
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
        @BaselineBoolRemoteValue
        struct RemoteValue {
            enum Variant { }
        }
        """,
        expandedSource:
        """

        struct RemoteValue {
            enum Variant { }
        }
        """,
        diagnostics: [
            DiagnosticSpec(message: "@BaselineBoolRemoteValue should be applied to empty struct", line: 1, column: 1),
            DiagnosticSpec(message: "@BaselineBoolRemoteValue should be applied to empty struct", line: 1, column: 1)
        ],
        macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
