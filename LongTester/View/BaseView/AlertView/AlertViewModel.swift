//
//  AlertViewModel.swift
//  LongTester
//
//  Created by Long on 4/21/23.
//

import Foundation
import RxSwift
import RxCocoa
protocol AlertPresentableViewModel {
    var alertModel: BehaviorRelay<AlertModel?> { get set }
}
