//
//  RoomDetailStatusHeaderCell.swift
//  LongTester
//
//  Created by Long on 6/14/23.
//

import UIKit

class RoomDetailStatusHeaderCell: UITableViewCell {
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.backgroundColor = .white
        
        content.backgroundColor = Color.viewDefaultColor
        bgView.layer.masksToBounds = true
        
        bgView.layer.cornerRadius = 20
    
        shadowView.layer.cornerRadius = 20
        
        shadowView.addBottomShadow(height: 3,
                                   alpha: 0.4,
                                   radius: 4)
        bgView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
