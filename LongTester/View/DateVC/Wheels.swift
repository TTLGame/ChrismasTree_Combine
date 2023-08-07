//
//  Wheels.swift
//  LongTester
//
//  Created by Long on 1/6/23.
//

import Foundation
import UIKit
class Wheels {
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
      
        
        datePicker.setDate(Date(), animated: true)
        datePicker.addTarget(self, action: #selector(setTitle), for: .valueChanged)
        return datePicker
    }()
    
    @objc func setTitle() {
        let formatter = DateFormatter()
        formatter.dateFormat = App.Format.headerDateTime
        let selectedDate = formatter.string(from: datePicker.date)
//        labelTextField.text = selectedDate
        // Update data if date picker has been change
        formatter.dateFormat = App.Format.responseTime
        let serverDate = formatter.string(from: datePicker.date)

    }
    
    private func setupDate(){
//        labelTextField.inputView = datePicker
        configureUI()
    }
    
    func configureUI() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done",
                                         style: .done,
                                         target: self,
                                         action: #selector(handleDoneButton(_:)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        toolbar.setItems([space, doneButton], animated: true)
        toolbar.tintColor = Color.normalTextColor
//        labelTextField.inputAccessoryView = toolbar
    }
    
    @objc func handleDoneButton(_ textField: UITextField) {
        let formatter = DateFormatter()
        formatter.dateFormat = App.Format.responseTime
        let selectedDate = formatter.string(from: datePicker.date)
//        labelTextField.endEditing(true)
    }
}
