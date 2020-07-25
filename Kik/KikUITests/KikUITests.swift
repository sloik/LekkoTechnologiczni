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

        SnapshotTesting.record = false
    }

    override func tearDown() {
        XCUIApplication().terminate()
        super.tearDown()
    }

    func test_fail() {
        assertSnapshot(
            matching: takeScreenShot(),
            as: .image
        )

        XCTFail()
    }
}


func takeScreenShot() -> UIImage {
    XCUIApplication()
        .windows
        .firstMatch
        .screenshot()
        .image
        .removingStatusBar
        ?? UIImage()
}

extension UIImage {
    var removingStatusBar: UIImage? {
        guard let cgImage = cgImage else {
            return nil
        }

        let yOffset = 40 * scale // status bar height on standard devices (not iPhoneX)
        let rect = CGRect(
            x: 0,
            y: Int(yOffset),
            width: cgImage.width,
            height: cgImage.height - Int(yOffset)
        )

        if let croppedCGImage = cgImage.cropping(to: rect) {
            return UIImage(cgImage: croppedCGImage, scale: scale, orientation: imageOrientation)
        }

        return nil
    }
}

