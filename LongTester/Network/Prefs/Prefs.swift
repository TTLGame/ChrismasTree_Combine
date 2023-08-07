//
//  Prefs.swift
//  LongTester
//
//  Created by Long on 1/4/23.
//

import Foundation
import RxSwift
import RxCocoa

protocol PrefsUserInfo: AnyObject {
    func getUserInfo() -> User?
    func saveUserInfo(_ userInfo: User?)
}

protocol PrefsShowTutorial: AnyObject {
    func setShowTutorial(showTutorial: Bool)
    func isShowTutorial() -> Bool
}

protocol PrefsAccessToken: AnyObject {
    func getAccessToken() -> String?
    func saveAccessToken(_ accessToken: String?)
}

protocol PrefsRefreshToken: AnyObject {
    func getRefreshToken() -> String?
    func saveRefreshToken(_ accessToken: String?)
}
