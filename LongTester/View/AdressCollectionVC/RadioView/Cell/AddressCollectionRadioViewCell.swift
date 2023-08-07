//
//  AddressCollectionRadioViewCell.swift
//  LongTester
//
//  Created by Long on 5/16/23.
//

import UIKit

class AddressCollectionRadioViewCell: UICollectionViewCell {

    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var backGroundView: UIView!
    
    
    var viewModel: AddressCollectionRadioViewCellViewModel? {
        didSet {
            bindData()
        }
    }
    
    private func bindData(){
        textLbl.text = viewModel?.title
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        // Initialization code
    }
    
    private func setup(){
        backGroundView.layer.cornerRadius = 10
    }
    func selectingOption(didSelect: Bool){
        didSelect ? seletingView() : deselectView()
    }
    func deselectView() {
        backGroundView.backgroundColor = .white
        textLbl.textColor = Color.greyPrimary
    }
    
    func seletingView() {
        backGroundView.backgroundColor = Color.redPrimary
        textLbl.textColor = UIColor.white
    }
}
