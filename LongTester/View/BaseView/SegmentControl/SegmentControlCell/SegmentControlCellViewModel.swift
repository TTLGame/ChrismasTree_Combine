//
//  SegmentControlCellViewModel.swift
//  LongTester
//
//  Created by Long on 5/25/23.
//

import Foundation
import UIKit

class SegmentControlCellViewModel {
    var title: String?
    var image : UIImage?
    init(title: String?, image : UIImage? = nil) {
        self.title = title
        self.image = image
    }
}
