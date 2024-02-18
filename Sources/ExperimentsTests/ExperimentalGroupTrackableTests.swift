import XCTest

@testable import Experiments

class ExperimentalGroupTrackableTests: XCTestCase {

    @BaselineStringRemoteValue
    struct RemoteStringValue: ExperimentalGroupTrackable {

        enum Variant: String {
            case a, b, c
        }

        var experimentalGroupKey: String { "" }

        var experimentalGroupValue: String { "" }
    }

    @BaselineBoolRemoteValue
    struct RemoteBoolValue: ExperimentalGroupTrackable {

        var experimentalGroupKey: String { "" }

        var experimentalGroupValue: String { "" }
    }

    func testRemoteValueIsBaseline() {
        let remoteStringValue = RemoteStringValue(name: "a_baseline")!
        let remoteBoolValue = RemoteBoolValue(name: "true_baseline")!
        XCTAssertFalse(remoteStringValue.shouldTrack)
        XCTAssertFalse(remoteBoolValue.shouldTrack)
    }

    func testRemoteValueIsNotBaseline() {
        let remoteStringValue = RemoteStringValue(name: "a")!
        let remoteBoolValue = RemoteBoolValue(name: "true")!
        XCTAssertTrue(remoteStringValue.shouldTrack)
        XCTAssertTrue(remoteBoolValue.shouldTrack)
    }
}
