import XCTest
@testable import Kik

class KikViewModelTests: XCTestCase {

    var sut: KikViewModel!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_symbolToStringShouldConvert() {
        // arrange
        let input: [Symbol] = Symbol.allCases
        sut = KikViewModel(model: kikMock(model: input))
        // act
        let result: [String] = input.map(sut.string(for:))

        // assert
        XCTAssertEqual(result, ["X", "O", "-"])
    }
}




