//
//  PickerViewModel.swift
//  LongTester
//
//  Created by Long on 6/1/23.
//

import Foundation
import UIKit

class PickerViewModel {
    let title : String
    let image : UIImage?
    let id : String?
    init(title: String, image: UIImage?, id: String?) {
        self.title = title
        self.image = image
        self.id = id
    }
}
