import XCTest
@testable import Kik

class KikBaseViewControllerTests: XCTest {
    
    var sut: KikBaseViewController!
    var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupKikBaseVC()
    }

    override func tearDown() {
        window = nil
        super.tearDown()
    }
    
    private func setupKikBaseVC() {
        let bundle =  Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        sut = storyboard.instantiateViewController(identifier: "KikBaseViewController") as! KikBaseViewController
    }
    
    private func viewDidLoad() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }
    

}
