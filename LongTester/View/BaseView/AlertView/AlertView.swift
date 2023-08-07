//
//  AlertView.swift
//  LongTester
//
//  Created by Long on 4/21/23.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol AlertPresentableView {
    var alertViewModel: AlertPresentableViewModel { get }
}

