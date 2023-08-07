//
//  AddressInfoViewCell.swift
//  LongTester
//
//  Created by Long on 5/19/23.
//

import UIKit

class AddressInfoViewCell: UITableViewCell {

    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    var viewModel : AddressInfoViewCellViewModel? {
        didSet {
            bindData()
        }
    }
    
    private func bindData() {
        self.valueLbl.text = viewModel?.value
        self.titleLbl.text = viewModel?.title
        
        if let shouldHighlightValue = viewModel?.shouldHighlightValue, shouldHighlightValue{
            self.valueLbl.font = UIFont.boldSystemFont(ofSize: 14.0)
        }
        else {
            self.valueLbl.font = UIFont.systemFont(ofSize: 14.0)
        }
        
        if let shouldHighlightTitle = viewModel?.shouldHighlightTitle, shouldHighlightTitle{
            self.titleLbl.font = UIFont.boldSystemFont(ofSize: 14.0)
        }
        else {
            self.titleLbl.font = UIFont.systemFont(ofSize: 14.0)
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
