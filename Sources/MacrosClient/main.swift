import Experiments

@StringRemoteValue
enum StringTest: String {
    case a, b, c
}

@BoolRemoteValue
enum BoolTest1 { }

@BoolRemoteValue
enum BoolTest2 { 
    static let `default`: Self = .enabled
}

@BoolRemoteValue(enabledByDefault: true)
enum BoolTest3 { }

@BoolRemoteValue(enabledByDefault: true)
enum BoolTest4 {
    static let `default`: Self = .enabled
}
