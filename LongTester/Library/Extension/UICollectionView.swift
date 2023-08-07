//
//  UICollectionView.swift
//  LongTester
//
//  Created by Long on 5/13/23.
//

import Foundation
import UIKit
extension UICollectionView {
    func setEmptyData(message: String = Language.localized("noData"), _ image: UIImage? = UIImage(named: "NoData")) {
        let noDataView = UITableViewNoDataEx(frame: self.frame, image: image, text: message)
        self.backgroundView = noDataView
    }
    
    func restoreNewProduct() {
        self.backgroundView = nil
    }
}
