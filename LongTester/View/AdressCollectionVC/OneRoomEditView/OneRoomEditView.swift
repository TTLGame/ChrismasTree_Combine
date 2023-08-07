//
//  OneRoomEditView.swift
//  LongTester
//
//  Created by Long on 6/8/23.
//

import Foundation
import UIKit
import RxSwift
protocol OneRoomEditViewDelegate : AnyObject {
    func didChangeData(view: OneRoomEditView , roomData: [RoomDataModel] , monthYear: MonthYear, nextRoom : [RoomDataModel]?)
}

class OneRoomEditView : UIView {
    enum roomValueType {
        case water
        case electric
    }
    
    var baseVC : BaseViewController?
    private var viewModel = OneRoomEditViewModel()
    private let disposeBag = DisposeBag()
    private var addressDataModel : AddressDataModel = AddressDataModel()
    private var currentMonthYear = MonthYear()
    private var roomId : String = ""
    private var pickerView : BasePickerView!
    weak var delegate : OneRoomEditViewDelegate?
    
    @IBOutlet weak var roomLbl: UILabel!
    @IBOutlet weak var waterLbl: UILabel!
    @IBOutlet weak var electricLbl: UILabel!
    @IBOutlet weak var editImgView: UIImageView!
    
    @IBOutlet weak var statusImgView: UIImageView!
    @IBOutlet weak var waterOldLbl: UILabel!
    @IBOutlet weak var electricOldLbl: UILabel!
    @IBOutlet weak var waterNewLbl: UILabel!
    @IBOutlet weak var electricNewLbl: UILabel!
    @IBOutlet weak var roomNumLbl: UILabel!
    
    
    @IBOutlet weak var quotaPriceTitle: UILabel!
    @IBOutlet weak var rentersTitle: UILabel!
    @IBOutlet weak var quotaTitle: UILabel!
    @IBOutlet weak var waterTitle: UILabel!
    @IBOutlet weak var electricTitle: UILabel!
    @IBOutlet weak var trashTitle: UILabel!
    @IBOutlet weak var internetTitle: UILabel!
    @IBOutlet weak var roomPriceTitle: UILabel!
    @IBOutlet weak var paidTitle: UILabel!
    
    @IBOutlet weak var totalTitle: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    
    
    @IBOutlet weak var electricTextField: UITextField!
    @IBOutlet weak var waterTextField: UITextField!
    @IBOutlet weak var quotaPriceTextField: TextFieldMoneyView!
    @IBOutlet weak var waterPriceTextField: TextFieldMoneyView!
    @IBOutlet weak var electricPriceTextField: TextFieldMoneyView!
    @IBOutlet weak var trashPriceTextField: TextFieldMoneyView!
    @IBOutlet weak var internetPriceTextField: TextFieldMoneyView!
    @IBOutlet weak var roomPricePriceTextField: TextFieldMoneyView!
    @IBOutlet weak var paidPriceTextField: TextFieldMoneyView!
    @IBOutlet weak var rentersTextField: TextFieldView!
    @IBOutlet weak var quotaTextField: TextFieldView!
    
    init(frame: CGRect,
         addressDataModel: AddressDataModel,
         currentMonthYear : MonthYear,
         roomId: String,
         baseVC: BaseViewController) {
        super.init(frame: frame)
        self.baseVC = baseVC
        self.currentMonthYear = currentMonthYear
        self.addressDataModel = addressDataModel
        self.roomId = roomId
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
        bindViewModel()
    }
    
