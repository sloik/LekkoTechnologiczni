import Foundation
import XCTest

public struct KikPageObject {
    
    public static let button1 = XCUIApplication().buttons["0"]
    public static let button2 = XCUIApplication().buttons.matching(identifier: "1").firstMatch
    public static let button3 = XCUIApplication().buttons.matching(identifier: "2").firstMatch
    public static let button4 = XCUIApplication().buttons.matching(identifier: "3").firstMatch
    public static let button5 = XCUIApplication().buttons.matching(identifier: "4").firstMatch
    public static let button6 = XCUIApplication().buttons.matching(identifier: "5").firstMatch
    public static let button7 = XCUIApplication().buttons.matching(identifier: "6").firstMatch
    public static let button8 = XCUIApplication().buttons.matching(identifier: "7").firstMatch
    public static let button9 = XCUIApplication().buttons.matching(identifier: "8").firstMatch
    
    public static func winningGame() {
        KikPageObject.button1.tap()
        KikPageObject.button2.tap()
        KikPageObject.button5.tap()
        KikPageObject.button8.tap()
        KikPageObject.button9.tap()
    }
    
    public static func drawGame() {
        KikPageObject.button1.tap()
        KikPageObject.button2.tap()
        KikPageObject.button4.tap()
        KikPageObject.button5.tap()
        KikPageObject.button8.tap()
        KikPageObject.button7.tap()
        KikPageObject.button3.tap()
        KikPageObject.button6.tap()
        KikPageObject.button9.tap()
    }
    
    public static func takeScreenShot() -> UIImage {
        guard let screenshot = XCUIApplication().windows.firstMatch.screenshot().image.removingStatusBar else { return UIImage() }
        return screenshot
    }
    
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
