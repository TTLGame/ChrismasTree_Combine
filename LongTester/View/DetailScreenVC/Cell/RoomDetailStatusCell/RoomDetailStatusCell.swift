//
//  RoomDetailStatusCell.swift
//  LongTester
//
//  Created by Long on 6/14/23.
//

import UIKit

class RoomDetailStatusCell: UITableViewCell {
    enum CornerType {
        case down
        case up
    }
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rentersShadowView: UIView!
    @IBOutlet weak var rentersView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    
    func setupCorner(type : CornerType){
        bgView.backgroundColor = .white
        bgView.layer.masksToBounds = true
        
        bgView.layer.cornerRadius = type == .down ?
        20 : 30
        
        bottomConstraint.constant = type == .down ?
        10 : 0
        topConstraint.constant = type == .down ?
        0 : 10
        
        shadowView.layer.cornerRadius = type == .down ?
        20 : 30
        
        shadowView.addBottomShadow(height: type == .down ? 3 : 0,
                                   alpha: 0.4,
                                   radius: 4)
        bgView.layer.maskedCorners = type == .down ?
        [.layerMaxXMaxYCorner, .layerMinXMaxYCorner] :
        [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    private func setup(){
        mainView.backgroundColor = Color.viewDefaultColor
        shadowView.addBottomShadow(height: 0, alpha: 0.4,radius: 4)
        shadowView.layer.masksToBounds = false
        shadowView.backgroundColor = .white
        
        rentersShadowView.addBottomShadow(height: 3, alpha: 0.7,radius: 4)
        rentersShadowView.layer.cornerRadius = 10
        
        rentersView.layer.cornerRadius = 10
        rentersView.layer.masksToBounds = true
        

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
