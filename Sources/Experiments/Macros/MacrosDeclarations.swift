// MARK: - StringRemoteValue

@attached(
    extension,
    conformances: CaseIterable, StringRemoteValue
)
public macro StringRemoteValue() = #externalMacro(module: "ExperimentsMacros", type: "StringRemoteValueMacro")

// MARK: - BoolRemoteValue

@attached(
    member,
    names: named(enabled), named(disabled), named(rawValue), named(init(booleanLiteral:))
)
@attached(
    extension,
    conformances: CaseIterable, BoolRemoteValue,
    names: named(`default`)
)
public macro BoolRemoteValue(enabledByDefault: Bool = false) = #externalMacro(module: "ExperimentsMacros", type: "BoolRemoteValueMacro")















//
//@attached(memberAttribute)
//@attached(
//    member,
//    names: named(baseline), named(variant), named(init(name:)), named(init(baseline:variant:))
//)
//@attached(
//    extension,
//    conformances: CaseIterable, BaselineStringRemoteValue, StringRemoteValue,
//    names: named(`default`), named(allCases), named(name)
//)
//public macro BaselineRemoteValue() = #externalMacro(module: "ExperimentsMacros", type: "BaselineRemoteValueMacro")

// MARK: - RemoteValuesNamespace

@attached(memberAttribute)
public macro RemoteValuesNamespace() = #externalMacro(module: "ExperimentsMacros", type: "RemoteValuesNamespaceMacro")
