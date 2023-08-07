//
//  AppDelegate.swift
//  LongTester
//
//  Created by Long on 12/28/22.
//

import UIKit
import IQKeyboardManagerSwift
import OHHTTPStubs
import FLEX
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var rootViewController: RootViewController {
        guard let rootViewController = window?.rootViewController as? RootViewController else {
            fatalError("Cannot cast the RootViewController")
        }
        return rootViewController
    }
    
    static let shared: AppDelegate = {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Cannot cast the AppDelegate")
        }
        return delegate
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        configIQKeyboard()
//        configStubData()
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate {
    func configIQKeyboard() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 60
    }
    
    func configStubData() {
        let baseURl = "reqres.in"
        stub(condition: isHost("\(baseURl)") &&  isPath("/api/getaddress")) { _ in

          let stubPath = OHPathForFile("wsresponse.json", type(of: self))
//          return fixture(JSONObject: stubPath!, headers: ["Content-Type":"application/json"])
            let obj = ["key1":"value1", "key2":"123"]
            return HTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
        }
    }
}
