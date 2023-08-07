//
//  BaseNavigationView.swift
//  LongTester
//
//  Created by Long on 4/14/23.
//

import Foundation
import UIKit
import SnapKit

extension UINavigationBar {
    public func setColors(background: UIColor, text: UIColor) {
        isTranslucent = false
        backgroundColor = background
        barTintColor = background
//        setBackgroundImage(UIImage(), for: .default)
        tintColor = text
        titleTextAttributes = [.foregroundColor: text]
    }
}

class BaseNavigationView: UINavigationController {
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initLabel()
        setUp()
    }
    
    fileprivate func setUp(){
        navigationBar.tintColor = Color.redPrimary
        let titleTextColor: UIColor = Color.redPrimary
        self.navigationBar.titleTextAttributes = [
            .foregroundColor: titleTextColor,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
    }
    
    func initLabel(){
        self.navigationBar.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
    }
    func setTitle(title: String, color : UIColor = Color.redPrimary){
        navigationBar.topItem?.title = ""
        navigationBar.tintColor = color
        self.navigationBar.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        let attribute = [
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)
        ]
        label.attributedText =  NSAttributedString(string: title,
                                                   attributes: attribute)
        
        
    }
    
    func setupBackTitle(){

        if self.viewControllers.count <= 1 {
            navigationBar.topItem?.title = ""
        }
    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        if self.viewControllers.count > 1 {
            let backBarButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: #selector(BaseNavigationView.back(sender:)))
            viewController.navigationItem.backBarButtonItem = backBarButton
        }
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        _ = navigationController?.popViewController(animated: true)
    }
    
}
