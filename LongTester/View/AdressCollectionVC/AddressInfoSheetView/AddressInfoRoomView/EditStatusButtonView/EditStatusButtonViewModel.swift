//
//  EditStatusButtonViewModel.swift
//  LongTester
//
//  Created by Long on 6/1/23.
//

import Foundation
import Moya
import RxCocoa
import RxSwift

class EditStatusButtonViewModel : NSObject {
    var editingState : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let dataStatus : BehaviorRelay<[PickerViewModel]> = BehaviorRelay(value: [])
    let api: Provider<MultiTarget>
    
    private var currentStatus  = ""
    private(set) var rootViewModel: RootViewModel
    
    var addressDataModel : AddressDataModel = AddressDataModel()
    var currentMonthYear = MonthYear()
    
    let disposeBag = DisposeBag()
    init(rootViewModel : RootViewModel = RootViewModel(), api: Provider<MultiTarget> = ProviderAPIBasic<MultiTarget>()) {
        self.api = api
        self.rootViewModel = rootViewModel
        super.init()
    }
    
    func getCurrentStatus() -> String {
        return currentStatus
    }
    
    func changeCurrentStatus(status : String) {
        currentStatus = status
    }
    
    func changeEditState(change : Bool) {
        editingState.accept(change)
    }
    
    func addDataStatus(data: [PickerViewModel]){
        dataStatus.accept(data)
    }
}
