//
//  ViewController.swift
//  LongTester
//
//  Created by Long on 12/28/22.
//

import UIKit
import RealmSwift
import RxSwift
class MainScreenViewController: BaseViewController {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var addressTblView: UITableView!
    @IBOutlet weak var headerBackGround: UIView!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var remainLbl: UILabel!
    private var viewModel = MainScreenViewModel()
    private var slideMenu = SlideMenuView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToViewModel()
        setup()
        // Do any additional setup after loading the view.
    }
    
    private func setup(){
        mainView.backgroundColor = Color.viewDefaultColor
        headerBackGround.addBottomShadow()
        headerBackGround.backgroundColor = Color.redPrimary
        headerLbl.text = Language.localized("mainTitle")
        headerLbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        let slideMenu = SlideMenuView(frame: self.view.frame, baseVC: self)
        self.slideMenu = slideMenu
        self.view.addSubview(self.slideMenu)
        
        setupTableView()
        
    }
    
    private func bindToViewModel() {
        self.viewModel = MainScreenViewModel(rootViewModel: rootViewModel )
        self.viewModel.baseVC = self
        self.viewModel.cellViewModels.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.addressTblView.reloadData()
            self.viewModel.updateCurrentAddressNumber()
            
        }).disposed(by: disposeBag)
        
        self.viewModel.willAddMore.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            
            self.remainLbl.text = "\(self.viewModel.cellViewModels.value.count) / \(self.viewModel.maxAddress)"
            self.addressTblView.reloadData()
            
        }).disposed(by: disposeBag)
        
        self.viewModel.dropdownCellVM.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.addressTblView.reloadData()
            
        }).disposed(by: disposeBag)
        
        viewModel.getMainScreenData()
        viewModel.getDropdownData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupTableView(){
        self.addressTblView.register(UINib(nibName: String(describing: MainScreenCell.self), bundle: nil), forCellReuseIdentifier: String(describing: MainScreenCell.self))
        
        self.addressTblView.register(UINib(nibName: String(describing: MainScreenAddMoreCell.self), bundle: nil), forCellReuseIdentifier: String(describing: MainScreenAddMoreCell.self))
        
        self.addressTblView.delegate = self
        self.addressTblView.dataSource = self        
    }
    
    @IBAction func menuBtnPressed(_ sender: Any) {
        self.slideMenu.handleAction()
        
    }
}

extension MainScreenViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let bg = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10))
        bg.backgroundColor = .clear
        return bg
    }
    
}

extension MainScreenViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (viewModel.cellViewModels.value.count + viewModel.willAddMore.value == 0) {
            tableView.setEmptyData()
        }
        else {
            tableView.restoreNewProduct()
        }
        return viewModel.cellViewModels.value.count + viewModel.willAddMore.value
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == viewModel.cellViewModels.value.count {
            let cell: MainScreenAddMoreCell! = tableView.dequeueReusableCell(
                withIdentifier: String(describing: MainScreenAddMoreCell.self),
                for: indexPath) as? MainScreenAddMoreCell

            // Highlighted color
            let myCustomSelectionColorView = UIView()
            myCustomSelectionColorView.backgroundColor = .clear
            cell.selectedBackgroundView = myCustomSelectionColorView
            cell.handlePress = {
                self.viewModel.handleOpenCreatePopup()
            }
            
            return cell
        }
        else {
            let cell: MainScreenCell! = tableView.dequeueReusableCell(
                withIdentifier: String(describing: MainScreenCell.self),
                for: indexPath) as? MainScreenCell

            cell.viewModel = viewModel.cellViewModels.value[indexPath.row]
            cell.setupDropdown(viewModels: viewModel.dropdownCellVM.value, baseVC: self)
            // Highlighted color
            let myCustomSelectionColorView = UIView()
            myCustomSelectionColorView.backgroundColor = .clear
            cell.selectedBackgroundView = myCustomSelectionColorView
            cell.handlePress = {
                self.handlePressData(indexPath: indexPath)
            }
            
            cell.handlePressDropdown = { index in
                self.viewModel.handleDropdown(selectDropdownIndex: index,
                                              selectcellIndex: indexPath)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        rootViewModel.alertModel.accept(AlertModel(message: "123"))
        
        indexPath.row == viewModel.cellViewModels.value.count ?
            viewModel.handleOpenCreatePopup() :
            viewModel.handlePressData(index: indexPath)
    }
    
    private func handlePressData(indexPath: IndexPath){
        viewModel.handlePressData(index: indexPath)
    }
    
}

extension MainScreenViewController : CustomPopUpDelegate {
    func didPressAction() {
        
        viewModel.createAddress()
    }
}
