//
//  AddressInfoRoomViewModel.swift
//  LongTester
//
//  Created by Long on 5/29/23.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class AddressInfoRoomViewModel : NSObject {
    var cellViewModels : BehaviorRelay<[AddressInfoRoomViewCellViewModel]> = BehaviorRelay(value: [])
    var addressDataMonthModel : BehaviorRelay<[AddressDataMonthModel]> = BehaviorRelay(value: [])
    var roomDataModel : BehaviorRelay<[RoomDataModel]> = BehaviorRelay(value: [])
    var pickerViewModel : BehaviorRelay<[PickerViewModel]> = BehaviorRelay(value: [])
    var statusBtnState : BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    private var editMode = false
    private var currentIndex : Int = -1
    private var focusIndex : Int = -1
    private var currentEditStatus : String = ""
    
    let api: Provider<MultiTarget>
    private(set) var rootViewModel: RootViewModel

    var addressDataModel : AddressDataModel = AddressDataModel()
    var currentMonthYear = MonthYear()
    
    let disposeBag = DisposeBag()
    init(rootViewModel : RootViewModel = RootViewModel(), api: Provider<MultiTarget> = ProviderAPIBasic<MultiTarget>()) {
        self.api = api
        self.rootViewModel = rootViewModel
        super.init()
        bindToEvents()
        
    }

    private func calculateTotal(cell : RoomDataModel) -> [Int] {
        var total = 0
        let currentElectric = cell.electricNum ?? 0
        let lastElectric = cell.lastElectricNum ?? 0
        let totalElectric = (currentElectric - lastElectric) * (cell.electricPrice ?? 0)
        
        let currentWater = cell.waterNum ?? 0
        let lastWater = cell.lastWaterNum ?? 0
        let quota = cell.quota ?? 0
        let qutotaPrice = cell.quotaPrice ?? 0
        var totalWater = ((currentWater - lastWater) * (cell.waterPrice ?? 0))
        
        totalWater += currentWater - lastWater > quota ? (currentWater - lastWater - quota) * qutotaPrice : 0
        total += totalWater + totalElectric
        
        if let trashPrice = cell.trashPrice {
            total += trashPrice
        }
        
        if let internetPrice = cell.internetPrice {
            total += internetPrice
        }
        
        total += cell.roomPrice ?? 0
        
        return [total, totalWater, totalElectric]
    }
    private func bindToEvents() {
        roomDataModel.map {data in
            data.map {cell in
                let arrTotal = self.calculateTotal(cell: cell)
                let total = arrTotal[0]
                let totalWater = arrTotal[1]
                let totalElectric = arrTotal[2]
                
                return AddressInfoRoomViewCellViewModel(status: cell.status, roomNum: cell.roomNums, lastWater: cell.lastWaterNum, currentWater: cell.waterNum, totalWater: totalWater, waterPrice:  cell.waterPrice, quotaPrice: cell.quotaPrice, quota: cell.quota, lastElectric: cell.lastElectricNum, currentElectric: cell.electricNum, electricPrice: cell.electricPrice, totalElectric: totalElectric, trashPrice: cell.trashPrice, internetPrice: cell.internetPrice, roomPrice: cell.roomPrice, paid: cell.paidNum, total: total,renters: cell.renters)
            }
        }.bind(to: cellViewModels).disposed(by: disposeBag)
    }
    
    private func getRoomDataModel(date: MonthYear) -> [RoomDataModel] {
        let checkData = addressDataMonthModel.value.contains(where: { cell in
            var monthYearData = MonthYear()
            if let monthYear = cell.monthYear?.split(separator: "-"),
                monthYear.count > 1{
                if let month = Int(monthYear[0]), let year = Int(monthYear[1]) {
                    monthYearData = MonthYear(month: month,
                                              year: year)
                }
            }
            return monthYearData == date
        })
        
        if (checkData){
            if let monthYearData = addressDataMonthModel.value.filter({ cell in
                var monthYearData = MonthYear()
                if let monthYear = cell.monthYear?.split(separator: "-"),
                    monthYear.count > 1{
                    if let month = Int(monthYear[0]), let year = Int(monthYear[1]) {
                        monthYearData = MonthYear(month: month,
                                                  year: year)
                    }
                }
                return monthYearData == date
            }).first , let mainCellData = monthYearData.roomData {
                return mainCellData
            }
        }
        return []
    }
}

