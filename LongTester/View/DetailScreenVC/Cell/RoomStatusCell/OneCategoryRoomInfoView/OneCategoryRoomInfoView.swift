//
//  OneCategoryRoomInfoView.swift
//  LongTester
//
//  Created by Long on 6/14/23.
//

import Foundation
import UIKit

class OneCategoryRoomInfoView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        loadViewFromNib()
    }
}
