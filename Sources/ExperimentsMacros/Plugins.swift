import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugins: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringRemoteValueMacro.self,
        BoolRemoteValueMacro.self,
        BaselineRemoteValueMacro.self,
        RemoteValuesNamespaceMacro.self
    ]
}
