//
//  UISwitch.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation
import UIKit
@available(iOS 14.0, *)
extension UISwitch {
    
    func setOnValueChangeListener(onValueChanged :@escaping (Bool) -> Void){
        self.addAction(UIAction(){ action in
            onValueChanged(self.isOn)
        }, for: .valueChanged)
    }
  
}
