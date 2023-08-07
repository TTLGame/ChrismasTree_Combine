//
//  SlideMenuViewCell.swift
//  LongTester
//
//  Created by Long on 4/19/23.
//

import UIKit

class SlideMenuViewCell: UITableViewCell {

    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        self.iconImageView.tintColor = Color.normalTextColor
        self.textLbl.textColor = Color.normalTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
