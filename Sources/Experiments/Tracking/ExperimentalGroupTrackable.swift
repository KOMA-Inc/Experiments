public protocol ExperimentalGroupTrackable {
    var experimentalGroupKey: String { get }
    var experimentalGroupValue: String { get }
    var shouldTrack: Bool { get }
}

public extension ExperimentalGroupTrackable where Self: RemoteValue {

    var shouldTrack: Bool {
        if let self = self as? BaselineStringRemoteValue {
            !self.baseline
        } else {
            true
        }
    }
}
