//
//  AddressCollectionViewController.swift
//  LongTester
//
//  Created by Long on 4/22/23.
//

import UIKit
import RxCocoa
import RxSwift
import DropDown

class AddressCollectionViewController: BaseViewController {

    @IBOutlet weak var backGroundImgView: UIImageView!
    @IBOutlet weak var radioViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    @IBOutlet weak var radioView: AddressCollectionRadioView!
    
    @IBOutlet weak var monthLbl: UILabel!

    @IBOutlet weak var monthInfoView: UIView!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var triangleDateImg: UIImageView!
    

    private var shouldChangeValue = true
    private var lastOffset : CGFloat = 0
    private var viewModel = AddressCollectionViewModel()
    private let sizeMax = CGFloat(40)
    private var contentSize : CGFloat = 0
    
//    private var dropdown : DropDownView<BaseDropDownCell, BaseDropDownCellViewModel>!
    private var dropdown : DropDownView<AddressCollectionDropDownCell, AddressCollectionDropDownCellViewModel>!
    private var dropdownCellViewModel = [AddressCollectionDropDownCellViewModel]()
    private var monthYearView : MonthYearView!
    
    
    init(id: String, background : String = "PyramidBG" ,rootViewModel: RootViewModel = RootViewModel()) {
        super.init(rootViewModel: rootViewModel)
        loadBackground(image: background)
        self.viewModel.setAddresId(id: id)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindToViewModel()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func loadBackground(image: String){
        DispatchQueue.main.async {
            self.backGroundImgView.image = UIImage(named: image)
        }
       
    }
    private func setup(){
        monthInfoView.addBottomShadow(height: 0, alpha: 0.4,radius: 5)
        setupCollectionView()
        setupDate()
        setupMonthPicker()
        setupBtnSetting()
        radioView.delegate = self
    }

    private func  setupBtnSetting() {
        settingBtn.setTitle("", for: .normal)
//        dropdown = DropDownView<BaseDropDownCell, BaseDropDownCellViewModel>(frame: self.view.frame, anchorView: settingBtn)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dropdown = DropDownView<AddressCollectionDropDownCell, AddressCollectionDropDownCellViewModel>(baseVC : self, anchorView: self.settingBtn)
            self.dropdown.tableWidth = 200
            self.dropdown.tableHeight = 100
            self.dropdown.cellHeight = 50
            self.dropdown.heightOffset = 8
            self.dropdown.highLightColor = .clear
            self.dropdown.horizonalDirection = .auto
            self.dropdown.verticalDirection = .auto
            self.dropdown.delegate = self
        }
    }
    
    private func setupDate(){
        let currentDateTime = Date()
        changeDateLbl(date: currentDateTime)
        
        triangleDateImg.tintColor = Color.redPrimary
        triangleDateImg.transform = CGAffineTransform(rotationAngle: .pi)

        DispatchQueue.main.async {
            UIView.animate(withDuration: 3, delay: 0.0, options: [.repeat, .autoreverse, .allowUserInteraction]) { [weak self] in
                self?.triangleDateImg.alpha = 0.3
            }
        }
    }
    
    private func setupMonthPicker(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.monthYearView = MonthYearView(frame: self.view.frame, size: .fixed(400), baseVC: self)
            self.monthYearView.delegate = self
            self.monthYearView.setupPicker()
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(monthInfoTapped))
        monthInfoView.addGestureRecognizer(gesture)
        
    }
    @objc func monthInfoTapped(){
        monthYearView.open()
    }
    
    private func bindToViewModel() {
        self.viewModel.setRootViewModel(rootViewModel: rootViewModel )
        self.viewModel.cellViewModels.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.detailCollectionView.reloadData()
            DispatchQueue.main.async {
                self.contentSize = self.detailCollectionView.contentSize.height
            }
           
            
        }).disposed(by: disposeBag)
        
        self.viewModel.radioViewModels.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] viewModel in
            guard let self = self else {return}
            self.radioView.viewModel = viewModel
            
        }).disposed(by: disposeBag)
        
        self.viewModel.dropdownCellViewModels.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] viewModels in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.dropdown.cellViewModels = viewModels
            }
           
        }).disposed(by: disposeBag)
        
        self.viewModel.collectionViewCellDropdownCellViewModels.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] viewModels in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.dropdownCellViewModel = viewModels
                self.detailCollectionView.reloadData()
            }
        }).disposed(by: disposeBag)
        
        
        self.viewModel.monthYearViewModel.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] viewModels in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.viewModel.getData(date: self.viewModel.currentMonthYear)
            }
           
        }).disposed(by: disposeBag)
        
        
        viewModel.getMonthYearData()
