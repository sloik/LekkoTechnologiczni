import XCTest
import SnapshotTesting

class KikUITests: XCTestCase {
    
    //Test recorded on iphone 8+
    
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        app.launchArguments = ["--DisableAnimations"]
        app.launch()
        continueAfterFailure = false
        
        record = true
    }

    override func tearDown() {
        XCUIApplication().terminate()
        super.tearDown()
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
