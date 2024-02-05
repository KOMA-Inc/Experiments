import Experiments

enum RemoteValue {

    case enabled

    case disabled

    var rawValue: Int {
        switch self {
        case .enabled:
            1
        case .disabled:
            0
        }
    }
}

extension RemoteValue: CaseIterable, BoolRemoteValue {
}

enum TestEnabled {}
