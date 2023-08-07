//
//  BaseViewModel.swift
//  LongTester
//
//  Created by Long on 4/21/23.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
protocol BasicViewModel: AlertPresentableViewModel {
    var pushViewModel: BehaviorRelay<PushModel?> { get set }
}

protocol BasicViewPresentableView: AlertPresentableView {
    var rootViewModel: RootViewModel { get }
}
