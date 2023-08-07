//
//  AddressCollectionDropDownCellViewModel.swift
//  LongTester
//
//  Created by Long on 5/16/23.
//

import Foundation
import UIKit
class AddressCollectionDropDownCellViewModel : BaseDropDownCellViewModel {
    var image : UIImage?
    var imageHeight : CGFloat?
    init(image: UIImage?, title: String?, imageHeight : CGFloat? = 20) {
        super.init(title: title)
        self.image = image
        self.imageHeight = imageHeight
    }
}
