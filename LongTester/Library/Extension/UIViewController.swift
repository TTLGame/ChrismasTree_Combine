//
//  UIViewController.swift
//  LongTester
//
//  Created by Long on 4/19/23.
//

import Foundation
import UIKit

extension UIViewController {
    func pushNavigationView(_ viewController: UIViewController, _ title : String){
        let viewController = viewController
        let navigationController = (navigationController as? BaseNavigationView)
        //        navigationController?.setTitle(title: title)
        navigationController?.setupBackTitle()
        viewController.title = title
        navigationController?.pushViewController(viewController, animated: true)
    }
}

