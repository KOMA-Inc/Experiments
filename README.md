# Introduction 

Experiments is a framework that helps to setup A/B testing infrustructure. It provides methods for defining your remote keys and values as well as services to work with.  

Currenly, only one concrete service is available - the one to be used for Firebase Remote Configs, however, you can define you own by conforming it to needed protocols.

# Defining values and keys

## Keys

Key is something that conforms to protocol `RemoteKey`:
```swift
public protocol RemoteKey {
    var name: String { get }
    var valueType: RemoteValue.Type { get }
}
```
The recommended approach is to use enum for this:
```swift
enum Key: String, CaseIterable, RemoteKey {

    case paywallType = "paywall_type"
    case aFeatureEnabled = "a_feature_enabled"

    var name: String {
        rawValue
    }

    var valueType: RemoteValue.Type {
        switch self {
        case .paywallType:
            PaywallType.self
        case .aFeatureEnabled:
            AFeatureEnabled.self
        }
    }
}
```
Here RemoteValue is a protocol with only one requirement:
```swift
public protocol RemoteValue {
    static var `default`: Self { get }
}
```

default value is the one that will be used by the app, if it failed to retrieve remote values

## Values

Currenly only flows with values that are created from Bool or String are supported. Craetion from Int / JSON will be possibly added later.  
`Experiments` framework provides macros to help you define your remote values, which are heighly recommended, but not obligatory. Below, both variants will be shown.  

### String Remote Value


If your remote values are created from String

Non macros way:
```swift
enum PaywallType: String, CaseIterable, StringInitializableRemoteValue {
    case a, b, c
}
```

Macros way:
```swift
@StringRemoteValue
enum PaywallType: String {
    case a, b, c
}
```

default value will be `a` (first from allCases), but you can override it.

Non macros way:
```swift
enum PaywallType: String, CaseIterable, StringInitializableRemoteValue {
    case a, b, c

    static let `default`: Self = .b
}
```

Macros way:
```swift
@StringRemoteValue
enum PaywallType: String {
    case a, b, c

    static let `default`: Self = .b
}
```

### Bool Remote Value

If your remote values are created from Bool

Non macros way:
```swift
enum AFeatureEnabled: CaseIterable, BoolEnumRemoteValue {
    case enabled
    case disabled
}
```

Macros way:
```swift
@BoolRemoteValue
enum AFeatureEnabled { }
```

default value will be `disabled`, but you can override it.

Non macros way:
```swift
enum AFeatureEnabled: CaseIterable, BoolEnumRemoteValue {
    case enabled
    case disabled

    static let `default`: Self = .enabled
}
```

Macros way:
```swift
@BoolRemoteValue
enum AFeatureEnabled {
    static let `default`: Self = .enabled
}

or

@BoolRemoteValue(enabledBeDefault: true)
enum AFeatureEnabled { }
```

# Using services

To work with remote keys / values you've defined, you can use `RemoteConfigService`. It is a class that only requires some `RemoteConfigKeeper`.  
There is one ready-to-use class `FirebaseRemoteConfigService`, that uses instance of `FirebaseRemoteConfigKeeper`.  

The instance of `FirebaseRemoteConfigService` should be kept as singleton in your app, as it has its local state.  

Algorithm is the following:
1. Use `fetch()` method and wait for the completion (it will fetch config from the Firebase)
2. To setup some kind of analytics groups, track missing keys / incorrect values, use `getValues(for:)` method (eg.: `getValues(for: RemoteKey.allCases)`)
3. You can later use methods `remoteValue(for:)` or `remoteValuePublisher(for:)` to retrieve value / publisher for remote key

# Notes

`RemoteConfigService` has several open methods you probably would like to override:
- `trackKeyNotFound` - is called when performing `getValues(for:)` for missing key
- `trackKeysNotFound` - is called after performing `getValues(for:)` for all missing keys
- `trackIncorrectValue` - is called when performing `getValues(for:)` for valid key but corrupted value
- `trackIncorrectValues` - is called after performing `getValues(for:)` for valid key but corrupted value
- `trackExperimentalGroup` - is called when performing `getValues(for:)` for valid remote value, if it conforms to `ExperimentalGroupTrackable`
- `debugValue(for:)` - if your app uses some kind of debug mechanism and this method does not return `nil`, the returned value will be used insead of real from Firebase.
