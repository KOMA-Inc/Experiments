import Experiments

// MARK: - Old (manual) way

enum StringTest: String, CaseIterable, StringInitializableRemoteValue {
    case a, b, c

    static let `default`: Self = .b
}

enum BoolTest: CaseIterable, BoolEnumRemoteValue {
    case enabled
    case disabled
}

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

// MARK: - New (macro) way

@StringRemoteValue
enum StringTestMacro: String {
    case a, b, c
}

@BoolRemoteValue
enum BoolTestMacro { }

@BaselineStringRemoteValue
struct StringBaselineTestMacro {

    enum Variant: String {
        case a, b, c

        static let `default`: Self = .b
    }
}

@BaselineBoolRemoteValue(enabledByDefault: true)
struct BoolBaselineTestMacro { }
