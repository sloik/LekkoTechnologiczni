
import Foundation

import XCTest
@testable import GridView

final class GridActionsTests: XCTestCase {

    func test_actionForIndex_shouldCall_correctAction() {
        // Arrange
        let action0WasCalled = expectationForAction(0)
        let action1WasCalled = expectationForAction(1)
        let action2WasCalled = expectationForAction(2)
        let action3WasCalled = expectationForAction(3)
        let action4WasCalled = expectationForAction(4)
        let action5WasCalled = expectationForAction(5)
        let action6WasCalled = expectationForAction(6)
        let action7WasCalled = expectationForAction(7)
        let action8WasCalled = expectationForAction(8)

        let sut = GridActions(
            action0: action0WasCalled.fulfill,
            action1: action1WasCalled.fulfill,
            action2: action2WasCalled.fulfill,
            action3: action3WasCalled.fulfill,
            action4: action4WasCalled.fulfill,
            action5: action5WasCalled.fulfill,
            action6: action6WasCalled.fulfill,
            action7: action7WasCalled.fulfill,
            action8: action8WasCalled.fulfill
        )

        // Act & Assert
        sut.actionFor(index: .bi0)()
        wait(for: [action0WasCalled], timeout: 0.1)

        sut.actionFor(index: .bi1)()
        wait(for: [action1WasCalled], timeout: 0.1)

        sut.actionFor(index: .bi2)()
        wait(for: [action2WasCalled], timeout: 0.1)


        sut.actionFor(index: .bi3)()
        wait(for: [action3WasCalled], timeout: 0.1)

        sut.actionFor(index: .bi4)()
        wait(for: [action4WasCalled], timeout: 0.1)

        sut.actionFor(index: .bi5)()
        wait(for: [action5WasCalled], timeout: 0.1)


        sut.actionFor(index: .bi6)()
        wait(for: [action6WasCalled], timeout: 0.1)

        sut.actionFor(index: .bi7)()
        wait(for: [action7WasCalled], timeout: 0.1)

        sut.actionFor(index: .bi8)()
        wait(for: [action8WasCalled], timeout: 0.1)
    }

}

func expectationForAction(_ index: Int) -> XCTestExpectation {
    let exp: XCTestExpectation = XCTestExpectation(description: "Action \(index) was called")
    exp.expectedFulfillmentCount = 1
    exp.assertForOverFulfill = true

    return exp
}
