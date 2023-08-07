//
//  AddressCollectionViewCell.swift
//  LongTester
//
//  Created by Long on 4/22/23.
//

import UIKit

class AddressCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var roomNumberLbl: UILabel!
    @IBOutlet weak var rentersLbl: UILabel!
    @IBOutlet weak var statusImgView: UIImageView!
    
    
    @IBOutlet weak var waterTitleLbl: UILabel!
    @IBOutlet weak var electricTitleLbl: UILabel!
    @IBOutlet weak var totalTitleLbl: UILabel!
    @IBOutlet weak var waterAmmountLbl: UILabel!
    @IBOutlet weak var electricAmmountLbl: UILabel!
    @IBOutlet weak var totalAmmountLbl: UILabel!
    @IBOutlet weak var statusImageUIView: UIView!
    
    private var dropdown : DropDownView<AddressCollectionDropDownCell, AddressCollectionDropDownCellViewModel>!
    
    var viewModel: AddressCollectionViewCellViewModel? {
        didSet {
            bindData()
        }
    }
    
    var enableGesture: Bool = false {
        didSet {
            gestureConfig()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }

    
    public func changeState(isChanged: Bool){
//        self.enableGesture = isChanged
        self.enableGesture = false
        isChanged ? bgView.addBottomShadow(height: 3, alpha: 0.8,radius: 4,color: Color.darkGreen) :
                    bgView.addBottomShadow(height: 3, alpha: 0.2,radius: 4)
    }
    private func setup(){
        bgView.addBottomShadow(height: 3, alpha: 0.2,radius: 4)
        bgView.layer.masksToBounds = false
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 10
        
        mainView.layer.cornerRadius = 10
        mainView.backgroundColor = .white
        mainView.layer.masksToBounds = true
        
        statusView.layer.cornerRadius = 10
        statusView.layer.masksToBounds = true
        
        waterTitleLbl.text = Language.localized("waterCell")
        electricTitleLbl.text = Language.localized("electricCell")
        totalTitleLbl.text = Language.localized("totalCell")
        
        addGesture()
    }
    
    private func addGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(pressedStatusImage))
        statusImageUIView.addGestureRecognizer(tap)
    }
    
    func setupDropdown(viewModels : [AddressCollectionDropDownCellViewModel], baseVC: BaseViewController){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dropdown = DropDownView<AddressCollectionDropDownCell, AddressCollectionDropDownCellViewModel>(baseVC : baseVC, anchorView: self.statusImgView)
            
            self.dropdown.cellViewModels = viewModels
            
            self.dropdown.tableWidth = 200
            self.dropdown.tableHeight = 150
            self.dropdown.cellHeight = 50
            self.dropdown.heightOffset = 8
//            self.dropdown.highLightColor = .clear
            self.dropdown.horizonalDirection = .auto
            self.dropdown.verticalDirection = .auto
            self.dropdown.delegate = self
        }
    }
    @objc func pressedStatusImage(){
        print("pressedStatusImage")
        self.dropdown.show()
    }
    private func bindData(){
        self.setStatusView()
        if let roomNums = viewModel?.roomNums , let renters = viewModel?.renters {
            roomNumberLbl.text = Language.localized("roomNums") +  String(roomNums)
            rentersLbl.text = Language.localized("renters") + String(renters)
        }
        
       if let water = viewModel?.waterNum,
          let electric = viewModel?.electricNum,
          let lastWater = viewModel?.lastWaterNum,
          let lastElectric = viewModel?.lastElectricNum,
          let total = viewModel?.totalNum {
           waterAmmountLbl.text =  "\(water)(\(water - lastWater))"
           electricAmmountLbl.text = "\(electric)(\(electric - lastElectric))"
           totalAmmountLbl.text =  total.formatnumberWithDot() + " VND"
       }
    }
    
    private func gestureConfig(){
        guard let gestures = statusImageUIView.gestureRecognizers else { return }
        
        for gesture in gestures {
            gesture.isEnabled = enableGesture
        }
    }
    
    private func setStatusView(){
        guard let status = viewModel?.status else { return }
        switch AddressCollectionViewCellViewModel.roomStatus(rawValue: status)  {
        case .paid :
            statusView.backgroundColor = Color.darkGreen
            statusImgView.image = UIImage(named: "yesSymbol")
        case .notPaid :
            statusView.backgroundColor = Color.redPrimary
            statusImgView.image = UIImage(named: "noSymbol")
        case .vacancy:
            statusView.backgroundColor = Color.purpleVacancy
            statusImgView.image = UIImage(named: "vacancySymbol")
        default:
            statusView.backgroundColor = Color.orangePrimary
            statusImgView.image = UIImage(named: "pendingSymbol")
        }
    }
}

extension AddressCollectionViewCell : DropDownViewDelegate {
    func didSelect(indexPath: IndexPath) {
        print("Selected")
    }
}
