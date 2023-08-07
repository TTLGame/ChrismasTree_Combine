//
//  TableScreenViewModel.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Moya
class TableScreenViewModel : NSObject {
    var cellViewModels: BehaviorRelay<[TableScreenCellViewModel]> = BehaviorRelay(value: [])
    private(set) var users : BehaviorRelay<[User]> = BehaviorRelay(value: [])
    let api: Provider<MultiTarget>
    let limit: Int = 50
    let disposeBag = DisposeBag()
    
    init(api: Provider<MultiTarget> = ProviderAPIBasic<MultiTarget>()) {
        self.api = api
        super.init()
        bindToEvents()
    }
    
    func bindToEvents() {
        users.map {users in
            users.map {user in
                return TableScreenCellViewModel(avatar: user.avatar,
                                                fullName: user.fullname)
            }
        }.bind(to: cellViewModels).disposed(by: disposeBag)
        
    }
    
    func getUserData() {
        api.request(MultiTarget(MainScreenTarget.getUser(page: 1)))
            .map(Pages.self, using: JSONDecoder.decoderAPI(), failsOnEmptyData: false)
            .subscribe {[weak self] event in
                guard let self = self else { return }
                switch event {
                case .success(let value):
                    if let value = value.data {
                        self.users.accept(value)
                    }
                case .failure(_):
                    break
                }
            }.disposed(by: disposeBag)
    }
}
