// MARK: - StringRemoteValue

@attached(
    extension,
    conformances: CaseIterable, StringRemoteValue, Equatable
)
public macro StringRemoteValue() = #externalMacro(module: "ExperimentsMacros", type: "StringRemoteValueMacro")

// MARK: - BoolRemoteValue

@attached(
    member,
    names: named(enabled), named(disabled), named(isEnabled), named(init(booleanLiteral:))
)
@attached(
    extension,
    conformances: CaseIterable, BoolRemoteValue, Equatable,
    names: named(`default`)
)
public macro BoolRemoteValue(enabledByDefault: Bool = false) = #externalMacro(module: "ExperimentsMacros", type: "BoolRemoteValueMacro")

// MARK: - BaselineStringRemoteValue

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
public macro BaselineStringRemoteValue() = #externalMacro(module: "ExperimentsMacros", type: "BaselineStringRemoteValueMacro")

// MARK: - BaselineBoolRemoteValue

@attached(
    member,
    names: named(baseline), named(isEnabled), named(init(name:)), named(init(baseline:isEnabled:))
)
@attached(
    extension,
    conformances: CaseIterable, BaselineStringRemoteValue, StringRemoteValue,
    names: named(`default`), named(allCases), named(name)
)
public macro BaselineBoolRemoteValue(enabledByDefault: Bool = false) = #externalMacro(module: "ExperimentsMacros", type: "BaselineBoolRemoteValueMacro")


// MARK: - RemoteValuesNamespace

@attached(memberAttribute)
public macro RemoteValuesNamespace() = #externalMacro(module: "ExperimentsMacros", type: "RemoteValuesNamespaceMacro")
