//
//  SubSlideMenuView.swift
//  LongTester
//
//  Created by Long on 4/19/23.
//

import Foundation
import UIKit
import RxSwift

protocol SubSlideMenuViewDelegate : AnyObject {
    func selectedCell(_ row: Int)
}

class SubSlideMenuView : UIView {
    
    @IBOutlet weak var imageBack: UIImageView!
    @IBOutlet weak var contentTblView: UITableView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var logoutLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var helloLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    var defaultHighlightedCell: Int = 0
    let disposeBag = DisposeBag()
    let viewModel = SubSlideMenuViewModel()
    weak var delegate : SubSlideMenuViewDelegate?
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {// UIView disappear
        } else {// UIView appear
            self.viewModel.getNameData()
            self.viewModel.getCellData()
            self.contentTblView.reloadData()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        loadViewFromNib()
        logoutLbl.text = Language.localized("logout")
        helloLbl.text = Language.localized("hello")
        imageBack.image = UIImage(named: "logOut")
        logoutView.backgroundColor = Color.redPrimary
        headerView.backgroundColor = Color.redPrimary
        //Add gesture
        addTapGesture()
        
        //Init TableView
        initTableView()
        
        //Bind Data
        bindData()
    }
    
    private func bindData(){
        self.viewModel.cellViewModels.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] item in
            guard let self = self else {return}
            self.contentTblView.reloadData()
            }).disposed(by: disposeBag)
        
        self.viewModel.userName.observe(on: MainScheduler.instance).subscribe { [weak self] name in
            guard let self = self else {return}
            self.nameLbl.text = name
        }.disposed(by: disposeBag)
    }
    
    private func addTapGesture(){
        let uiTapGesture = UITapGestureRecognizer(target: self, action: #selector(pressLogout))
        let uiLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectLogout(_:)))
                
        uiLongGesture.minimumPressDuration = 0.3
        logoutView.isUserInteractionEnabled = true
        logoutView.addGestureRecognizer(uiTapGesture)
        logoutView.addGestureRecognizer(uiLongGesture)
    }
    
    
    private func initTableView(){
        self.contentTblView.delegate = self
        self.contentTblView.dataSource = self
        self.contentTblView.backgroundColor = Color.redPrimary
        self.contentTblView.separatorStyle = .none
        
        self.contentTblView.register(UINib(nibName: String(describing: SlideMenuViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: SlideMenuViewCell.self))
        //        // Set Highlighted Cell
        //        DispatchQueue.main.async {
        //            let defaultRow = IndexPath(row: self.defaultHighlightedCell, section: 0)
        //            self.sideMenuTableView.selectRow(at: defaultRow, animated: false, scrollPosition: .none)
        //        }
    }
    
    private func logout(){
        self.delegate?.selectedCell(-1)
        PrefsImpl.default.saveUserInfo(nil)
        PrefsImpl.default.saveAccessToken(nil)
        AppDelegate.shared.rootViewController.show(.login)
    }
    @objc func pressLogout() {
        logout()
    }
    @objc func selectLogout(_ gestureRecognizer: UILongPressGestureRecognizer!){
        if (gestureRecognizer.state == .began){
            logoutView.backgroundColor = Color.selectLogout
            
        }
        else if (gestureRecognizer.state == .ended){
            let size = gestureRecognizer.location(in: logoutView)
            if (size.y < 0 || size.y > 40.0 ||
                size.x < 0 || size.x > self.frame.size.width){
                logoutView.backgroundColor = Color.redPrimary
            }
            else {
                logout()
            }
        }
    }
}


// MARK: - UITableViewDelegate

extension SubSlideMenuView: UITableViewDelegate {
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 40
   }
}

// MARK: - UITableViewDataSource

extension SubSlideMenuView: UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.viewModel.cellViewModels.value.count
   }

   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell: SlideMenuViewCell! = tableView.dequeueReusableCell(
           withIdentifier: String(describing: SlideMenuViewCell.self),
           for: indexPath) as? SlideMenuViewCell
       
       
       let data = viewModel.cellViewModels.value[indexPath.row]
       cell.iconImageView.image = data.icon
       cell.textLbl.text = data.title
    
       // Highlighted color
       let myCustomSelectionColorView = UIView()
       myCustomSelectionColorView.backgroundColor = Color.selectTableView
       cell.selectedBackgroundView = myCustomSelectionColorView
       return cell
   }

   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       self.delegate?.selectedCell(indexPath.row)
       // ...
       
//        Remove highlighted color when you press the 'Profile' and 'Like us on facebook' cell
//       if indexPath.row == 4 || indexPath.row == 6 {
//           tableView.deselectRow(at: indexPath, animated: true)
//       }
   }
}
