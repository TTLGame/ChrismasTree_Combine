//
//  TextFieldMoneyView.swift
//  LongTester
//
//  Created by Long on 6/12/23.
//

import Foundation
import UIKit
protocol TextFieldMoneyViewDelegate : AnyObject {
    func textFieldDidChange(_ textField: TextFieldMoneyView, value: Int)
}
class TextFieldMoneyView : UIView {
    @IBOutlet weak var textFieldView: UITextField!
    
    weak var delegate : TextFieldMoneyViewDelegate?
    var isCompulsory : Bool = false
    var colorTheme : UIColor = Color.greyPrimary
    private var lastValue = 0
    
    public var bgColor : UIColor = .white {
        didSet {
            updateBackgroundColor()
        }
    }
    
    public override var isUserInteractionEnabled: Bool {
        didSet {
            super.isUserInteractionEnabled = isUserInteractionEnabled
            textFieldView.isUserInteractionEnabled = isUserInteractionEnabled
            textFieldView.backgroundColor = isUserInteractionEnabled ? bgColor : Color.viewDefaultColor
            
            
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        loadViewFromNib()
        
        setupInit()
        setup()
        
    }
    
    private func setupInit(){
        textFieldView.layer.borderWidth = 2
        textFieldView.layer.borderColor = Color.textViewBorder.cgColor
        textFieldView.keyboardType = .asciiCapableNumberPad
        textFieldView.layer.cornerRadius = 5
        textFieldView.layer.masksToBounds = true
        textFieldView.delegate = self
        textFieldView.addTarget(self,
                            action: #selector(TextFieldMoneyView.textFieldDidChange(_:)), for: .editingChanged)
        
        textFieldView.text = " VND"
    }
    
    private func updateBackgroundColor(){
        textFieldView.backgroundColor = bgColor
    }
}

///FUNCTION ACCESSABLE
extension TextFieldMoneyView {
    func setup(value : Int = 0, color: UIColor = Color.greyPrimary) {
        self.colorTheme = color
        self.textFieldView.text = value.formatnumberWithDot() + " VND"
    }

    func getData() -> Int {
        return lastValue
    }
}

extension TextFieldMoneyView : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 2
        textField.layer.borderColor = Color.selectedTextView.cgColor
        
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
        guard let text = textField.text else { return }
        var curentPos = 0
        if let selectedRange = textField.selectedTextRange {
            let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.start)
            
            if (cursorPosition > text.count - 4 ) {
                let val = lastValue
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
        
        delegate?.textFieldDidChange(self, value: Int(newText) ?? 0)
        //Convert number when data hit 0 VND, because if we input number, the number 0 is not disapear, so we must convert to Int and then convert back to String to kil the number 0
        if newText.isEmpty {
            textField.text = "0 VND"
        }
        else {
            let val = Int(newText) ?? 0
            lastValue = val
            textField.text = val.formatnumberWithDot() + " VND"
        }
        
        if let newPosition = textField.position(from: textField.endOfDocument, offset: curentPos) {
            // set the new position
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
}
