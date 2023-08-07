//
//  MainScreenAddMorePopUp.swift
//  LongTester
//
//  Created by Long on 6/4/23.
//

import Foundation
import UIKit

class MainScreenAddMorePopUp : UIView {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var roomPriceTextField: UITextField!
    @IBOutlet weak var roomPriceLbl: UILabel!
    @IBOutlet weak var electricPriceTextField: UITextField!
    @IBOutlet weak var electricPriceLbl: UILabel!
    @IBOutlet weak var waterPriceTextField: UITextField!
    @IBOutlet weak var waterPriceLbl: UILabel!
    @IBOutlet weak var QuotaPriceTextField: UITextField!
    @IBOutlet weak var QuotaPriceLbl: UILabel!
    @IBOutlet weak var QuotaTextField: UITextField!
    @IBOutlet weak var QuotaLbl: UILabel!
    @IBOutlet weak var roomNumTextField: UITextField!
    @IBOutlet weak var roomNumLbl: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    private var arrTextfield : [UITextField] = []
    var viewModel = MainScreenAddMorePopUpViewModel()
//    init(frame: CGRect, baseVC : UIViewController, view : UIView) {
//        super.init(frame: frame)
//        commonInit()
//    }
//    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        loadViewFromNib()
        setup()
    }
    
    private func setupTextField(){
        for textfield in arrTextfield {
            textfield.layer.borderWidth = 2
            textfield.layer.borderColor = Color.textViewBorder.cgColor
            textfield.layer.cornerRadius = 5
            textfield.layer.masksToBounds = true
            textfield.delegate = self
            
            textfield.addTarget(self,
                                         action: #selector(MainScreenAddMorePopUp.textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    private func setup(){
        arrTextfield = [roomPriceTextField,electricPriceTextField,waterPriceTextField,QuotaTextField,roomNumTextField,nameTextField,QuotaPriceTextField]
        
        setupTextField()
        
        roomPriceLbl.text = Language.localized("roomPrice") + "(*)"
        electricPriceLbl.text = Language.localized("electricPrice") + "(*)"
        waterPriceLbl.text = Language.localized("waterPrice") + "(*)"
        QuotaPriceLbl.text = Language.localized("quotaPrice")
        QuotaLbl.text = Language.localized("quota")
        roomNumLbl.text = Language.localized("totalRoomPopUp") + "(*)"
        addressLbl.text = Language.localized("addressPopup") + "(*)"
        titleLbl.text = Language.localized("popupCreateAddressTitle")
        nameTitle.text = Language.localized("addressName")
        
        roomPriceTextField.text = " VND"
        electricPriceTextField.text = " VND"
        waterPriceTextField.text = " VND"
        QuotaPriceTextField.text = " VND"
        
        addressTextView.delegate = self
        addressTextView.layer.cornerRadius = 5
        addressTextView.layer.borderColor = Color.viewDefaultColor.cgColor
        addressTextView.layer.borderWidth = 2
        addressTextView.layer.masksToBounds = true
    }
    
    func returnViewModel() -> MainScreenAddMorePopUpViewModel? {
        return viewModel.checkValidation() ? viewModel : nil
    }
}

extension MainScreenAddMorePopUp : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2
        textField.layer.borderColor = Color.selectedTextView.cgColor
        
        if (textField == QuotaTextField || textField == roomNumTextField){
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let newPosition = textField.position(from: textField.endOfDocument, offset: -4) {
                
                // set the new position
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2
        textField.layer.borderColor = Color.textViewBorder.cgColor
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField == QuotaTextField ||
            textField == roomNumTextField ||
            textField == nameTextField){
            updateViewModelTextField(textField: textField, text: textField.text ?? "")
            return
        }
        guard let text = textField.text else { return }
        var curentPos = 0
        if let selectedRange = textField.selectedTextRange {
            let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            
            if (cursorPosition > text.count - 4 ) {
                let val = getLastNumber(textField: textField)
                textField.text = (val.formatnumberWithDot()) + " VND"
                if let newPosition = textField.position(from: textField.endOfDocument, offset: -4) {
                    // set the new position
                    textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                }
                return
            }
            else {
                curentPos = ((textField.text?.count ?? 0) - cursorPosition) * -1
            }
        }
        var newText = text.replacingOccurrences(of: " VND", with: "")
        newText = newText.replacingOccurrences(of: ".", with: "")
        
        updateViewModelTextField(textField: textField, text: newText)
        
        //Convert number when data hit 0 VND, because if we input number, the number 0 is not disapear, so we must convert to Int and then convert back to String to kil the number 0
        if newText.isEmpty {
            textField.text = "0 VND"
        }
        else {
            let val = Int(newText) ?? 0
            textField.text = val.formatnumberWithDot() + " VND"
        }
        
        if let newPosition = textField.position(from: textField.endOfDocument, offset: curentPos) {
            // set the new position
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
    
    private func updateViewModelTextField(textField: UITextField, text: String){
        switch textField {
        case QuotaPriceTextField:
            viewModel.inputQuotaPrice = Int(text) ?? 0
        case waterPriceTextField:
            viewModel.inputWater = Int(text) ?? 0
        case electricPriceTextField:
            viewModel.inputElectric = Int(text) ?? 0
        case roomPriceTextField:
            viewModel.inputRoomPrice = Int(text) ?? 0
        case roomNumTextField :
            viewModel.inputRooms = Int(text) ?? 0
        case QuotaTextField:
            viewModel.inputQuota = Int(text) ?? 0
        case nameTextField:
            viewModel.inputName = text
        default:
            break
        }
    }
    
    private func getLastNumber(textField: UITextField) -> Int{
        switch textField {
        case QuotaTextField:
            return viewModel.inputQuotaPrice
        case waterPriceTextField:
            return viewModel.inputWater
        case electricPriceTextField:
            return viewModel.inputElectric
        case roomPriceTextField:
            return viewModel.inputRoomPrice
            
        default:
            return 0
        }
    }
}

extension MainScreenAddMorePopUp : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 2
        textView.layer.borderColor = Color.selectedTextView.cgColor
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 2
        textView.layer.borderColor = Color.textViewBorder.cgColor
    }
    func textViewDidChange(_ textView: UITextView) {
        viewModel.inputAddress = textView.text
    }
}
