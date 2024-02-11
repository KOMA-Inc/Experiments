//import SwiftSyntaxMacros
//import SwiftSyntaxMacrosTestSupport
//import XCTest
//
//@testable import Experiments
//
//#if canImport(ExperimentsMacros)
//import ExperimentsMacros
//
//private let testMacros: [String: Macro.Type] = ["BaselineRemoteValue": BaselineRemoteValueMacro.self]
//#endif
//
//final class BaselineRemoteValueMacroTests: XCTestCase {
//
//    func testExpansionOnStruct() throws {
//        #if canImport(ExperimentsMacros)
//        assertMacroExpansion(
//        """
//        @BaselineRemoteValue
//        struct RemoteValue {
//
//            enum Variant: String {
//                case a, b
//                case c = "c_test", d, e = "sd"
//                case f
//            }
//        }
//
//        """,
//        expandedSource:
//        """
//        struct RemoteValue {
//            @RemoteValue
//
//            enum Variant: String {
//                case a, b
//                case c = "c_test", d, e = "sd"
//                case f
//            }
//
//            let baseline: Bool
//
//            let variant: Variant
//
//            init?(name: String) {
//                let baseline = name.hasSuffix("_baseline")
//                let name = baseline ? String(name.dropLast("_baseline".count)) : name
//                guard let variant = Variant(name: name) else {
//                    return nil
//                }
//                self.baseline = baseline
//                self.variant = variant
//            }
//
//            init(baseline: Bool, variant: Variant) {
//                self.baseline = baseline
//                self.variant = variant
//            }
//        }
//
//        extension RemoteValue: CaseIterable, StringRemoteValue, BaselineStringRemoteValue {
//            static var allCases: [RemoteValue] {
//                [
//                    RemoteValue(baseline: true, variant: .a),
//                    RemoteValue(baseline: false, variant: .a),
//                    RemoteValue(baseline: true, variant: .b),
//                    RemoteValue(baseline: false, variant: .b),
//                    RemoteValue(baseline: true, variant: .c),
//                    RemoteValue(baseline: false, variant: .c),
//                    RemoteValue(baseline: true, variant: .d),
//                    RemoteValue(baseline: false, variant: .d),
//                    RemoteValue(baseline: true, variant: .e),
//                    RemoteValue(baseline: false, variant: .e),
//                    RemoteValue(baseline: true, variant: .f),
//                    RemoteValue(baseline: false, variant: .f)
//                ]
//            }
//
//            var name: String {
//                baseline ? variant.name + "_baseline" : variant.name
//            }
//
//            static var `default`: Self {
//                RemoteValue(baseline: true, variant: .default)
//            }
//        }
//        """,
//        macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
//
//    func testExpansionOnStructWithPresentMacro() throws {
//        #if canImport(ExperimentsMacros)
//        assertMacroExpansion(
//        """
//        @BaselineRemoteValue
//        struct RemoteValue {
//
//            @RemoteValue
//            enum Variant: String {
//                case a, b
//                case c = "c_test", d, e = "sd"
//                case f
//            }
//        }
//
//        """,
//        expandedSource:
//        """
//        struct RemoteValue {
//
//            @RemoteValue
//            enum Variant: String {
//                case a, b
//                case c = "c_test", d, e = "sd"
//                case f
//            }
//
//            let baseline: Bool
//
//            let variant: Variant
//
//            init?(name: String) {
//                let baseline = name.hasSuffix("_baseline")
//                let name = baseline ? String(name.dropLast("_baseline".count)) : name
//                guard let variant = Variant(name: name) else {
//                    return nil
//                }
//                self.baseline = baseline
//                self.variant = variant
//            }
//
//            init(baseline: Bool, variant: Variant) {
//                self.baseline = baseline
//                self.variant = variant
//            }
//        }
//
//        extension RemoteValue: CaseIterable, StringRemoteValue, BaselineStringRemoteValue {
//            static var allCases: [RemoteValue] {
//                [
//                    RemoteValue(baseline: true, variant: .a),
//                    RemoteValue(baseline: false, variant: .a),
//                    RemoteValue(baseline: true, variant: .b),
//                    RemoteValue(baseline: false, variant: .b),
//                    RemoteValue(baseline: true, variant: .c),
//                    RemoteValue(baseline: false, variant: .c),
//                    RemoteValue(baseline: true, variant: .d),
//                    RemoteValue(baseline: false, variant: .d),
//                    RemoteValue(baseline: true, variant: .e),
//                    RemoteValue(baseline: false, variant: .e),
//                    RemoteValue(baseline: true, variant: .f),
//                    RemoteValue(baseline: false, variant: .f)
//                ]
//            }
//
//            var name: String {
//                baseline ? variant.name + "_baseline" : variant.name
//            }
//
//            static var `default`: Self {
//                RemoteValue(baseline: true, variant: .default)
//            }
//        }
//        """,
//        macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
//
//    func testErrorOnIncorrectType() throws {
//        #if canImport(ExperimentsMacros)
//        assertMacroExpansion(
//        """
//        @BaselineRemoteValue
//        enum Value {
//        }
//        """,
//        expandedSource:
//        """
//
//        enum Value {
//        }
//        """,
//        diagnostics: [
//            DiagnosticSpec(message: "@BaselineRemoteValue should be applied to struct", line: 1, column: 1),
//            DiagnosticSpec(message: "@BaselineRemoteValue should be applied to struct", line: 1, column: 1)
//        ],
//        macros: testMacros
//        )
//        #else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
//}
