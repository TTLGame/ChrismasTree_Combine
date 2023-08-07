//
//  RegisterViewModel.swift
//  LongTester
//
//  Created by Long on 6/6/23.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import SVProgressHUD
import OHHTTPStubs
class RegisterViewModel : NSObject {
    var isMale : BehaviorRelay<Bool> = BehaviorRelay(value: true)
    var didRegisterSuccess : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    let api: Provider <MultiTarget>
    private(set) var rootViewModel: RootViewModel
    let limit: Int = 50

    let disposeBag = DisposeBag()
    init(rootViewModel : RootViewModel = RootViewModel(), api: Provider<MultiTarget> = ProviderAPIWithAccessToken<MultiTarget>()) {
        self.api = api
        self.rootViewModel = rootViewModel
        super.init()
    }
    
    func setMaleData(isMale: Bool) {
        self.isMale.accept(isMale)
    }
    
    func register(data: RegisterReqModel){
        rootViewModel.handleProgress(true)
        api.request(MultiTarget(LoginTarget.register(request: data)))
            .map(ReturnBlankModel.self, using: JSONDecoder.decoderAPI(), failsOnEmptyData: false)
            .subscribe {[weak self] event in
                guard let self = self else { return }
                switch event {
                case .success(let value):
                    if let messageVN = value.messageVN,
                       let messageEN = value.messageEN{
                        let alertModel = AlertModel.ActionModel(title: Language.localized("login"), style: .default, handler: {_ in
                            self.didRegisterSuccess.accept(true)
                        })
                        
                        self.rootViewModel.alertModel.accept(
                            AlertModel(actionModels: [alertModel],
                                       title: "", message: AppConfig.shared.language == .vietnamese ? messageVN : messageEN,
                                       prefferedStyle: .alert))
                        
//                        self.rootViewModel.alertModel.accept(AlertModel(message: AppConfig.shared.language == .vietnamese ? messageVN : messageEN))
                        
                    }
                case .failure(let error):
                    self.rootViewModel.alertModel.accept(AlertModel(message: error.localizedDescription))
                    
                    self.didRegisterSuccess.accept(false)
                    break
                }
                self.rootViewModel.handleProgress(false)
               
            }.disposed(by: disposeBag)
    }
}
