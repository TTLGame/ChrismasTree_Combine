//
//  UITextField.swift
//  LongTester
//
//  Created by Long on 5/31/23.
//

import Foundation
import UIKit

extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        
        let cancelBar = UIBarButtonItem(title: Language.localized("cancelBtn"), style: .plain, target: onCancel.target, action: onCancel.action)
        cancelBar.tintColor = Color.normalTextColor
        
        let doneBar = UIBarButtonItem(title: Language.localized("doneBtn"), style: .done, target: onDone.target, action: onDone.action)
        doneBar.tintColor = Color.normalTextColor
        
        toolbar.items = [
            cancelBar,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            doneBar
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}
