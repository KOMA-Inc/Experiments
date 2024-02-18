# Introduction 

Experiments is a framework designed to facilitate the setup of A/B testing infrastructure. It offers methods for defining remote keys and values, along with services to interact with them. 

Currently, the framework supports a Firebase Remote Configs service, but you can define your own by conforming to the necessary protocols.

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

default value is the one that will be used by the app, if it failed to retrieve remote values. We can call it in-app default / baseline value

## Values

Currenly only flows with values that are created from Bool or String are supported. Craetion from Int / JSON will be possibly added later.  
There are 4 use-cases for remote values:
1. **String Remote Value**. Use when you need a multivariant remote value
2. **Bool Remote Value**. Use when you need enabled / disabled remote value
3. _(Advacned)_ **Baseline String Remote Value**. Use when you need a multivariant remote value and overriding of the in-app default / baseline.
4. _(Advanced)_ **Baseline Bool Remote Value**. Use when you need enabled / disabled remote value and overriding of the in-app default / baseline.
   
`Experiments` framework provides macros to help you define your remote values, which are heighly recommended, but not obligatory. Below, both variants will be shown.  

<table>
    
<tr>
<th></th>
<th>Non macros way</th>
<th>Macros way</th>
</tr>
    
<tr>
<td>
String Remote Value
</td>
<td>

```swift
enum PaywallType: String, CaseIterable, StringInitializableRemoteValue {
    case a, b, c
}
```

<details>
<summary>Override `default`</summary>

```swift
enum PaywallType: String, CaseIterable, StringInitializableRemoteValue {
    case a, b, c

    static let `default`: Self = .b
}
```
</details>


</td>

<td>

```swift
@StringRemoteValue
enum PaywallType: String {
    case a, b, c
}
```

<details>
<summary>Override `default`</summary>

```swift
@StringRemoteValue
enum PaywallType: String {
    case a, b, c

    static let `default`: Self = .b
}
```

</details>

</td>

</tr>

<tr>
<td>
Bool Remote Value
</td>
<td>

```swift
enum AFeatureEnabled: CaseIterable, BoolEnumRemoteValue {
    case enabled
    case disabled
}
```

<details>
<summary>Override `default`</summary>

```swift
enum AFeatureEnabled: CaseIterable, BoolEnumRemoteValue {
    case enabled
    case disabled

    static let `default`: Self = .enabled
}
```

</details>


</td>

<td>

```swift
@BoolRemoteValue
enum AFeatureEnabled { }
```

<details>
<summary>Override `default`</summary>

```swift
@BoolRemoteValue
enum AFeatureEnabled {
    static let `default`: Self = .enabled
}

or

@BoolRemoteValue(enabledByDefault: true)
enum AFeatureEnabled { }
```

</details>

</td>

</tr>

<tr>
<td>
Baseline String Remote Value
</td>
<td>

```swift
struct StringBaselineTest: CaseIterable, BaselineStringRemoteValue {

    enum Variant: String, CaseIterable, StringInitializableRemoteValue {
        case a, b, c
    }

    let baseline: Bool
    let variant: Variant

    init(baseline: Bool, variant: Variant) {
        self.baseline = baseline
        self.variant = variant
    }

    init?(name: String) {
        let baseline = name.hasSuffix("_baseline")
        let name = baseline ? String(name.dropLast("_baseline".count)) : name
        guard let variant = Variant(name: name) else {
            return nil
        }
        self.baseline = baseline
        self.variant = variant
    }

    var name: String {
        variant.name
    }

    static var allCases: [StringBaselineTest] {
        Variant.allCases.flatMap {
            [
                StringBaselineTest(baseline: true, variant: $0),
                StringBaselineTest(baseline: false, variant: $0)
            ]
        }
    }
}
```

<details>
<summary>Override `default`</summary>