//        viewModel.getData(date: MonthYear())
        viewModel.getRadioData()
        viewModel.getDropdownData()
    }
    
    private func setupCollectionView(){
        detailCollectionView.register(UINib(nibName: String(describing: AddressCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: AddressCollectionViewCell.self))
        detailCollectionView.delegate = self
        detailCollectionView.dataSource = self
        
        let tapDismissGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapForDismiss))
        tapDismissGesture.numberOfTapsRequired = 2
        
        detailCollectionView.addGestureRecognizer(tapDismissGesture)

    }
    
    private func changeDateLbl(date: Date){
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "GMT+7")
        formatter.dateFormat = AppConfig.shared.language == .english ? App.Format.englishMonthYear : App.Format.vietnamMonthYear
        monthLbl.text = AppConfig.shared.language == .english ? formatter.string(from: date) :
                                                                "Tháng " + formatter.string(from: date)
    }
    
    @objc func didDoubleTapForDismiss(){
        if (viewModel.getState()){
            viewModel.changeState(value: false)
            
            self.detailCollectionView.reloadData()
        }
    }
    
    @IBAction func settingBtnTapped(_ sender: Any) {
        radioViewInteract(hide: false)
        dropdown.show()
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions(), animations: {
            [weak self] in
            self?.settingBtn.transform = CGAffineTransform(rotationAngle: .pi)
        }) { (animated) in }
        
    }
}

//MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension AddressCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.getState() ? openSheetEditOneRoom(index: indexPath) : didSelectItem(indexPath: indexPath)
    }
    
    func configureInactiveContextMenu(indexPath: IndexPath) -> UIContextMenuConfiguration{
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title:"Edit product", image: UIImage(systemName:"pencil.line")){ _ in
                self.viewModel.changeState(value: true)
                self.detailCollectionView.reloadData()
                self.openSheetEditOneRoom(index: indexPath)
            }
            return UIMenu(title:"Option", children: [deleteAction])
        }
    }
    
    func configureActiveContextMenu(indexPath: IndexPath) -> UIContextMenuConfiguration{
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let deleteAction = UIAction(title:"Stop Editing", image: UIImage(systemName:"pencil.line")){ _ in
                self.viewModel.changeState(value: false)
                self.detailCollectionView.reloadData()
            }
            return UIMenu(title:"Option", children: [deleteAction])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return viewModel.getState() ?  configureActiveContextMenu(indexPath: indexPath) :
                            configureInactiveContextMenu(indexPath: indexPath)
    }
    
}


//MARK: Handle Cell Pressed
extension AddressCollectionViewController {
    private func didSelectItem(indexPath: IndexPath){
        self.viewModel.handlePressData(index: indexPath)
    }
    
}
extension AddressCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (viewModel.cellViewModels.value.count == 0) {
            detailCollectionView.setEmptyData()
        }
        else {
            detailCollectionView.restoreNewProduct()
        }
        return viewModel.cellViewModels.value.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollPos = scrollView.contentOffset.y
        let contentSize = scrollView.contentSize.height - (scrollView.frame.size.height)
        if (self.contentSize < detailCollectionView.frame.height + 50){
            return
        }

        if (lastOffset < scrollPos) { // scroll down
            radioViewHeightConstraint.constant = radioViewHeightConstraint.constant - 1 < 0 ? 0 : radioViewHeightConstraint.constant - 1
            radioView.alpha = CGFloat(radioViewHeightConstraint.constant / sizeMax)
            settingBtn.alpha = CGFloat(radioViewHeightConstraint.constant / sizeMax)
        }
        else {
            radioViewHeightConstraint.constant = radioViewHeightConstraint.constant + 1 > sizeMax ? sizeMax : radioViewHeightConstraint.constant + 1
            radioView.alpha = CGFloat(radioViewHeightConstraint.constant / sizeMax)
            settingBtn.alpha = CGFloat(radioViewHeightConstraint.constant / sizeMax)
        }
        
        if (scrollPos <= 0){
            radioViewInteract(hide: false)
        }
        else if (scrollPos >= contentSize){
            radioViewInteract(hide: true)
        }
        
        if (radioView.alpha <= 0.5){
            radioView.isUserInteractionEnabled = false
            settingBtn.isUserInteractionEnabled = false
        }
        else {
            radioView.isUserInteractionEnabled = true
            settingBtn.isUserInteractionEnabled = true
        }
        lastOffset = scrollPos
    }
    
    private func radioViewInteract(hide: Bool){
        radioViewHeightConstraint.constant = hide ? 0 : sizeMax
        radioView.alpha = hide ? 0 : 1
        settingBtn.alpha = hide ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: AddressCollectionViewCell! = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: AddressCollectionViewCell.self),
            for: indexPath) as? AddressCollectionViewCell
        cell.viewModel = viewModel.cellViewModels.value[indexPath.row]
        cell.changeState(isChanged: viewModel.getState())
        cell.setupDropdown(viewModels: dropdownCellViewModel, baseVC: self)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension AddressCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.size.width - 40) / 2.0
        return CGSize(width: width, height: 150)
    }
}

