//
//  LoginViewController.swift
//  LongTester
//
//  Created by Long on 4/17/23.
//

import UIKit
class LoginViewController: BaseViewController {
    @IBOutlet weak var userNameView: TextFieldView!
    @IBOutlet weak var passwordView: TextFieldView!
    
    @IBOutlet weak var appTitleLbl: UILabel!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var languageLbl: UILabel!
    @IBOutlet weak var customSwitch: CustomSwitch!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    var viewModel = LoginViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindToViewModel()
        viewModel.checkLocalUser()
        
    }
    
    private func bindToViewModel() {
        self.viewModel = LoginViewModel(rootViewModel: rootViewModel)
        self.viewModel.baseVC = self
        
    }
    
    private func setup(){
        mainView.backgroundColor = Color.viewDefaultColor
        viewModel.setupLanguage()
        userNameView.setup(text: Language.localized("username"))
        passwordView.setup(text: Language.localized("password"),isSecure: true)
        #if DEBUG
        userNameView.addDefaultData(defaultValue: "ttlgame123@gmail.com")
        passwordView.addDefaultData(defaultValue: "tlong123")
        #endif
        customSwitch.delegate = self
      
        setSwitchChange()
        
        circleView.layer.cornerRadius = 10
        circleView.clipsToBounds = true

        circleView.layer.borderColor = UIColor.clear.cgColor
        
        setupBtn()
        
        appTitleLbl.layer.shadowColor = UIColor.black.cgColor
        appTitleLbl.layer.shadowRadius = 2.0
        appTitleLbl.layer.shadowOpacity = 1.0
        appTitleLbl.layer.shadowOffset = CGSize(width: 4, height: 4)
        appTitleLbl.layer.masksToBounds = false
        
    }
    
    private func setupBtn(){
        loginBtn.setTitle(Language.localized("login"), for: .normal)
        registerBtn.setTitle(Language.localized("registerAccount"), for: . normal)
        
        registerBtn.setTitleColor(Color.redPrimary, for: .normal)
        loginBtn.backgroundColor = Color.redPrimary
        loginBtn.setTitleColor(.white, for: .normal)
        loginBtn.layer.cornerRadius = 5
        loginBtn.layer.borderColor = UIColor.clear.cgColor
        loginBtn.layer.masksToBounds = true
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        viewModel.logIn(email: userNameView.getData(),
                        pasword: passwordView.getData())
//        AppDelegate.shared.rootViewController.show(.main)
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        viewModel.openSheetViewRegister()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setSwitchChange() {
        let isOn = AppConfig.shared.language == .vietnamese
        languageLbl.text = AppConfig.shared.language.rawValue
        customSwitch.myColor =  Color.redPrimary
        customSwitch.disableColor = Color.greyPrimary
        customSwitch.isOn = isOn
    }
}

extension LoginViewController : CustomSwitchDelegate {
    func switchShouldChanged(sender: CustomSwitch, value: Bool) {
        
    }
    
    func switchDidChanged(sender: CustomSwitch) {
        print("sender.isOn \(sender.isOn)")
        viewModel.changeLanguage(language : sender.isOn ? .vietnamese : .english)
    }
}
