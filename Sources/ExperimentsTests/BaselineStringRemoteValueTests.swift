import XCTest

@testable import Experiments

class BaselineStringRemoteValueTests: XCTestCase {

    @BaselineStringRemoteValue
    struct RemoteValue {

        enum Variant: String {
            case a, b = "b_var"
        }
    }

    func testRemoteValueIsBaselineA() {
        let remoteValue = RemoteValue(name: "a_baseline")!
        XCTAssertTrue(remoteValue.baseline)
        XCTAssertEqual(remoteValue.variant, .a)
    }

    func testRemoteValueIsNotBaselineA() {
        let remoteValue = RemoteValue(name: "a")!
        XCTAssertFalse(remoteValue.baseline)
        XCTAssertEqual(remoteValue.variant, .a)
    }

    func testRemoteValueIsBaselineB() {
        let remoteValue = RemoteValue(name: "b_var_baseline")!
        XCTAssertTrue(remoteValue.baseline)
        XCTAssertEqual(remoteValue.variant, .b)
    }

    func testRemoteValueIsNotBaselineB() {
        let remoteValue = RemoteValue(name: "b_var")!
        XCTAssertFalse(remoteValue.baseline)
        XCTAssertEqual(remoteValue.variant, .b)
    }

    func testRemoteValueIsIncorrect() {
        let remoteValue = RemoteValue(name: "c")
        XCTAssertNil(remoteValue)
    }
}
