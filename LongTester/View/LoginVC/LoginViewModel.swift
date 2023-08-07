//
//  LoginViewModel.swift
//  LongTester
//
//  Created by Long on 4/17/23.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import Alamofire
import OHHTTPStubs

class LoginViewModel : NSObject {
    let api: Provider <MultiTarget>
    let disposeBag = DisposeBag()
    private(set) var rootViewModel: RootViewModel
    
    var sheetView : BaseSheetView!
    var registerView : RegisterView!
    var baseVC : BaseViewController? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      let baseVC = self.baseVC else { return }
                self.registerView = RegisterView(frame: baseVC.view.frame,baseVC: baseVC)
                self.registerView.delegate = self
                self.sheetView = BaseSheetView(frame: baseVC.view.frame, size: .percent(0.9), baseVC: baseVC, view: self.registerView)
                self.sheetView.title = ""
                self.sheetView.isHidden = true
                self.sheetView.open()
                self.sheetView.close()
            }
        }
    }
    init(rootViewModel : RootViewModel = RootViewModel(), api: Provider<MultiTarget> = ProviderAPIBasic<MultiTarget>()) {
        self.api = api
        self.rootViewModel = rootViewModel
        super.init()
    }
    
    func setupLanguage() {
        let newQuery = ["id" : "-1"]
        if let appConfigData = StoreManager.shared.find(AppConfigModel.self, queryParts: newQuery, in: .appConfig) {
            if let language = appConfigData.first?.language {
                AppConfig.shared.language = Language(rawValue: language) ?? .vietnamese
            }
        }
    }
    
    func changeLanguage(language : Language){
        AppConfig.shared.language = language
        addLanguage()
        AppDelegate.shared.rootViewController.show(.login)
    }
    
    func addLanguage(){
        let data = AppConfigModel()
        data.language = AppConfig.shared.language.rawValue
        guard var tmpJson = data.json() else { return }
        tmpJson["id"] = "-1"
        do {
            try StoreManager.shared.save(data: tmpJson, in: .appConfig)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func checkLocalUser(){
        if let _ = PrefsImpl.default.getUserInfo()?.json() {
            DispatchQueue.main.async {
                AppDelegate.shared.rootViewController.show(.main)
            }
        }
    }
    func logIn(email: String, pasword: String) {
        #if STG
        snub()
        #endif
        rootViewModel.handleProgress(true)
        api.request(MultiTarget(LoginTarget.login(email: email, password: pasword)))
            .map(LoginModel.self, using: JSONDecoder.decoderAPI(), failsOnEmptyData: false)
            .subscribe {[weak self] event in
                guard let self = self else { return }
                switch event {
                case .success(let value):
                    if let value = value.data,
                       let token = value.token {
                        PrefsImpl.default.saveAccessToken(token)
                        PrefsImpl.default.saveUserInfo(value.user)
                        AppDelegate.shared.rootViewController.show(.main)
                        self.rootViewModel.handleProgress(false)
                    }
                case .failure(let error):
                    self.rootViewModel.alertModel.accept(AlertModel(message: error.localizedDescription))
                    self.rootViewModel.handleProgress(false)
                    break
                }
                self.rootViewModel.handleProgress(false)
            }.disposed(by: disposeBag)
    }
    
    func openSheetViewRegister(){
        self.sheetView.isHidden = false
        sheetView.open()
    }
}

extension LoginViewModel {
    func snub(){
        let roomData : [String:Any] =
        ["statusCode" : 200,
         "data" : ["user" : ["id" : "da1f2aa1-fbda-4c66-8f5d-a00e37846126",
                             "email" : "ttlgame123@gmail.com"],
                   "token" : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImRhMWYyYWExLWZiZGEtNGM2Ni04ZjVkLWEwMGUzNzg0NjEyNiIsImVtYWlsIjoidHRsZ2FtZTEyM0BnbWFpbC5jb20iLCJpYXQiOjE2ODU4MTMxNjUsImV4cCI6MTcxNzM0OTE2NX0.07fECokojExAswpSTYshiV6BbUrYUJ-cejXUerP6JMg"],
         "messageVN": "Login sucessfully!",
         "messageEN": "Đăng nhập thành công!"]
        
        var host: String = Environment.shared.configuration(.apiHost)
        let path: String = Environment.shared.configuration(.apiPath)
        
        host = host.deletingPrefix("https://")
        host = host.deletingPrefix("http://")
        host = host.replacingOccurrences(of: "/", with: "")
        
        stub(condition: isHost("\(host)") &&  isPath("/\(path)auth/login") && isScheme("https")) { _ in
            
            return HTTPStubsResponse(jsonObject: roomData, statusCode: 200, headers: nil)
        }
    }
}

extension LoginViewModel : RegisterViewDelegate {
    func didSuccessRegister() {
        self.sheetView.close()
    }
}
