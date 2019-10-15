
import XCTest
@testable import Kik

class KikViewModelTests: XCTestCase {
    
    var sut: KikViewModel!
    
    override func setUp() {
        super.setUp()
        sut = KikViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }


    func test_gridProperty_ShouldSetAppripriateValue(){
     //act
        sut.didTapElement(0)
        sut.didTapElement(1)
        sut.didTapElement(2)
        
      //assert
        XCTAssertEqual(sut.grid, "O X O\n- - -\n- - -")
    }
}

