//
//  AddressInfoRoomView.swift
//  LongTester
//
//  Created by Long on 5/26/23.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
protocol AddressInfoRoomViewDelegate : AnyObject {
    func didChangeData(view: AddressInfoRoomView , roomData: [RoomDataModel] , monthYear: MonthYear, nextRoom : [RoomDataModel]?)
}
class AddressInfoRoomView : UIView {
    var baseVC : BaseViewController?
    private var viewModel = AddressInfoRoomViewModel()
    private let disposeBag = DisposeBag()
    private var addressDataModel : AddressDataModel = AddressDataModel()
    private var currentMonthYear = MonthYear()
    
    weak var delegate : AddressInfoRoomViewDelegate?
    @IBOutlet weak var detailTblView: UITableView!
    
    @IBOutlet weak var roomLbl: UILabel!
    @IBOutlet weak var waterLbl: UILabel!
    @IBOutlet weak var electricLbl: UILabel!
    @IBOutlet weak var editImgView: UIImageView!
    
    @IBOutlet weak var editBtnView: EditStatusButtonView!
    @IBOutlet weak var editBtnHeightConstraint: NSLayoutConstraint!
    func updateAddressData(addressData: AddressDataModel){
        self.addressDataModel = addressData
        self.viewModel.addressDataModel = addressDataModel
        self.viewModel.setupData()
        
    }
    init(frame: CGRect,addressDataModel: AddressDataModel, currentMonthYear : MonthYear, baseVC: BaseViewController) {
        super.init(frame: frame)
        self.baseVC = baseVC
        self.currentMonthYear = currentMonthYear
        self.addressDataModel = addressDataModel
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        loadViewFromNib()
        setup()
        bindData()
    }
    
    private func setup(){
        self.detailTblView.register(UINib(nibName: String(describing: AddressInfoRoomViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: AddressInfoRoomViewCell.self))
        self.detailTblView.delegate = self
        self.detailTblView.dataSource = self
        
        self.roomLbl.text = Language.localized("room")
        self.electricLbl.text = Language.localized("electric")
        self.waterLbl.text = Language.localized("water")
        
        self.editBtnView.alpha = 0
        self.editBtnHeightConstraint.constant = 0
        editImgView.isUserInteractionEnabled = true
        
        editBtnView.baseVC = self.baseVC
        editBtnView.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(editChangePressed))
        editImgView.addGestureRecognizer(gesture)
    }
    
    @objc func editChangePressed(){
        viewModel.changeEditMode()
        viewModel.changeCurrentIndex(index: -1)
        
        if (viewModel.getEditMode()) {
            DispatchQueue.main.async {
                self.detailTblView.reloadData()
            }
            UIView.animate(withDuration: 0.2) {
                self.editBtnView.alpha = 1
                self.editBtnHeightConstraint.constant = 40
                
                self.layoutIfNeeded()
            }
        }
        else {
            if (viewModel.checkValidation()){
                UIView.animate(withDuration: 0.2) {
                    self.editBtnView.alpha = 0
                    self.editBtnHeightConstraint.constant = 0
                    self.layoutIfNeeded()
                }
                editBtnView.resetData()
                delegate?.didChangeData(view: self,
                                        roomData: viewModel.convertCellVMtoModels(),
                                        monthYear: viewModel.currentMonthYear,
                                        nextRoom: viewModel.convertNextMonthDatatoModels())
                
//                self.detailTblView.reloadData()
            }
            else {
                viewModel.showPopUp()
                viewModel.changeEditMode()
            }
        }
    }
    private func bindData(){
        self.viewModel = AddressInfoRoomViewModel(rootViewModel: baseVC?.rootViewModel as! RootViewModel)
        self.viewModel.addressDataModel = addressDataModel
        self.viewModel.currentMonthYear = currentMonthYear
        self.viewModel.cellViewModels.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.detailTblView.reloadData()
            
        }).disposed(by: disposeBag)
        
        self.viewModel.addressDataMonthModel.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.viewModel.getData(date: self.viewModel.currentMonthYear)
            
        }).disposed(by: disposeBag)
        
        self.viewModel.pickerViewModel.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.detailTblView.reloadData()
                self.editBtnView.setupPicker(viewModel: self.viewModel.pickerViewModel.value)
            }
        }).disposed(by: disposeBag)
        
        self.viewModel.statusBtnState.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.detailTblView.reloadData()
            }
        }).disposed(by: disposeBag)
        
        self.viewModel.setupData()
        self.viewModel.getPickerData()
    }
}

extension AddressInfoRoomView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension AddressInfoRoomView : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AddressInfoRoomViewCell! = tableView.dequeueReusableCell(
            withIdentifier: String(describing: AddressInfoRoomViewCell.self),
            for: indexPath) as? AddressInfoRoomViewCell
        cell.selectionStyle = .none
        cell.delegate = self
        cell.viewModel = viewModel.cellViewModels.value[indexPath.row]
        cell.updateNextValue(value: viewModel.getNextMonthData(index: indexPath.row))
        cell.editState(isDisable: !viewModel.getEditMode())
        cell.editStatusState(editState: viewModel.getEditMode(),
                             isDisable: viewModel.statusBtnState.value)
        cell.indexPath = indexPath
        cell.setupPicker(viewModel: self.viewModel.pickerViewModel.value, baseVC: baseVC)
        if (indexPath.row == viewModel.getFocusIndex()) {
            viewModel.changeFocusIndex(index: -1)
            DispatchQueue.main.async {
                cell.focusWaterTextField()
            }
        }
        
        indexPath.row == self.viewModel.getCurrentIndex() ? cell.selectingCell() : cell.deselectingCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.getEditMode() {
            if viewModel.statusBtnState.value {
                viewModel.cellViewModels.value[indexPath.row].inputStatus = viewModel.getCurrentEditStatus()
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            return
        }
        
        let currentIndex = viewModel.getCurrentIndex()
        let oldIndex = currentIndex
        if (currentIndex == indexPath.row) {
            viewModel.changeCurrentIndex(index: -1)
        }
        else {
            viewModel.changeCurrentIndex(index: indexPath.row)
        }
        if oldIndex == -1 {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            tableView.reloadRows(at: [indexPath, IndexPath(row: oldIndex, section: 0)], with: .automatic)
        }
    }
}

extension AddressInfoRoomView {
    func resetMonthYear(monthYear: MonthYear) {
        self.viewModel.getData(date: monthYear)
    }
}

extension AddressInfoRoomView : AddressInfoRoomViewCellDelegate {
    func focusNextView(current: IndexPath) {
        if (current.row + 1 < viewModel.cellViewModels.value.count) {
            viewModel.changeFocusIndex(index: current.row + 1)
            detailTblView.reloadRows(at: [IndexPath(row: current.row + 1, section: 0)], with: .none)
        }
    }
}

extension AddressInfoRoomView : EditStatusButtonViewDelegate {
    func didChangeStatusEditState(state: Bool, currentStatus: String) {
        self.viewModel.changeCurrentEditStatus(data: currentStatus)
        self.viewModel.changeEditStatusBtnState(state: state)
    }
}
