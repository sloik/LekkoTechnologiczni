
import XCTest
@testable import GridView
import SnapshotTesting
import Prelude

final class GridViewSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        SnapshotTesting.record = false
    }

    override func tearDown() {
        super.tearDown()
    }

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

    func test_forNoneViewModel_buttonTitlesAreIndexes() {

        let vc = UIStoryboard(
            name: "Grid",
            bundle: .module)
            .instantiateInitialViewController()!

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

        let iPhoneXDarkMode: ViewImageConfig =  {
            var config = ViewImageConfig.iPhoneX(.landscape)

            config.traits = .init(traitsFrom: [darkMode, .iPhoneX(.landscape)])

            return config
        }()

        assertSnapshot(
            matching: vc,
            as: .image(
                on:    iPhoneXDarkMode
            ),
            named: "iPhoneX-landscape-darkMode"
        )
    }
}

let noActionViewModel: GridViewModel =
    .gridVisible(
        action: { _ in
            
        },
        title: { index in
            "Title for \(index |> toIntIndex)"
        }
    )

let darkMode: UITraitCollection = .init(userInterfaceStyle: .dark)