    private func bindViewModel(){
        guard let baseVC = baseVC else { return }
        self.viewModel = OneRoomEditViewModel(rootViewModel: baseVC.rootViewModel)
        self.viewModel.addressDataModel = addressDataModel
        self.viewModel.currentMonthYear = currentMonthYear
        self.viewModel.roomId = roomId
        
        self.viewModel.addressDataMonthModel.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.viewModel.getData(date: self.viewModel.currentMonthYear)
            
        }).disposed(by: disposeBag)
        
        self.viewModel.pickerViewModel.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] data in
            guard let self = self else {return}
            self.setupPicker(viewModel: data)
            
        }).disposed(by: disposeBag)
        
        
        self.viewModel.cellViewModels.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            
            self.bindData()
            
        }).disposed(by: disposeBag)
        
        self.viewModel.statusBtnState.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] state in
            guard let self = self else {return}
            let index = self.viewModel.getIndex()
            if index >= self.viewModel.cellViewModels.value.count {
                return
            }
            self.setStatusView(status: self.viewModel.cellViewModels.value[index].inputStatus ?? "")
            self.changeTextFieldState(isEdit: state)
            
        }).disposed(by: disposeBag)
        
        
        self.viewModel.setupData()
        self.viewModel.getPickerData()
    }
    
    func setupPicker(viewModel: [PickerViewModel]){
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let baseVC = self.baseVC else { return }
            self.pickerView = BasePickerView(frame: baseVC.view.frame, size: .fixed(300), baseVC: baseVC)
            self.pickerView.delegate = self
            self.pickerView.viewModel = viewModel
//            self.pickerView.pickerType = .withoutImage
            self.pickerView.setupPicker()
        }
    }
    
    private func addGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(pressedStatusImage))
        statusImgView.addGestureRecognizer(tap)
    }
    
    @objc func pressedStatusImage(){
        
        pickerView.open()
    }
    
    private func setup(){
        addGesture()
        electricTextField.keyboardType = .asciiCapableNumberPad
        waterTextField.keyboardType = .asciiCapableNumberPad
        electricTextField.layer.cornerRadius = 5
        electricTextField.layer.borderWidth = 1
        electricTextField.layer.borderColor = Color.viewDefaultColor.cgColor
        electricTextField.layer.masksToBounds = true
        
        waterTextField.layer.cornerRadius = 5
        waterTextField.layer.borderWidth = 1
        waterTextField.layer.borderColor = Color.viewDefaultColor.cgColor
        waterTextField.layer.masksToBounds = true
        
        self.roomLbl.text = Language.localized("room")
        self.electricLbl.text = Language.localized("electric")
        self.waterLbl.text = Language.localized("water")
       
        paidTitle.text = Language.localized("Paid")
        waterTitle.text = Language.localized("water")
        electricTitle.text = Language.localized("electric")
        trashTitle.text = Language.localized("trashFee")
        internetTitle.text = Language.localized("internetFee")
        roomPriceTitle.text = Language.localized("roomPrice")
        totalTitle.text = Language.localized("total")
        quotaTitle.text = Language.localized("quota")
        quotaPriceTitle.text = Language.localized("quotaPrice")
        rentersTitle.text = Language.localized("renters")
        
        electricTextField.delegate = self
        waterTextField.delegate = self
        quotaPriceTextField.delegate = self
        waterPriceTextField.delegate = self
        electricPriceTextField.delegate = self
        trashPriceTextField.delegate = self
        internetPriceTextField.delegate = self
        roomPricePriceTextField.delegate = self
        paidPriceTextField.delegate = self
        rentersTextField.delegate = self
        quotaTextField.delegate = self
        
        quotaTextField.setup(text: "", isDigit: true)
        rentersTextField.setup(text: "", isDigit: true)
        
        electricTextField.addTarget(self, action: #selector(AddressInfoRoomViewCell.textFieldDidChange(_:)), for: .editingChanged)
        
        waterTextField.addTarget(self, action: #selector(AddressInfoRoomViewCell.textFieldDidChange(_:)), for: .editingChanged)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(editChangePressed))
        editImgView.addGestureRecognizer(gesture)
        editImgView.isUserInteractionEnabled = true
        
        changeTextFieldState(isEdit: true)
    }
    
    private func bindData(){
        
        let index = viewModel.getIndex()
        if index >= viewModel.cellViewModels.value.count {
            return
        }
        let nextData = self.viewModel.getNextMonthData(index: self.viewModel.getIndex())
        viewModel.cellViewModels.value[index].nextWater =  nextData[0]
        viewModel.cellViewModels.value[index].nextElectric =  nextData[1]
        
        electricTextField.text = String(viewModel.cellViewModels.value[index].currentElectric ?? 0 )
        waterTextField.text = String(viewModel.cellViewModels.value[index].currentWater ?? 0 )
        roomNumLbl.text = String(viewModel.cellViewModels.value[index].roomNum ?? 0)
        quotaPriceTextField.setup(value: viewModel.cellViewModels.value[index].quotaPrice ?? 0)
        waterPriceTextField.setup(value: viewModel.cellViewModels.value[index].waterPrice ?? 0)
        electricPriceTextField.setup(value: viewModel.cellViewModels.value[index].electricPrice ?? 0)
        trashPriceTextField.setup(value: viewModel.cellViewModels.value[index].trashPrice ?? 0)
        internetPriceTextField.setup(value: viewModel.cellViewModels.value[index].internetPrice ?? 0)
        
        roomPricePriceTextField.setup(value: viewModel.cellViewModels.value[index].roomPrice ?? 0)
        paidPriceTextField.setup(value: viewModel.cellViewModels.value[index].paid ?? 0)
        rentersTextField.addDefaultData(defaultValue: String(viewModel.cellViewModels.value[index].renters ?? 0))
        quotaTextField.addDefaultData(defaultValue: String(viewModel.cellViewModels.value[index].quota ?? 0))
        
        setStatusView(status: viewModel.cellViewModels.value[index].status ?? "")
        changeTextFieldState(isEdit: viewModel.statusBtnState.value)
        updateTotalNum()
    }
    
    private func setStatusView(status: String){
        paidPriceTextField.isUserInteractionEnabled = false
        switch AddressCollectionViewCellViewModel.roomStatus(rawValue: status)  {
        case .paid :
            statusImgView.image = UIImage(named: "yesSymbol")
        case .notPaid :
            statusImgView.image = UIImage(named: "noSymbol")
        case .vacancy:
            statusImgView.image = UIImage(named: "vacancySymbol")
        default:
            statusImgView.image = UIImage(named: "pendingSymbol")
            paidPriceTextField.isUserInteractionEnabled = viewModel.statusBtnState.value
        }
    }
}

extension OneRoomEditView {
    func changeTextFieldState(isEdit: Bool){
        let index = viewModel.getIndex()
        if index >= viewModel.cellViewModels.value.count {
            return
        }
        
        UIView.animate(withDuration: 0.2) {
            self.waterOldLbl.text = !isEdit  ?
                "     " :
                String(self.viewModel.cellViewModels.value[index].lastWater ?? 0)
            self.electricOldLbl.text = !isEdit ?
                "" :
                String(self.viewModel.cellViewModels.value[index].lastElectric ?? 0)
            
            self.waterNewLbl.text = !isEdit  ?
                "" :
                (self.viewModel.cellViewModels.value[index].nextWater != nil ?
                    String(self.viewModel.cellViewModels.value[index].nextWater ?? 0)
                 : "")
            
            self.electricNewLbl.text = !isEdit  ? "" :
            (self.viewModel.cellViewModels.value[index].nextElectric != nil ?
             String(self.viewModel.cellViewModels.value[index].nextElectric ?? 0)
             : "")
            
            self.layoutIfNeeded()
        }
        statusImgView.isUserInteractionEnabled = isEdit
        waterTextField.isUserInteractionEnabled = isEdit
        electricTextField.isUserInteractionEnabled = isEdit
        quotaTextField.isUserInteractionEnabled = isEdit
        rentersTextField.isUserInteractionEnabled = isEdit
        quotaPriceTextField.isUserInteractionEnabled = isEdit
        waterPriceTextField.isUserInteractionEnabled = isEdit
        electricPriceTextField.isUserInteractionEnabled = isEdit
        trashPriceTextField.isUserInteractionEnabled = isEdit
        internetPriceTextField.isUserInteractionEnabled = isEdit
        roomPricePriceTextField.isUserInteractionEnabled = isEdit
//        paidPriceTextField.isUserInteractionEnabled = isEdit
    }
    
    @objc func editChangePressed(){
        let index = viewModel.getIndex()
        if index >= viewModel.cellViewModels.value.count {
            return
        }
        
        self.viewModel.changeState()
        if (!viewModel.statusBtnState.value) {
            if (viewModel.checkValidation()){
                
                delegate?.didChangeData(view: self,
                                        roomData: viewModel.convertCellVMtoModels(),
                                        monthYear: viewModel.currentMonthYear,
                                        nextRoom: viewModel.convertNextMonthDatatoModels())
            }
            else {
                viewModel.showPopUp()
                self.viewModel.changeState()
            }
        }
    }
    
    private func updateTotalNum(){
        let index = viewModel.getIndex()
        if index >= viewModel.cellViewModels.value.count {
            return
        }
        let total = viewModel.changeTotal(cell: viewModel.cellViewModels.value[index])
        totalLbl.text = total[0].formatnumberWithDot() + " VND"
    }
    
    private func updateViewModel(){
        let index = viewModel.getIndex()
        if index >= viewModel.cellViewModels.value.count {
            return
        }
        let total = viewModel.changeTotal(cell: viewModel.cellViewModels.value[index])
        totalLbl.text = total[0].formatnumberWithDot() + " VND"
    }
    
}

extension OneRoomEditView : TextFieldMoneyViewDelegate {
    func textFieldDidChange(_ textField: TextFieldMoneyView, value: Int) {
        let index = viewModel.getIndex()
        if index >= viewModel.cellViewModels.value.count {
            return
        }
        switch textField {
        case quotaPriceTextField :
            viewModel.cellViewModels.value[index].inputQuotaPrice = value
        case waterPriceTextField :
            viewModel.cellViewModels.value[index].inputWaterPrice = value
        case electricPriceTextField :
            viewModel.cellViewModels.value[index].inputElectricPrice = value
        case trashPriceTextField :
            viewModel.cellViewModels.value[index].inputTrashPrice = value
        case internetPriceTextField :
            viewModel.cellViewModels.value[index].inputInternetPrice = value
        case roomPricePriceTextField :
            viewModel.cellViewModels.value[index].inputRoomPrice = value
        case paidPriceTextField :
            viewModel.cellViewModels.value[index].inputPaid = value
        default :
            break
        }
        
        updateTotalNum()
    }
}

extension OneRoomEditView : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = Color.selectedTextView.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = Color.viewDefaultColor.cgColor
    }
    
    private func changeOldLabel(type: roomValueType){
        let index = viewModel.getIndex()
        if index >= viewModel.cellViewModels.value.count {
            return
        }
        
        switch type {
        case .electric :
            if let newElectricText = electricTextField.text,
               let electricText = Int(newElectricText) {
                viewModel.cellViewModels.value[index].inputElectric = electricText
                electricOldLbl.textColor = viewModel.cellViewModels.value[index].checkValidation(type: .electric) ? Color.normalTextColor : Color.redPrimary
                
                electricNewLbl.textColor = viewModel.cellViewModels.value[index].checkValidationNext(type: .electric) ? Color.normalTextColor : Color.redPrimary
            }
            
        case .water :
            if let newWaterText = waterTextField.text,
               let waterText = Int(newWaterText) {
                viewModel.cellViewModels.value[index].inputWater = waterText
                waterOldLbl.textColor = viewModel.cellViewModels.value[index].checkValidation(type: .water) ? Color.normalTextColor : Color.redPrimary
                
                waterNewLbl.textColor = viewModel.cellViewModels.value[index].checkValidationNext(type: .water) ? Color.normalTextColor : Color.redPrimary
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if ( textField.text == ""){
            textField.text = "0"
        }
        
        //remove number 0
        if let text = textField.text,
           let convertInt = Int(text) {
            textField.text = String(convertInt)
        }
      
        changeOldLabel(type: textField == waterTextField ? .water : .electric)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}

extension OneRoomEditView : BasePickerViewDelegate {
    func didSelectIndex(index: Int, id: String?) {
        let index = viewModel.getIndex()
        if index >= viewModel.cellViewModels.value.count {
            return
        }
        
        self.viewModel.cellViewModels.value[index].inputStatus = id
        self.setStatusView(status: id ?? "")
    }
}

extension OneRoomEditView : TextFieldViewDelegate {
    func handleErrorMessage(text: String) {
        self.baseVC?.rootViewModel.alertModel.accept(AlertModel(message: text))
    }
    
    func textFieldDidChange(_ textField: TextFieldView, value: String) {
        let index = viewModel.getIndex()
        if index >= viewModel.cellViewModels.value.count {
            return
        }
        switch textField {
        case rentersTextField :
            viewModel.cellViewModels.value[index].inputRenters = Int(value)
        case quotaTextField :
            viewModel.cellViewModels.value[index].inputQuota = Int(value)
        default :
            break
        }
    }
}
