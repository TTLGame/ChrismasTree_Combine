//
//  DateSelectView.swift
//  LongTester
//
//  Created by Long on 5/22/23.
//

import Foundation
import UIKit
import SnapKit

class DateSelectView : UIView {
    @IBOutlet weak var labelTextField: UITextField!
    private var returnData = ""
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
      
        
        datePicker.setDate(Date(), animated: true)
        datePicker.addTarget(self, action: #selector(didScrollValueDate), for: .valueChanged)
        return datePicker
    }()
    var formatDate : String = App.Format.headerDateTime
    var dateHeight : CGFloat = 200
    var visibleTextField  = false
    
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
        setupDate()
        setup()
    }
    
    func setup(){
        labelTextField.layer.cornerRadius = 5
        labelTextField.layer.borderWidth = 2
        labelTextField.layer.borderColor = Color.textViewBorder.cgColor
        labelTextField.layer.masksToBounds = true
        labelTextField.textColor = Color.greyPrimary
        labelTextField.delegate = self
    }
    
    @objc func didScrollValueDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = self.formatDate
        let selectedDate = formatter.string(from: datePicker.date)
        print("selected date :\(selectedDate)")
    }
    
    func setupDate(height : CGFloat = 200){
        self.dateHeight = height
    
        // Big enough frame
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.dateHeight)
        let pickerWrapperView = UIView(frame: rect)
        pickerWrapperView.addSubview(datePicker)

        // Adding constraints
        datePicker.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Using wrapper view instead of picker
        labelTextField.inputView = pickerWrapperView
        configureUI()
    }
    
    private func configureUI() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: Language.localized("doneBtn"),
                                         style: .done,
                                         target: self,
                                         action: #selector(handleDoneButton(_:)))
        
        let cancelButton = UIBarButtonItem(title: Language.localized("cancelBtn"),
                                         style: .done,
                                         target: self,
                                         action: #selector(handleCancelButton(_:)))
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        toolbar.setItems([cancelButton, space, doneButton], animated: true)
        toolbar.tintColor = Color.normalTextColor
        labelTextField.inputAccessoryView = toolbar
    }
    
    @objc func handleDoneButton(_ textField: UITextField) {
        let formatter = DateFormatter()
        formatter.dateFormat = self.formatDate
        labelTextField.text = formatter.string(from: datePicker.date)
        
        formatter.dateFormat = App.Format.reponseDateTime
        returnData = formatter.string(from: datePicker.date)
        labelTextField.endEditing(true)
   
    }
    
    @objc func handleCancelButton(_ textField: UITextField) {
        labelTextField.endEditing(true)
    }
}

extension DateSelectView {
    func addPlaceHolder(text: String){
        labelTextField.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [NSAttributedString.Key.foregroundColor: Color.greyPrimary]
        )
    }
    
    func getData() -> String {
        return returnData
    }
}

extension DateSelectView : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        labelTextField.layer.borderColor = Color.selectedTextView.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        labelTextField.layer.borderColor = Color.textViewBorder.cgColor
    }
}
