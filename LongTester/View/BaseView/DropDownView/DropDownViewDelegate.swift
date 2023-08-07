//
//  DropDownViewDelegate.swift
//  LongTester
//
//  Created by Long on 5/17/23.
//

import Foundation

public protocol DropDownViewDelegate : AnyObject {
    func didSelect(indexPath: IndexPath)
    func didOpenDropDown()
    func didCloseDropdown()
}

//default
public extension DropDownViewDelegate {
    func didOpenDropDown() {
        
    }
    func didCloseDropdown(){
        
    }
}
