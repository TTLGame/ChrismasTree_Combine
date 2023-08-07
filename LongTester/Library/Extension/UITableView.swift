//
//  UITableView.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation
import UIKit
import SnapKit

extension UITableView {
    func dequeueCell<T: UITableViewCell>(_ withClass: T.Type, indexPath: IndexPath) -> T {
        let className = String(describing: withClass)
        guard let cell = dequeueReusableCell(withIdentifier: className, for: indexPath) as? T else {
            fatalError("\(className) isn't register")
        }
        return cell
    }

    func dequeueCell<T: UITableViewCell>(_ withClass: T.Type) -> T {
        let className = String(describing: withClass)
        guard let cell = dequeueReusableCell(withIdentifier: className) as? T else {
            fatalError("\(className) isn't register")
        }
        return cell
    }
}

extension UITableView {
    func setEmptyData(message: String = Language.localized("noData"), _ image: UIImage? = UIImage(named: "NoData")) {
        let noDataView = UITableViewNoDataEx(frame: self.frame, image: image, text: message)
        self.backgroundView = noDataView
        self.separatorStyle = .none
    }
    
    func restoreNewProduct() {
        self.backgroundView = nil
        self.separatorStyle = .none
    }
}
