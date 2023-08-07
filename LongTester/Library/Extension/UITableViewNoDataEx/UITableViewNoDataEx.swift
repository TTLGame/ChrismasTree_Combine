//
//  UITableViewNoDataEx.swift
//  LongTester
//
//  Created by Long on 5/13/23.
//

import Foundation
import UIKit
class UITableViewNoDataEx : UIView {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var textLbl: UILabel!
    init(frame: CGRect, image : UIImage?, text: String) {
        super.init(frame: frame)
        self.commonInit()
        configureData(image: image, text: text)
        
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    func commonInit(){
        loadViewFromNib()
        textLbl.textColor = Color.normalTextColor
    }
    func configureData(image : UIImage?, text: String){
        self.imgView.image = image
        self.textLbl.text = text
    }
}

