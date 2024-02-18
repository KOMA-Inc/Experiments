import XCTest

@testable import Experiments

class BaselineBoolRemoteValueTests: XCTestCase {

    @BaselineBoolRemoteValue
    struct RemoteValue { }

    func testRemoteValueIsBaselineTrue() {
        let remoteValue = RemoteValue(name: "true_baseline")!
        XCTAssertTrue(remoteValue.baseline)
        XCTAssertTrue(remoteValue.isEnabled)
    }

    func testRemoteValueIsNotBaselineTrue() {
        let remoteValue = RemoteValue(name: "true")!
        XCTAssertFalse(remoteValue.baseline)
        XCTAssertTrue(remoteValue.isEnabled)
    }

    func testRemoteValueIsBaselineFalse() {
        let remoteValue = RemoteValue(name: "false_baseline")!
        XCTAssertTrue(remoteValue.baseline)
        XCTAssertFalse(remoteValue.isEnabled)
    }

    func testRemoteValueIsNotBaselineFalse() {
        let remoteValue = RemoteValue(name: "false")!
        XCTAssertFalse(remoteValue.baseline)
        XCTAssertFalse(remoteValue.isEnabled)
    }

    func testRemoteValueIsIncorrect() {
        let remoteValue = RemoteValue(name: "enabled")
        XCTAssertNil(remoteValue)
    }
}
