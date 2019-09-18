import XCTest
import SnapshotTesting

class KikUITests: XCTestCase {

    override func setUp() {
        XCUIApplication().launch()
        continueAfterFailure = false
    }

    override func tearDown() {
        XCUIApplication().terminate()
    }

    func test_IfButtonsAreTappable() {
        
        KikPageObject.button1.tap()
        XCTAssert(KikPageObject.button1.label == "O")
        
        KikPageObject.button2.tap()
        XCTAssert(KikPageObject.button2.label == "X")
    }
    
    func test_CheckIfUserCannotTapButtonTwice() {
        KikPageObject.button1.tap()
        KikPageObject.button1.tap()
        assertSnapshot(matching: KikPageObject.takeScreenShot(), as: .image)
    }
    
    func test_IfUserCanWin() {
        KikPageObject.winningGame()
        assertSnapshot(matching: KikPageObject.takeScreenShot(), as: .image)
    }
    
    func test_CheckIfUserCanTie() {
        KikPageObject.tieGame()
        assertSnapshot(matching: KikPageObject.takeScreenShot(), as: .image)
    }
}
