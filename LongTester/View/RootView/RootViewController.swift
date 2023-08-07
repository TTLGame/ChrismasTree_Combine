import UIKit
import SnapKit

final class RootViewController: BaseViewController {
    var currentVC: UIViewController!
    enum ScreenType {
        /// Main way to access Root View Controller
        case main
        case tableView
        case login
    }
    
    init() {
        super.init()
        setupData()
        currentVC = LoginViewController()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupData(){
        let newQuery = ["id" : "-1"]
        if let appConfigData = StoreManager.shared.find(AppConfigModel.self, queryParts: newQuery, in: .appConfig) {
            print("appConfigData \(appConfigData)")
            if let language = appConfigData.first?.language {
                AppConfig.shared.language = Language(rawValue: language) ?? .vietnamese
            }
            else {
                addLanguage()
            }
        }
    }
    
    func addLanguage(){
        let data = AppConfigModel()
        data.language = AppConfig.shared.language.rawValue
        guard var tmpJson = data.json() else { return }
        tmpJson["id"] = "-1"
        do {
            try StoreManager.shared.save(data: tmpJson, in: .appConfig)
        } catch {
            print(error.localizedDescription)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(currentVC)
        if #available(iOS 13.0, *) {
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        } else {
            // Fallback on earlier versions
        }
        view.addSubview(currentVC.view)
        currentVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        currentVC.didMove(toParent: self)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
                self.view.frame.origin.y += 90
                
            }
        }
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func show(_ type: ScreenType) {
        var rootViewController: UIViewController
        switch type {
        case .main:
            rootViewController = BaseNavigationView(rootViewController: MainScreenViewController())
            update(current: rootViewController)
        case .tableView:
            rootViewController = TableScreenViewController()
            update(current: rootViewController)
        case .login:
            
            rootViewController = BaseNavigationView(rootViewController: LoginViewController())
            update(current: rootViewController)
        }
        
        
    }
}

// Private func
extension RootViewController {
    private func update(current viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        viewController.didMove(toParent: self)
        
        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()
        currentVC = viewController
        currentVC.setNeedsStatusBarAppearanceUpdate()
        addChild(currentVC)
    }
}
