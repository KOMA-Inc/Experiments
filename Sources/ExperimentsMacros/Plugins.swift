import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugins: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringRemoteValueMacro.self,
        BoolRemoteValueMacro.self,
        BaselineStringRemoteValueMacro.self,
        BaselineBoolRemoteValueMacro.self,
        RemoteValuesNamespaceMacro.self
    ]
}
