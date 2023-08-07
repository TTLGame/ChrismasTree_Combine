//
//  PickerView.swift
//  LongTester
//
//  Created by Long on 6/1/23.
//

import Foundation
import UIKit
import SnapKit

class PickerView: UIPickerView  {
    enum PickerType {
        case withImage
        case withoutImage
    }
    private var cellViewModels = [PickerViewModel]()
    private var currentIndex = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    var cellHeight : CGFloat = 50 {
        didSet{
            self.reloadAllComponents()
        }
    }
    
    var pickerType : PickerType = .withImage {
        didSet{
            self.reloadAllComponents()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getCurrentIndex() -> Int {
        return currentIndex
    }
    func setCellViewModel(viewModel: [PickerViewModel]) {
        self.cellViewModels = viewModel
        self.reloadAllComponents()
    }
    
    func selectedIndex(index: Int) {
        self.currentIndex = index
    }
    
    internal func hide() {
        self.removeFromSuperview()
        self.isHidden = true
    }
    
    func commonSetup() {
        self.delegate = self
        self.dataSource = self
        
        selectIndex(index: self.currentIndex)
    }
    
    private func selectIndex(index: Int) {
        selectRow(index, inComponent: 0, animated: false)
    }
}

extension PickerView : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return cellViewModels[row].title
//    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
       return cellHeight
   }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        var myView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width - 50, height: cellHeight))

        switch self.pickerType {
        case .withImage :
//            var myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            var myImageView = UIImageView()
            
            myImageView.image = cellViewModels[row].image
//            let myLabel = UILabel(frame: CGRectMake(60, 0, pickerView.bounds.width - 90, 60 ))
            let myLabel = UILabel()
            myLabel.font = UIFont.systemFont(ofSize: 14)
            myLabel.text = cellViewModels[row].title

            myView.addSubview(myLabel)
            myView.addSubview(myImageView)
            
            myImageView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().offset(20)
                make.width.height.equalTo(cellHeight - 10)
            }
            
            myLabel.snp.makeConstraints { make in
                make.left.equalTo(myImageView.snp.right).offset(10)
                make.centerY.equalToSuperview()
            }
        case .withoutImage :
            let myLabel = UILabel()
            myLabel.font = UIFont.systemFont(ofSize: 14)
            myLabel.text = cellViewModels[row].title
            
            myView.addSubview(myLabel)
            myLabel.snp.makeConstraints { make in
                make.centerY.centerX.equalToSuperview()
            }
        }
     

        return myView
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cellViewModels.count
    }
    
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) ->  NSAttributedString? {
//        NSAttributedString(
//            string: titleLbl.text ?? "",
//            attributes: [NSAttributedString.Key.foregroundColor: Color.greyPrimary]
//        )
//    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectIndex(index: row)
        self.currentIndex = row
    }
}
 
