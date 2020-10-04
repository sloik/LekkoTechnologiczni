import UIKit
import Flutter

class KikFlutterViewController: FlutterViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let helloChannell = FlutterMethodChannel(name: "KikMethodChannel", binaryMessenger: self.binaryMessenger)
        
        helloChannell.setMethodCallHandler({
           [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch(call.method){
            case "printHello":
                return self!._handleKikMethodChannel(result: result)
            default:
                break;
            }
        })
        
    }
    
    func _handleKikMethodChannel(result: FlutterResult){
        result("SZCZĘŚĆ BOŻĘ")
    }
}
