//
//  AddressCollectionDropDownCell.swift
//  LongTester
//
//  Created by Long on 5/16/23.
//

import UIKit


class AddressCollectionDropDownCell: BaseCell<AddressCollectionDropDownCellViewModel> {
//    var viewModel: AddressCollectionDropDownCellViewModel?
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var widthImageConstraint: NSLayoutConstraint!
    
    override var viewModel: AddressCollectionDropDownCellViewModel? {
        didSet {
            bindData()
        }
    }

    private func bindData() {
        imgView.image = viewModel?.image
        titleLbl.text = viewModel?.title
        widthImageConstraint.constant = viewModel?.imageHeight ?? 0
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
