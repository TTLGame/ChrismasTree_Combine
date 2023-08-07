//
//  AddressInfoRoomViewCell.swift
//  LongTester
//
//  Created by Long on 5/28/23.
//

import UIKit

protocol AddressInfoRoomViewCellDelegate: AnyObject {
    func focusNextView(current: IndexPath)
}
class AddressInfoRoomViewCell: UITableViewCell {

    enum roomValueType {
        case water
        case electric
    }
    
    weak var delegate : AddressInfoRoomViewCellDelegate?
    @IBOutlet weak var mainView: UIStackView!
    @IBOutlet weak var waterTextField: UITextField! {
        didSet {
            waterTextField.addDoneCancelToolbar(onDone: (target: self, action: #selector(waterTextFieldDoneBtnPressed)))
        }
    }
    @IBOutlet weak var electricTextField: UITextField! {
        didSet {
            electricTextField.addDoneCancelToolbar(onDone: (target: self, action: #selector(electricTextFieldDoneBtnPressed)))
        }
    }
    
    @IBOutlet weak var duePriceLbl: UILabel!
    @IBOutlet weak var dueTitleLbl: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var statusImgView: UIImageView!
    @IBOutlet weak var waterOldLbl: UILabel!
    @IBOutlet weak var electricOldLbl: UILabel!
    @IBOutlet weak var waterNewLbl: UILabel!
    @IBOutlet weak var electricNewLbl: UILabel!
    
    @IBOutlet weak var waterTitle: UILabel!
    @IBOutlet weak var currentWaterLbl: UILabel!
    @IBOutlet weak var lastWaterLbl: UILabel!
    @IBOutlet weak var totalPriceWaterLbl: UILabel!
    @IBOutlet weak var waterUsedLbl: UILabel!
    @IBOutlet weak var waterPriceLbl: UILabel!
    @IBOutlet weak var quotaUsedLbl: UILabel!
    @IBOutlet weak var quotaPriceLbl: UILabel!
    
    @IBOutlet weak var electricTitle: UILabel!
    @IBOutlet weak var currentElectricLbl: UILabel!
    @IBOutlet weak var lastElectricLbl: UILabel!
    @IBOutlet weak var totalPriceElectricLbl: UILabel!
    @IBOutlet weak var electricUsedLbl: UILabel!
    @IBOutlet weak var electricPriceLbl: UILabel!
    
    @IBOutlet weak var trashTitle: UILabel!
    @IBOutlet weak var trashPriceLbl: UILabel!
    @IBOutlet weak var trashView: UIView!
    
    @IBOutlet weak var internetTitle: UILabel!
    @IBOutlet weak var internetPriceLbl: UILabel!
    @IBOutlet weak var internetView: UIView!
    
    @IBOutlet weak var roomPriceTitle: UILabel!
    @IBOutlet weak var roomPriceLbl: UILabel!
    
    @IBOutlet weak var totalTitle: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var roomNumLbl: UILabel!
    
   
    
    var viewModel : AddressInfoRoomViewCellViewModel? {
        didSet{
            bindData()
        }
    }
    var indexPath : IndexPath!
    private var pickerView : BasePickerView!
    
    private func bindData(){
        guard let viewModel = viewModel else { return }
        let currentWater = viewModel.currentWater ?? 0
        let lastWater = viewModel.lastWater ?? 0
        currentWaterLbl.text = String(currentWater)
        lastWaterLbl.text = String(lastWater)
        
        if (currentWater - lastWater > (viewModel.quota ?? 0)){
            quotaUsedLbl.text = String(currentWater - lastWater - (viewModel.quota ?? 0))
        }
        else {
            quotaUsedLbl.text = "0"
        }
        
        quotaPriceLbl.text = "X   " + (viewModel.quotaPrice?.formatnumberWithDot() ?? "0")
        waterUsedLbl.text = String(currentWater - lastWater)
        waterPriceLbl.text = "X   " + (viewModel.waterPrice?.formatnumberWithDot() ?? "0")
        totalPriceWaterLbl.text = (viewModel.totalWater?.formatnumberWithDot() ?? "0") + " VND"
//        waterTextField.text = String(currentWater)
        
        let currentElectric = viewModel.currentElectric ?? 0
        let lastElectric = viewModel.lastElectric ?? 0
        currentElectricLbl.text = String(currentElectric)
        lastElectricLbl.text = String(lastElectric)
        electricUsedLbl.text = String(currentElectric - lastElectric)
        electricPriceLbl.text = "X   " +  (viewModel.electricPrice?.formatnumberWithDot() ?? "0")
        totalPriceElectricLbl.text = (viewModel.totalElectric?.formatnumberWithDot() ?? "0") + " VND"
//        electricTextField.text = String(currentElectric)
        
        if let trashPrice = viewModel.trashPrice, trashPrice != 0 {
            trashPriceLbl.text = trashPrice.formatnumberWithDot() + " VND"
            trashView.isHidden = false
        }
        else {
            trashView.isHidden = true
        }
        
        if let internetPrice = viewModel.internetPrice, internetPrice != 0 {
            internetPriceLbl.text = internetPrice.formatnumberWithDot() + " VND"
            internetView.isHidden = false
        }
        else {
            internetView.isHidden = true
        }

        totalLbl.text = (viewModel.total?.formatnumberWithDot() ?? "0") + " VND"
        roomPriceLbl.text = (viewModel.roomPrice?.formatnumberWithDot() ?? "0") + " VND"
        
        roomNumLbl.text = String(viewModel.roomNum ?? 0)
        electricOldLbl.textColor = Color.normalTextColor
        waterOldLbl.textColor = Color.normalTextColor
        
        
        electricNewLbl.textColor = Color.normalTextColor
        waterNewLbl.textColor = Color.normalTextColor
        
        electricTextField.text = String(viewModel.inputElectric ?? 0)
        waterTextField.text = String(viewModel.inputWater ?? 0)
        
        duePriceLbl.text = (viewModel.paid?.formatnumberWithDot() ?? "0") + " VND"
        changeOldLabel(type: .electric)
        changeOldLabel(type: .water)
        
        setStatusView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
        addGesture()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupPicker(viewModel: [PickerViewModel], baseVC : UIViewController?){
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let baseVC = baseVC else { return }
            self.pickerView = BasePickerView(frame: baseVC.view.frame, size: .fixed(300), baseVC: baseVC)
            self.pickerView.delegate = self
            self.pickerView.viewModel = viewModel
//            self.pickerView.pickerType = .withoutImage
            self.pickerView.setupPicker()
        }
    }
    
    private func addGesture(){
        statusImgView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(pressedStatusImage))
        statusImgView.addGestureRecognizer(tap)
    }
    
    @objc func pressedStatusImage(){
        
        pickerView.open()
    }
    
    private func setup(){
        dueTitleLbl.text = Language.localized("paid")
        waterTitle.text = Language.localized("water")
        electricTitle.text = Language.localized("electric")
        trashTitle.text = Language.localized("trashFee")
        internetTitle.text = Language.localized("internetFee")
        roomPriceTitle.text = Language.localized("roomPrice")
        totalTitle.text = Language.localized("total")
        
        mainView.layer.borderWidth = 1.0
        mainView.layer.borderColor = UIColor.clear.cgColor
        mainView.layer.cornerRadius = 10
        mainView.layer.masksToBounds = true
        
        electricTextField.layer.cornerRadius = 5
        electricTextField.layer.borderWidth = 1
        electricTextField.layer.borderColor = Color.viewDefaultColor.cgColor
        electricTextField.layer.masksToBounds = true
        
        waterTextField.layer.cornerRadius = 5
        waterTextField.layer.borderWidth = 1
        waterTextField.layer.borderColor = Color.viewDefaultColor.cgColor
        waterTextField.layer.masksToBounds = true
        
        electricTextField.delegate = self
        waterTextField.delegate = self
        
        waterTextField.keyboardType = .asciiCapableNumberPad
        electricTextField.keyboardType = .asciiCapableNumberPad
        
        electricTextField.addTarget(self, action: #selector(AddressInfoRoomViewCell.textFieldDidChange(_:)), for: .editingChanged)
        waterTextField.addTarget(self, action: #selector(AddressInfoRoomViewCell.textFieldDidChange(_:)), for: .editingChanged)
        
        editState(isDisable: true)
        waterNewLbl.text = ""
        electricNewLbl.text = ""
    }
    
    func editState(isDisable: Bool){
        UIView.animate(withDuration: 0.2) {
            self.waterOldLbl.text = isDisable  ? "     " : String(self.viewModel?.lastWater ?? 0)
            self.electricOldLbl.text = isDisable ? "" : String(self.viewModel?.lastElectric ?? 0)
            
            self.waterNewLbl.text = isDisable  ? "" :
                                                (self.viewModel?.nextWater != nil ?
                                                 String(self.viewModel?.nextWater ?? 0) : "")
            self.electricNewLbl.text = isDisable  ? "" :
                                                (self.viewModel?.nextElectric != nil ?
                                                 String(self.viewModel?.nextElectric ?? 0) : "")
            self.layoutIfNeeded()
        }
//        waterOldLbl.text = isDisable  ? "" : String(viewModel?.lastWater ?? 0)
//        electricOldLbl.text = isDisable ? "" : String(viewModel?.lastElectric ?? 0)
        
        electricTextField.isUserInteractionEnabled = !isDisable
        waterTextField.isUserInteractionEnabled = !isDisable
    
        electricTextField.backgroundColor = isDisable ? Color.viewDefaultColor : .white
        waterTextField.backgroundColor = isDisable ? Color.viewDefaultColor : .white
        
        statusImgView.isUserInteractionEnabled = !isDisable
    }
    
    func editStatusState(editState: Bool, isDisable : Bool){
        if (!editState){
            return
        }
        statusImgView.isUserInteractionEnabled = !isDisable
    }
    
    func updateNextValue(value: [Int?]){
        viewModel?.nextWater = value[0]
        viewModel?.nextElectric = value[1]
    }
    
    private func setStatusView(){
        guard let status = viewModel?.inputStatus else { return }
        switch AddressCollectionViewCellViewModel.roomStatus(rawValue: status)  {
        case .paid :
            statusImgView.image = UIImage(named: "yesSymbol")
        case .notPaid :
            statusImgView.image = UIImage(named: "noSymbol")
        case .vacancy:
            statusImgView.image = UIImage(named: "vacancySymbol")
        default:
            statusImgView.image = UIImage(named: "pendingSymbol")
        }
    }
    
    func focusWaterTextField(){
        self.waterTextField.becomeFirstResponder()
    }
    
    func selectingCell(){
        infoView.isHidden = false
        mainView.backgroundColor = Color.viewDefaultColor
        layoutIfNeeded()
    }
    
    func deselectingCell(){
        self.infoView.isHidden = true
        self.mainView.backgroundColor = .white
        layoutIfNeeded()
    }
}

extension AddressInfoRoomViewCell : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = Color.selectedTextView.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = Color.viewDefaultColor.cgColor
    }
    
    private func changeOldLabel(type: roomValueType){
        switch type {
        case .electric :
            if let viewModel = viewModel,
               let newElectricText = electricTextField.text,
               let electricText = Int(newElectricText) {
                viewModel.inputElectric = electricText
                electricOldLbl.textColor = viewModel.checkValidation(type: .electric) ? Color.normalTextColor : Color.redPrimary
                
                electricNewLbl.textColor = viewModel.checkValidationNext(type: .electric) ? Color.normalTextColor : Color.redPrimary
            }
            
        case .water :
            if let viewModel = viewModel,
               let newWaterText = waterTextField.text,
               let waterText = Int(newWaterText) {
                viewModel.inputWater = waterText
                waterOldLbl.textColor = viewModel.checkValidation(type: .water) ? Color.normalTextColor : Color.redPrimary
                
                waterNewLbl.textColor = viewModel.checkValidationNext(type: .water) ? Color.normalTextColor : Color.redPrimary
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

extension AddressInfoRoomViewCell {
    @objc func waterTextFieldDoneBtnPressed(){
        electricTextField.becomeFirstResponder()
    }
    
    @objc func electricTextFieldDoneBtnPressed(){
        electricTextField.resignFirstResponder()
        self.delegate?.focusNextView(current: indexPath)
    }
    
}

extension AddressInfoRoomViewCell : BasePickerViewDelegate {
    func didSelectIndex(index: Int, id: String?) {
        viewModel?.inputStatus = id
        self.setStatusView()
        
    }
}
