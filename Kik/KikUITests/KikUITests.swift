import XCTest
import SnapshotTesting

class KikUITests: XCTestCase {

    let application = XCUIApplication()

    override func setUp() {
        application.launch()
        continueAfterFailure = false
    }

    override func tearDown() {
        application.terminate()
    }

    func test_checkIfButtonIsTappable() {
        KikPageObject.button1.tap()
        XCTAssert(KikPageObject.button1.label == "O", "Button was not tapped")
        
        KikPageObject.button2.tap()
        XCTAssert(KikPageObject.button2.label == "X", "Wrong symbol appeared")
    }
    
    func test_chceckIfUserCannotTapOneButtonTwice() {
        KikPageObject.button1.tap()
        KikPageObject.button1.tap()
        assertSnapshot(matching: KikPageObject.takeScreenShot(), as: .image)
    }
    
    func test_chcekIfUserCanWin() {
        KikPageObject.winningGame()
        assertSnapshot(matching: KikPageObject.takeScreenShot(), as: .image)
    }
    
    func test_checkIfUsersCanTie() {
        KikPageObject.drawGame()
        assertSnapshot(matching: KikPageObject.takeScreenShot(), as: .image)
    }
}
