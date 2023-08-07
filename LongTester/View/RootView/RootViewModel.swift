//
//  RootViewModel.swift
//  LongTester
//
//  Created by Long on 4/20/23.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import SVProgressHUD

class RootViewModel : NSObject, BasicViewModel {
    var pushViewModel: BehaviorRelay<PushModel?> = BehaviorRelay(value: nil)
    var alertModel: BehaviorRelay<AlertModel?> = BehaviorRelay(value: nil)
    var isAccessTokenExpired : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    func handleProgress(_ value : Bool){
        if (value){
            SVProgressHUD.show(withStatus: "Loading ....")
        } else {
            SVProgressHUD.dismiss()
        }
    }

    func setUpObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAccessTokenExpired),
                                               name: .AutoHandleAccessTokenExpired, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleAPIError(_:)),
                                               name: .AutoHandleAPIError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNoInternetConnectionError(_:)),
                                               name: .AutoHandleNoInternetConnectionError, object: nil)
    }
    
    override init() {
        super.init()
        setUpObserver()
    }
    
    func clearLocalData (){
        PrefsImpl.default.saveUserInfo(nil)
        PrefsImpl.default.saveAccessToken(nil)
    }
    @objc func handleAccessTokenExpired() {
        isAccessTokenExpired.accept(true)
    }

    @objc func handleAPIError(_ notification: Notification) {
        if let error: Error = notification.object as? Error {
            if case APIError.ignore(_) = error {
                return
            }

            print("error as? LocalizedAppError \(error as? LocalizedAppError)")
            if let localizedError: LocalizedAppError = error as? LocalizedAppError,
               let message = localizedError.appErrorDescription {
                self.alertModel.accept(AlertModel(message: message))
            } else {
                self.alertModel.accept(AlertModel(message: Language.localized("systemError")))
            }
        } else {
            self.alertModel.accept(AlertModel(message: Language.localized("systemError")))
        }
    }

    @objc func handleNoInternetConnectionError(_ notification: Notification) {
        let alert = AlertModel(actionModels:
                                [AlertModel.ActionModel(title: "OK", style: .default, handler: nil)],
                               title: nil,
                               message: Language.localized("internetError"),
                               prefferedStyle: .alert)
        self.alertModel.accept(alert)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