```swift
struct StringBaselineTest: CaseIterable, BaselineStringRemoteValue {

    enum Variant: String, CaseIterable, StringInitializableRemoteValue {
        case a, b, c
    }

    let baseline: Bool
    let variant: Variant

    init(baseline: Bool, variant: Variant) {
        self.baseline = baseline
        self.variant = variant
    }

    init?(name: String) {
        let baseline = name.hasSuffix("_baseline")
        let name = baseline ? String(name.dropLast("_baseline".count)) : name
        guard let variant = Variant(name: name) else {
            return nil
        }
        self.baseline = baseline
        self.variant = variant
    }

    var name: String {
        variant.name
    }

    static var allCases: [StringBaselineTest] {
        Variant.allCases.flatMap {
            [
                StringBaselineTest(baseline: true, variant: $0),
                StringBaselineTest(baseline: false, variant: $0)
            ]
        }
    }

    static let `default`: Self = StringBaselineTest(baseline: true, variant: .b)
}
```

</details>

</td>

<td>

```swift
@BaselineStringRemoteValue
struct StringBaselineTestMacro {

    enum Variant: String {
        case a, b, c
    }
}
```


<details>
<summary>Override `default`</summary>

```swift
@BaselineStringRemoteValue
struct StringBaselineTestMacro {

    enum Variant: String {
        case a, b, c

        static let `default`: Self = .b
    }
}
```

</details>

</td>

</tr>

<tr>
<td>
Baseline Bool Remote Value
</td>
<td>

```swift
struct BoolBaselineTest: CaseIterable, BaselineBoolRemoteValue {

    let baseline: Bool
    let isEnabled: Bool

    init(baseline: Bool, isEnabled: Bool) {
        self.baseline = baseline
        self.isEnabled = isEnabled
    }

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

        guard let isEnabled else { return nil }

        self.baseline = baseline
        self.isEnabled = isEnabled
    }

    var name: String {
        isEnabled ? "Enabled" : "Disabled"
    }

    static var allCases: [BoolBaselineTest] {
        [
            BoolBaselineTest(baseline: true, isEnabled: true),
            BoolBaselineTest(baseline: false, isEnabled: true),
            BoolBaselineTest(baseline: false, isEnabled: true),
            BoolBaselineTest(baseline: false, isEnabled: false)
        ]
    }
}
```

<details>
<summary>Override `default`</summary>

```swift
struct BoolBaselineTest: CaseIterable, BaselineBoolRemoteValue {

    let baseline: Bool
    let isEnabled: Bool

    init(baseline: Bool, isEnabled: Bool) {
        self.baseline = baseline
        self.isEnabled = isEnabled
    }

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

        guard let isEnabled else { return nil }

        self.baseline = baseline
        self.isEnabled = isEnabled
    }

    var name: String {
        isEnabled ? "Enabled" : "Disabled"
    }

    static var allCases: [BoolBaselineTest] {
        [
            BoolBaselineTest(baseline: true, isEnabled: true),
            BoolBaselineTest(baseline: false, isEnabled: true),
            BoolBaselineTest(baseline: false, isEnabled: true),
            BoolBaselineTest(baseline: false, isEnabled: false)
        ]
    }

    static let `default`: Self = BoolBaselineTest(baseline: truee, isEnabled; false)
}
```

</details>


</td>

<td>

```swift
@BaselineBoolRemoteValue
struct BoolBaselineTestMacro { }
```

<details>
<summary>Override `default`</summary>

```swift
@BaselineBoolRemoteValue(enabledByDefault: true)
struct BoolBaselineTestMacro { }
```

</details>

</td>

</tr>

</table>

Using `RemoteValuesNamespace` macro, you can encapsulate all remote values in namespace and avoid using macros with every declaration:
```swift
enum Remote {

    @RemoteValuesNamespace
    enum Value {

        struct PaywallType {

            enum Variant: String {
                case a, b, c
            }
        }

        struct AFeatureEnabled { }

        // use only to override default
        @BaselineBoolRemoteValue(enabledByDefault: true)
        struct BFeatureEnabled { }

        enum CFeatureEnabled { }

        enum OnboardingType: String {
            case x, y, z
        }
    }
}
```

will expand to:
```swift
enum Remote {

    enum Value {

        @BaselineStringRemoteValue
        struct PaywallType {

            enum Variant: String {
                case a, b, c
            }
        }

        @BaselineBoolRemoteValue
        struct AFeatureEnabled { }

        @BaselineBoolRemoteValue(enabledByDefault: true)
        struct BFeatureEnabled { }

        @BoolRemoteValue
        enum CFeatureEnabled { }

        @StringRemoteValue
        enum OnboardingType: String {
            case x, y, z
        }
    }
}
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
