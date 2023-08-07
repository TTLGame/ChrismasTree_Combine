//
//  AddressInfoSheetView.swift
//  LongTester
//
//  Created by Long on 5/26/23.
//

import Foundation
import UIKit

protocol AddressInfoSheetViewDelegate : AnyObject {
    func didChangeData(view: AddressInfoSheetView , roomData: [RoomDataModel] , monthYear: MonthYear, nextRoom : [RoomDataModel]?)
}
class AddressInfoSheetView : UIView {
    var baseVC : BaseViewController?
    
    @IBOutlet weak var segmentControl: SegmentControl!
    @IBOutlet weak var pageView: PageView!
    
    weak var delegate : AddressInfoSheetViewDelegate?
    private var currentMonthYear : MonthYear = MonthYear()
    private var addressData : AddressDataModel = AddressDataModel() {
        didSet {
            self.addressView.updateAddressData(addressData: self.addressData)
            self.addressRoomView.updateAddressData(addressData: self.addressData)
        }
    }
    
    private var addressView : AddressInfoView!
    private var addressRoomView : AddressInfoRoomView!
    init(frame: CGRect, baseVC: BaseViewController, currentMonthYear : MonthYear, addressData : AddressDataModel) {
        super.init(frame: frame)
        self.baseVC = baseVC
        self.currentMonthYear = currentMonthYear
        self.addressData = addressData
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
    
    func updateAddressData(addressData: AddressDataModel){
        self.addressData = addressData
    }
    func commonInit(){
        loadViewFromNib()
        setup()
        setupPageView()
    }
    
    private func setup(){
        self.segmentControl.layer.cornerRadius = 10
        self.segmentControl.layer.masksToBounds = true
        self.segmentControl.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.segmentControl.delegate = self

        self.segmentControl.cellViewModels = [SegmentControlCellViewModel(title: Language.localized("generalInfo")),
                                              SegmentControlCellViewModel(title: Language.localized("roomsInfo"))]
    }
    
    private func setupPageView(){
        guard let baseVC = baseVC  else { return }
        self.addressView = AddressInfoView(frame: baseVC.view.frame,
                                          currentMonthYear: currentMonthYear,
                                          data: addressData, baseVC: baseVC)
        
        self.addressRoomView = AddressInfoRoomView(frame: baseVC.view.frame,
                                                   addressDataModel: addressData,
                                                   currentMonthYear: currentMonthYear,
                                                   baseVC: baseVC)
        addressRoomView.delegate = self
        addressView.delegate = self
        pageView.transitionViews = [addressView, addressRoomView]
        pageView.animeType = .faded
    }
}

extension AddressInfoSheetView : SegmentControlDelegate {
    func didChangeSegment(indexPath: IndexPath, direction: SegmentControl.Direction) {
        pageView.animeType = .move(direction == .forward ? .reverse : .forward)
        pageView.presentView(interator: indexPath.row)
    }
}

extension AddressInfoSheetView : AddressInfoViewDelegate {
    func updateMonthYear(monthYear: MonthYear) {
        self.currentMonthYear = monthYear
        self.addressView.resetMonthYear(monthYear: currentMonthYear)
        self.addressRoomView.resetMonthYear(monthYear: currentMonthYear)
    }
}

extension AddressInfoSheetView : AddressInfoRoomViewDelegate {
    func didChangeData(view: AddressInfoRoomView, roomData: [RoomDataModel], monthYear: MonthYear, nextRoom: [RoomDataModel]?) {
        delegate?.didChangeData(view: self, roomData: roomData, monthYear: monthYear,nextRoom: nextRoom)
    }
}
