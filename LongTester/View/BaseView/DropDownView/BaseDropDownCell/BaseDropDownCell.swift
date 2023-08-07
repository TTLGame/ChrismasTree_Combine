//
//  BaseDropDownCell.swift
//  LongTester
//
//  Created by Long on 5/17/23.
//

import UIKit

class BaseCell<U>: UITableViewCell {
    var viewModel: U?
}

class BaseDropDownCell : BaseCell<BaseDropDownCellViewModel> {
    override var viewModel : BaseDropDownCellViewModel? {
        didSet {
            bindData()
        }
    }

    @IBOutlet weak var titleLbl: UILabel!
    
    private func bindData() {
        if let titleLbl = titleLbl {
            titleLbl.text = self.viewModel?.title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
