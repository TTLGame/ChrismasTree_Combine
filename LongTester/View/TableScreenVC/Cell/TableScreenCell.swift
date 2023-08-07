//
//  TableScreenCell.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import UIKit

class TableScreenCell: UITableViewCell {

    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var renderColor: UIView!
    @IBOutlet weak var textLbl: UILabel!
    
    var viewModel: TableScreenCellViewModel? {
        didSet {
            bindData()
        }
    }
    
    private func bindData(){
        self.textLbl.text = viewModel?.fullName
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func renderColor(color: UIColor, pressed : Bool){
        renderColor.backgroundColor = color
        borderView.addDashedBorder(color: Color.redPrimary, radius: 10)
//            borderView.isHidden = pressed
        
    }
}