//MARK: Public Function
extension AddressInfoRoomViewModel {
    func setupData(){
        if let data = addressDataModel.data {
            self.addressDataMonthModel.accept(data)
        }
    }
    func getData(date: MonthYear){
        currentMonthYear = date
        roomDataModel.accept(getRoomDataModel(date: date))
    }
    
    func getPickerData(){
        let cellData = [PickerViewModel(title: Language.localized("yesSymbolText"),
                                        image: UIImage(named: "yesSymbol"),
                                        id: "Paid"),
                        PickerViewModel(title: Language.localized("vacancySymbolText"),
                                        image: UIImage(named: "vacancySymbol"),
                                        id : "Vacancy"),
                        PickerViewModel(title: Language.localized("noSymbolText"),
                                        image: UIImage(named: "noSymbol"),
                                        id : "NotPaid")]
        self.pickerViewModel.accept(cellData)
    }
    
    func getNextMonthData(index: Int) -> [Int?]{
        if (currentMonthYear == MonthYear()){
            return [nil,nil] }
    
        let roomData  = getRoomDataModel(date: currentMonthYear + 1)
        if roomData.count > index {
            return [roomData[index].waterNum, roomData[index].electricNum]
        }
        return [nil,nil]
    }
    
    func showPopUp(){
        let closeModel = AlertModel.ActionModel(title: Language.localized("understand"), style: .default, handler: {_ in
        })
        rootViewModel.alertModel.accept(AlertModel(actionModels: [closeModel], title: "ChristmasTree", message: Language.localized("errorInvalidData"), prefferedStyle: .alert))
    }
    
    func checkValidation() -> Bool{
        var result = true
        for cellViewModel in cellViewModels.value {
            result = result
            && cellViewModel.checkValidation(type: .all)
            && cellViewModel.checkValidationNext(type: .all)
        }
        
        return result
    }
    
    func changeEditMode(){
        editMode = !editMode
    }

    func getEditMode() -> Bool{
        return editMode
    }

    func changeCurrentIndex(index: Int){
        currentIndex = index
    }

    func getCurrentIndex() -> Int{
        return currentIndex
    }
    
    func changeFocusIndex(index: Int){
        focusIndex = index
    }

    func getFocusIndex() -> Int{
        return focusIndex
    }
    
    func changeEditStatusBtnState(state: Bool){
        self.statusBtnState.accept(state)
    }
    
    func changeCurrentEditStatus(data: String){
        currentEditStatus = data
    }

    func getCurrentEditStatus() -> String{
        return currentEditStatus
    }
}


//Convert data back to Models -> Optimize views due to they don't have to call API second time to have updated value
extension AddressInfoRoomViewModel {
    func convertCellVMtoModels() -> [RoomDataModel] {
        let roomData = roomDataModel.value
        
        for interator in 0..<cellViewModels.value.count {
           
            roomData[interator].waterNum = cellViewModels.value[interator].inputWater
            roomData[interator].electricNum = cellViewModels.value[interator].inputElectric
            roomData[interator].status = cellViewModels.value[interator].inputStatus
            
            let arrTotal = self.calculateTotal(cell: roomData[interator])
            
            if (roomData[interator].status == "Paid") {
                roomData[interator].paidNum = arrTotal[0]
            }
            else if (roomData[interator].status != "Pending") {
                roomData[interator].paidNum = 0
            }
        
            roomData[interator].totalNum = arrTotal[0]
        }
        return roomData
    }
    
    func convertNextMonthDatatoModels() -> [RoomDataModel]? {
        if (currentMonthYear == MonthYear() || cellViewModels.value.count == 0){
            return nil
        }
        let roomData  = getRoomDataModel(date: currentMonthYear + 1)
        for interator in 0..<roomData.count {
            roomData[interator].lastWaterNum = cellViewModels.value[interator].inputWater
            roomData[interator].lastElectricNum = cellViewModels.value[interator].inputElectric
            
            let arrTotal = self.calculateTotal(cell: roomData[interator])
            roomData[interator].totalNum = arrTotal[0]
            
            if (roomData[interator].paidNum ?? 0 >=  arrTotal[0]) {
                roomData[interator].paidNum =  arrTotal[0]
            }
        }
        return roomData
    }
}
