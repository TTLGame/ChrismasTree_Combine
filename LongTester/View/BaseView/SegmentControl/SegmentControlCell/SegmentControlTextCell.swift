//
//  SegmentControlTextCell.swift
//  LongTester
//
//  Created by Long on 5/25/23.
//

import UIKit

class SegmentControlTextCell: UICollectionViewCell {

    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var textLbl: UILabel!
    
    private var selectedTextColor : UIColor!
    private var textColor : UIColor!
    
    var viewModel : SegmentControlCellViewModel? {
        didSet {
            bindData()
        }
    }
    
    private func bindData(){
        self.textLbl.text = viewModel?.title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setColor(selectedTextColor : UIColor, textColor : UIColor){
        self.selectedTextColor = selectedTextColor
        self.textColor = textColor
    }
    
    func selectingOption(didSelect: Bool){
        didSelect ? seletingView() : deselectView()
    }
    func deselectView() {
//        backGroundView.backgroundColor = .white
        UIView.animate(withDuration: 0.1) {
            self.textLbl.textColor = self.textColor
            self.layoutIfNeeded()
        } completion: { _ in }
        
       
    }
    
    func seletingView() {
//        backGroundView.backgroundColor = Color.redPrimary
        UIView.animate(withDuration: 0.1) {
            self.textLbl.textColor = self.selectedTextColor
            self.layoutIfNeeded()
        } completion: { _ in }
    }

}
