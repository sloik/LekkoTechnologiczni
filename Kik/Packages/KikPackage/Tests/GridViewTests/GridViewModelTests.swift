import Foundation

import XCTest
@testable import GridView

final class GridViewModelTests: XCTestCase {

    func test_runAction_shouldCall_correctAction() {
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

        let actions = GridActions(
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

        let sut = GridViewModel(
            actions: actions,
            titleForElement: { _ in "No title" }
        )

        // Act & Assert
        sut.runAction(0)
        wait(for: [action0WasCalled], timeout: 0.1)

        sut.runAction(1)
        wait(for: [action1WasCalled], timeout: 0.1)

        sut.runAction(2)
        wait(for: [action2WasCalled], timeout: 0.1)


        sut.runAction(3)
        wait(for: [action3WasCalled], timeout: 0.1)

        sut.runAction(4)
        wait(for: [action4WasCalled], timeout: 0.1)

        sut.runAction(5)
        wait(for: [action5WasCalled], timeout: 0.1)


        sut.runAction(6)
        wait(for: [action6WasCalled], timeout: 0.1)

        sut.runAction(7)
        wait(for: [action7WasCalled], timeout: 0.1)

        sut.runAction(8)
        wait(for: [action8WasCalled], timeout: 0.1)
    }
}
