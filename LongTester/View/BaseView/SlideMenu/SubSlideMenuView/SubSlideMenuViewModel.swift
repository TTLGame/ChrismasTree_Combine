//
//  SubSlideMenuViewModel.swift
//  LongTester
//
//  Created by Long on 4/19/23.
//

import Foundation

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Moya
class SubSlideMenuViewModel : NSObject {
    var cellViewModels: BehaviorRelay<[SlideMenuViewModel]> = BehaviorRelay(value: [])
    private(set) var userName : BehaviorRelay<String> = BehaviorRelay(value: "")
    let disposeBag = DisposeBag()
    
    var menu: [SlideMenuViewModel] = [
        SlideMenuViewModel(icon: UIImage(systemName: "house.fill")!, title: "TableView"),
        SlideMenuViewModel(icon: UIImage(systemName: "music.note")!, title: "Music"),
        SlideMenuViewModel(icon: UIImage(systemName: "film.fill")!, title: "Date"),
        SlideMenuViewModel(icon: UIImage(systemName: "book.fill")!, title: "Books"),
        SlideMenuViewModel(icon: UIImage(systemName: "person.fill")!, title: "Profile"),
        SlideMenuViewModel(icon: UIImage(systemName: "slider.horizontal.3")!, title: "Settings"),
        SlideMenuViewModel(icon: UIImage(systemName: "hand.thumbsup.fill")!, title: "Like us on facebook")
    ]
    
    override init() {
        super.init()
    }
    
    func getCellData() {
        self.cellViewModels.accept(menu)
    }
    
    func getNameData(){
        if let user = PrefsImpl.default.getUserInfo(),
           let name = user.fullname{
            self.userName.accept(name)
            
        }
    }
    //
}
