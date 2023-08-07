//
//  BaseViewController.swift
//  LongTester
//
//  Created by Long on 4/21/23.
//

import UIKit
import RxSwift
class BaseViewController: UIViewController, BasicViewPresentableView {
    var rootViewModel: RootViewModel
    var alertViewModel: AlertPresentableViewModel
    
    
    let disposeBag: DisposeBag = DisposeBag()
    init(rootViewModel: RootViewModel = RootViewModel()) {
        self.rootViewModel = rootViewModel
        alertViewModel = rootViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindAlertViewModel(alertViewModel)
        bindRootViewModel()
        bindExpireToken()
        // Do any additional setup after loading the view.
    }
    
    @discardableResult
    func bindAlertViewModel(_ alertViewModel: AlertPresentableViewModel) -> Disposable {
        let disposable = alertViewModel.alertModel.observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] (model: AlertModel?) in
                guard let model = model else {
                    return
                }

                let alert = AlertBuilder.buildAlertController(for: model)
                self?.present(alert, animated: true, completion: nil)
            })

        disposable.disposed(by: disposeBag)
        return disposable
    }
    
    @discardableResult
    func bindExpireToken() -> Disposable {
        let disposable = rootViewModel.isAccessTokenExpired.distinctUntilChanged().observe(on: MainScheduler.instance)
            .filter({ (value: Bool) -> Bool in
                return (value == true)
            }).subscribe(onNext: {[weak self] (_: Bool) in
                self?.rootViewModel.clearLocalData()
                let alert = UIAlertController(title: nil, message: "Access token expired", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    // Log out using coordinator
                    AppDelegate.shared.rootViewController.show(.login)
                }))                
            })
        disposable.disposed(by: disposeBag)
        return disposable
    }
    
    @discardableResult
    func bindRootViewModel() -> Disposable {
        let disposable = rootViewModel.pushViewModel.observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] (model: PushModel?) in
                guard let model = model else {
                    return
                }
                self?.pushNavigationView(model.viewController, model.title)
            })
        disposable.disposed(by: disposeBag)
        return disposable
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
