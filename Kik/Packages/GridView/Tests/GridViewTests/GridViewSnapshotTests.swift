
import XCTest
@testable import GridView
import SnapshotTesting

final class GridViewSnapshotTests: XCTestCase {
    func test_viewIsLayoutIn3by3Grid() {
        let vc = gridViewController(noActionViewModel)

        assertSnapshot(
            matching: vc,
            as: .image(
                on: .iPhoneX(.portrait)
            ),
            named: "iPhoneX-portrait"
        )

        assertSnapshot(
            matching: vc,
            as: .image(
                on: .iPhoneX(.landscape)
            ),
            named: "iPhoneX-landscape"
        )
    }
}

let noActionViewModel: GridViewModel = gridViewModel(Array(repeating: nop, count: 9)).right!
