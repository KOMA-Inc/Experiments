import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugins: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RemoteValueMacro.self,
        BaselineRemoteValueMacro.self,
        RemoteValuesNamespaceMacro.self
    ]
}
