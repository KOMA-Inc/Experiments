@attached(
    member,
    names: named(baseline), named(variant), named(init(name:)), named(init(baseline:variant:)), named(enabled), named(disabled), named(rawValue)
)
@attached(
    extension,
    conformances: CaseIterable, BaselineStringRemoteValue, StringRemoteValue, BoolRemoteValue, Equatable,
    names: named(`default`), named(allCases), named(name)
)
public macro RemoteValue() = #externalMacro(module: "ExperimentsMacros", type: "RemoteValueMacro")

@attached(memberAttribute)
@attached(
    member,
    names: named(baseline), named(variant), named(init(name:)), named(init(baseline:variant:))
)
@attached(
    extension,
    conformances: CaseIterable, BaselineStringRemoteValue, StringRemoteValue,
    names: named(`default`), named(allCases), named(name)
)
public macro BaselineRemoteValue() = #externalMacro(module: "ExperimentsMacros", type: "BaselineRemoteValueMacro")

@attached(memberAttribute)
public macro RemoteValuesNamespace() = #externalMacro(module: "ExperimentsMacros", type: "RemoteValuesNamespaceMacro")
