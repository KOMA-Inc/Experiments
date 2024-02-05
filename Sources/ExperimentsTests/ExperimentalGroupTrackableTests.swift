import XCTest

@testable import Experiments

class ExperimentalGroupTrackableTests: XCTestCase {

    @BaselineRemoteValue
    struct RemoteValue: ExperimentalGroupTrackable {

        enum Variant: String {
            case a, b, c
        }

        var experimentalGroupKey: String { "" }

        var experimentalGroupValue: String { "" }
    }

    func testRemoteValueIsBaseline() {
        let remoteValue = RemoteValue(name: "a_baseline")!
        XCTAssertFalse(remoteValue.shouldTrack)
    }

    func testRemoteValueIsNotBaseline() {
        let remoteValue = RemoteValue(name: "a")!
        XCTAssertTrue(remoteValue.shouldTrack)
    }
}