extension AddressCollectionViewController : AddressCollectionRadioViewDelegate {
    func didSortData(interator: Int) {
        let rootView = rootViewModel as! RootViewModel
        rootView.handleProgress(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            rootView.handleProgress(false)
            self.viewModel.sortData(interator: interator)
        }
        
        self.detailCollectionView.setContentOffset(CGPoint(x:0,y:0), animated: true)
        radioViewHeightConstraint.constant = sizeMax
        radioView.alpha = 1
        settingBtn.alpha = 1
    }
}

extension AddressCollectionViewController : DropDownViewDelegate {
    func didSelect(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            openSheetEditCell()
        case 1:
            openSheetViewInfo()
        default:
            break
        }
    }
    
    func didCloseDropdown(){
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions(), animations: {
            [weak self] in
            self?.settingBtn.transform = CGAffineTransform.identity
        }) { (animated) in }
    }
}

//MARK: Handle dropdown Selection
extension AddressCollectionViewController {
    func openSheetViewInfo(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let addressSheetView = AddressInfoSheetView(frame: self.view.frame,
                                                        baseVC: self,
                                                        currentMonthYear: self.viewModel.currentMonthYear,
                                                        addressData: self.viewModel.addressDataModel)
            addressSheetView.delegate = self
            let sheetView = BaseSheetView(frame: self.view.frame, size: .percent(0.8), baseVC: self, view: addressSheetView)
            sheetView.title = Language.localized("addressCollectionMainTitle")
            sheetView.open()
        }
    }
    
    func openSheetEditCell(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let addressView = AddressInfoRoomView(
                frame: self.view.frame,
                addressDataModel: self.viewModel.addressDataModel,
                currentMonthYear: self.viewModel.currentMonthYear,
                baseVC: self)
            addressView.delegate = self
            addressView.resetMonthYear(monthYear: self.viewModel.currentMonthYear)
            let sheetView = BaseSheetView(frame: self.view.frame, size: .percent(0.8), baseVC: self, view: addressView)
            sheetView.title = Language.localized("addressCollectionMainTitle")
            sheetView.open()
        }
    }
    
    func openSheetEditOneRoom(index : IndexPath){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let addressView = OneRoomEditView(
                frame: self.view.frame,
                addressDataModel: self.viewModel.addressDataModel,
                currentMonthYear: self.viewModel.currentMonthYear,
                roomId: self.viewModel.cellViewModels.value[index.row].id ?? "",
                baseVC: self)

            addressView.delegate = self
            let sheetView = BaseSheetView(frame: self.view.frame, size: .percent(0.8), baseVC: self, view: addressView)
            sheetView.title = Language.localized("addressCollectionMainTitle")
            sheetView.open()
        }
    }
    
}

extension AddressCollectionViewController : MonthYearViewDelegate {
    func didSelectDate(value: Date) {
        changeDateLbl(date: value)
        
        let calendar = Calendar.current
        let date = value
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        viewModel.getData(date: MonthYear(month: month, year: year))
        self.radioView.reloadRadioView()
    }
}

extension AddressCollectionViewController : AddressInfoSheetViewDelegate {
    func didChangeData(view: AddressInfoSheetView, roomData: [RoomDataModel], monthYear: MonthYear, nextRoom: [RoomDataModel]?) {
        viewModel.updateAddressDataModel(roomData: roomData, monthYear: monthYear,nextRoom: nextRoom)
        view.updateAddressData(addressData: viewModel.addressDataModel)
    }
}

extension AddressCollectionViewController : OneRoomEditViewDelegate {
    func didChangeData(view: OneRoomEditView, roomData: [RoomDataModel], monthYear: MonthYear, nextRoom: [RoomDataModel]?) {
        
        viewModel.updateAddressDataModel(roomData: roomData, monthYear: monthYear,nextRoom: nextRoom)
//        view.updateAddressData(addressData: viewModel.addressDataModel)
    }
}

extension AddressCollectionViewController : AddressInfoRoomViewDelegate {
    func didChangeData(view: AddressInfoRoomView, roomData: [RoomDataModel], monthYear: MonthYear, nextRoom: [RoomDataModel]?) {
        print("MonthYear \(monthYear.month)")
        viewModel.updateAddressDataModel(roomData: roomData, monthYear: monthYear,nextRoom: nextRoom)
        view.updateAddressData(addressData: viewModel.addressDataModel)
    }
}
