//
//  AddressCollectionViewModel.swift
//  LongTester
//
//  Created by Long on 4/22/23.
//

import Foundation

import RxSwift
import RxCocoa
import Moya
import SVProgressHUD
import OHHTTPStubs

class AddressCollectionViewModel : NSObject {
    var radioViewModels : BehaviorRelay<AddressCollectionRadioViewModel> = BehaviorRelay(value: AddressCollectionRadioViewModel(cellViewModels: []))
    var dropdownCellViewModels : BehaviorRelay<[AddressCollectionDropDownCellViewModel]> = BehaviorRelay(value: [])
    var collectionViewCellDropdownCellViewModels : BehaviorRelay<[AddressCollectionDropDownCellViewModel]> = BehaviorRelay(value: [])
    
    var cellViewModels : BehaviorRelay<[AddressCollectionViewCellViewModel]> = BehaviorRelay(value: [])
    
    var addressDataMonthModel : BehaviorRelay<[AddressDataMonthModel]> = BehaviorRelay(value: [])
    var monthYearViewModel : BehaviorRelay<[AddressCollectionMonthYearViewModel]> = BehaviorRelay(value: [])
 
    var addressDataModel : AddressDataModel = AddressDataModel()
    var currentMonthYear = MonthYear()
    
    let api: Provider<MultiTarget>
    private(set) var rootViewModel: RootViewModel
    private let limit: Int = 50
    private let rooms = Int.random(in: 1..<20)
    private var randomPic = [String]()
    private var defaultCellViewModels = [AddressCollectionViewCellViewModel]()
    private var editState = false
    private var addressId = ""
    
    let disposeBag = DisposeBag()
    init(rootViewModel : RootViewModel = RootViewModel(), api: Provider<MultiTarget> = ProviderAPIWithAccessToken<MultiTarget>()) {
        self.api = api
        self.rootViewModel = rootViewModel
        super.init()
        bindToEvents()
    }

    private func convertMonthYear(monthYear: String?) -> MonthYear {
        var monthYearData = MonthYear()
        if let monthYear = monthYear?.split(separator: "-"),
            monthYear.count > 1{
            if let month = Int(monthYear[0]), let year = Int(monthYear[1]) {
                monthYearData = MonthYear(month: month,
                                          year: year)
            }
           
        }
        return monthYearData
    }
    func bindToEvents() {
        addressDataMonthModel.map {data in
            data.map {cell in
                let monthYearData = self.convertMonthYear(monthYear: cell.monthYear)
                
                let roomData = cell.roomData.map { data in
                    data.map { cell in
                        return AddressCollectionViewCellViewModel(
                            id: cell.id,
                            roomNums: cell.roomNums,
                            renters: cell.renters,
                            status: cell.status,
                            waterNum: cell.waterNum,
                            lastWaterNum: cell.lastWaterNum,
                            electricNum: cell.electricNum,
                            lastElectricNum: cell.lastElectricNum,
                            totalNum: cell.totalNum)
                    }
                }
                return AddressCollectionMonthYearViewModel(monthYear: monthYearData,
                                                           cellViewModels: roomData ?? [])
            }
        }.bind(to: monthYearViewModel).disposed(by: disposeBag)
    }
    
    func setRootViewModel(rootViewModel : RootViewModel = RootViewModel()){
        self.rootViewModel = rootViewModel
    }
    func setAddresId(id: String){
        addressId = id
    }
    
    func getMonthYearData() {
        #if STG
        createStubData()
        #endif
        
        rootViewModel.handleProgress(true)
        api.request(MultiTarget(AddressCollectionTarget.getAddressData(id: self.addressId)))
            .map(AddressModel.self, using: JSONDecoder.decoderAPI(), failsOnEmptyData: false)
            .subscribe {[weak self] event in
                guard let self = self else { return }
                switch event {
                case .success(let value):
                    if let addressData = value.data {
                        self.addressDataModel = addressData
                        if let data = addressData.data {
                            self.addressDataMonthModel.accept(data)
                        }
                    }
                    
                    SVProgressHUD.dismiss()
                case .failure(let error):
                    self.rootViewModel.alertModel.accept(AlertModel(message: error.localizedDescription))
                    SVProgressHUD.dismiss()
                    break
                }
            }.disposed(by: disposeBag)
    }
    
    func getData(date: MonthYear){
        currentMonthYear = date
        var data = [AddressCollectionViewCellViewModel]()
        let checkData = monthYearViewModel.value.contains(where: { $0.monthYear == date})
        if (checkData){
            if let cellViewModel = monthYearViewModel.value.filter({$0.monthYear == date}).first?.cellViewModels {
                data = cellViewModel
                defaultCellViewModels = data
                cellViewModels.accept(data)
            }
        } else if ( monthYearViewModel.value.contains(where: { $0.monthYear == date - 1})) {
            createNewMonthYearData(date: currentMonthYear)
        }
        
        defaultCellViewModels = data
        cellViewModels.accept(data)
    }
    
    func updateAddressData(roomReqData: [[String:Any]]){
        rootViewModel.handleProgress(true)
        api.request(MultiTarget(
            AddressCollectionTarget.updateAddressData(id: self.addressId,
                                                      data: roomReqData)))
        .map(ReturnBlankModel.self, using: JSONDecoder.decoderAPI(), failsOnEmptyData: false)
            .subscribe {[weak self] event in
                guard let self = self else { return }
                switch event {
                case .success(_):
                    if let data = self.addressDataModel.data {
                        self.addressDataMonthModel.accept(data)
                    }
                    
                    SVProgressHUD.dismiss()
                case .failure(let error):
                    self.rootViewModel.alertModel.accept(AlertModel(message: error.localizedDescription))
                    SVProgressHUD.dismiss()
                    break
                }
            }.disposed(by: disposeBag)
    }
    
    func getDropdownData(){
        let data = [AddressCollectionDropDownCellViewModel(image: UIImage(systemName: "book.fill"),
                                                           title: Language.localized("addData")),
                    AddressCollectionDropDownCellViewModel(image: UIImage(systemName: "info.circle.fill"),
                                                           title:  Language.localized("getInfo"))]
        
        let cellData = [AddressCollectionDropDownCellViewModel(image: UIImage(named: "yesSymbol"),
                                                               title: Language.localized("yesSymbolText"),
                                                               imageHeight: 40),
                        AddressCollectionDropDownCellViewModel(image: UIImage(named: "pendingSymbol"),
                                                               title:  Language.localized("pendingSymbolText"),
                                                               imageHeight: 40),
                        AddressCollectionDropDownCellViewModel(image: UIImage(named: "vacancySymbol"),
                                                               title:  Language.localized("vacancySymbolText"),
                                                               imageHeight: 40)]
        
        dropdownCellViewModels.accept(data)
        collectionViewCellDropdownCellViewModels.accept(cellData)
    }
    
    func getRadioData(){
        let cell = [AddressCollectionRadioViewCellViewModel(title: Language.localized("radioAll"),type: "ALL"),
                    AddressCollectionRadioViewCellViewModel(title: Language.localized("radioUnPaid"),type: "UNPAID"),
                    AddressCollectionRadioViewCellViewModel(title: Language.localized("radioPaid"),type: "PAID"),
                    AddressCollectionRadioViewCellViewModel(title: Language.localized("radioVancancy"),type: "VACANCY")
        ]
        
        let data = AddressCollectionRadioViewModel(cellViewModels: cell)
        radioViewModels.accept(data)
    }
    
    func handlePressData(index : IndexPath){
        self.rootViewModel.pushViewModel.accept(PushModel(viewController: DetailScreenViewController(),
                                                          title: Language.localized("roomDetailTitle") + " " + String(cellViewModels.value[index.row].roomNums ?? 0)))
    }
}

extension AddressCollectionViewModel {
    func getState() -> Bool{
        return editState
    }
    
    func changeState(value : Bool){
        editState = value
    }
}
extension AddressCollectionViewModel {
    func sortData(interator: Int){
        switch radioViewModels.value.cellViewModels?[interator].type {
        case "ALL":
            cellViewModels.accept(defaultCellViewModels)
        case "PAID":
            let sortedData = defaultCellViewModels.filter { data in
                return data.status == "Paid"
            }
            cellViewModels.accept(sortedData)
        case "VACANCY" :
            let sortedData = defaultCellViewModels.filter { data in
                return data.status == "Vacancy"
            }
            cellViewModels.accept(sortedData)
            
        default:
            let sortedData = defaultCellViewModels.filter { data in
                return data.status == "Pending" || data.status == "NotPaid"
            }
            cellViewModels.accept(sortedData)
        }
    }
}

//Reload Data when RoomView Data Changed
extension AddressCollectionViewModel{
    func updateAddressDataModel(roomData: [RoomDataModel], monthYear: MonthYear, nextRoom : [RoomDataModel]?) {
        var returnData = [[String:Any]]()
        if let pos = self.addressDataModel.data?.firstIndex(where: { data in
            let monthYearData = self.convertMonthYear(monthYear: data.monthYear)
            return monthYearData == monthYear
        }) {
            let addressData = self.addressDataModel
            
            addressData.data?[pos].roomData = roomData
    
            returnData.append(RoomDataReqModel(
                monthYear: "\(monthYear.month)-\(monthYear.year)",
                roomData: roomData).json() ?? [:])
            if let nextRoom = nextRoom,
               let nextPos = self.addressDataModel.data?.firstIndex(where: { data in
                let monthYearData = self.convertMonthYear(monthYear: data.monthYear)
                return monthYearData == monthYear + 1
            }){
                addressData.data?[nextPos].roomData = nextRoom
                let nextMonth = monthYear + 1
                
                returnData.append(RoomDataReqModel(
                    monthYear: "\(nextMonth.month)-\(nextMonth.year)",
                    roomData: roomData).json() ?? [:])
            }
            self.addressDataModel = addressData
            self.updateAddressData(roomReqData: returnData)
        }
    }
}


//Create new MonthYear Data
extension AddressCollectionViewModel {
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
    
    func createNewMonthYearData(date : MonthYear) {
        if let cellViewModel = addressDataMonthModel.value.filter({ cell in
                let monthYear = convertMonthYear(monthYear: cell.monthYear)
                return monthYear == date - 1
            }).first,
            let lastData = cellViewModel.roomData {
            var currentData = [RoomDataModel]()
            for roomData in lastData {
                let newRoomData = RoomDataModel(
                    id : roomData.id,
                    status: roomData.status == "Vacancy" ?
                    roomData.status : "NotPaid",
                    roomNums: roomData.roomNums,
                    renters: roomData.renters,
                    quota: roomData.quota,
                    quotaPrice: roomData.quotaPrice,
                    waterPrice: roomData.waterPrice,
                    waterNum: roomData.waterNum,
                    lastWaterNum: roomData.waterNum,
                    electricPrice: roomData.electricPrice,
                    electricNum: roomData.electricNum,
                    lastElectricNum: roomData.electricNum,
                    roomPrice: roomData.roomPrice,
                    totalNum: 0,
                    internetPrice: roomData.internetPrice,
                    trashPrice: roomData.trashPrice)
                
                let total = calculateTotal(cell: newRoomData)
                newRoomData.totalNum = total[0]
                currentData.append(newRoomData)
            }
            let monthString = "\(date.month)-\(date.year)"
            addressDataModel.data?
                .append(AddressDataMonthModel(
                    monthYear: monthString,
                    globalElectric: cellViewModel.globalElectric,
                    globalWater: cellViewModel.globalWater,
                    globalQuotaPrice: cellViewModel.globalQuotaPrice,
                    globalQuota: cellViewModel.globalQuota,
                    globalRoomPrice: cellViewModel.globalRoomPrice,
                    roomData: currentData))
            
            if let data = addressDataModel.data {
                self.addressDataMonthModel.accept(data)
            }
        }
    }
}
// Create Dummy data
extension AddressCollectionViewModel {
    func createStubData(){
        let monthYear = MonthYear() - 1
        let totalRoom = Int.random(in: 6..<20)
        var roomData : [String:Any] = ["address" : "99/4A, KP2A, P. Dong Hung Thuan, Q12, TP.Ho Chi Minh",
                                       "totalRoom" : totalRoom]
        
        var lastWater = Array(repeating: 0, count: totalRoom)
        var lastElectric = Array(repeating: 0, count: totalRoom)
        
        var dataTemp = [[String : Any]]()
        for interator in 0...12 {
            let currentMonth = monthYear - 12 + interator
            let monthString = "\(currentMonth.month)-\(currentMonth.year)"
            var data : [String:Any] = ["monthYear" : monthString,
                                       "globalElectric" : 3000,
                                       "globalWater" : 7000,
                                       "globalQuota" : 4,
                                       "globalQuotaPrice": 3000,
                                       "globalRoomPrice": Int.random(in: 1500000..<2000000).roundNumber(numberOfZero: 5, type: .toNearestOrEven)]
            
            let status = ["Paid", "Pending", "NotPaid","Vacancy"]

            var roomDataTemp = [[String : Any]]()
            for roomNum in 0..<totalRoom {
                var roomData : [String:Any] = [:]

                let quota = data["globalQuota"] as! Int
                let quotaPrice = data["globalQuotaPrice"] as! Int
                let roomPrice = data["globalRoomPrice"] as! Int
                
                let waterNum = lastWater[roomNum] + Int.random(in: 5..<40)
                let waterPrice = data["globalWater"] as! Int
                let lastWaterNum = lastWater[roomNum]
                lastWater[roomNum] = waterNum
                
                let electricNum = lastElectric[roomNum] + Int.random(in: 5..<40)
                let electricPrice = data["globalElectric"] as! Int
                let lastElectricNum = lastElectric[roomNum]
                lastElectric[roomNum] = electricNum
                
                let trashOdd = Int.random(in: 0...1)
                let internetOdd = Int.random(in: 0...1)
                roomData["status"] = status[Int.random(in: 0..<status.count)]
                roomData["roomNums"] = roomNum + 1
                roomData["id"] = String(roomNum + 1)
                roomData["renters"] = Int.random(in: 1..<5)
                roomData["quota"] = data["globalQuota"]
                roomData["quotaPrice"] = data["globalQuotaPrice"]
                
                roomData["waterNum"] = waterNum
                roomData["waterPrice"] = waterPrice
                roomData["lastWaterNum"] = lastWaterNum
                
                roomData["electricNum"] = electricNum
                roomData["electricPrice"] = electricPrice
                roomData["lastElectricNum"] = lastElectricNum
                
                roomData["roomPrice"] = roomPrice
                
                if (trashOdd == 1) {
                    roomData["trashPrice"] = 100000
                }
                
                if (internetOdd == 1) {
                    roomData["internetPrice"] = 200000
                }
    
                var water = 0
                if (waterNum - lastWaterNum > quota){
                    let usedWater = waterNum - lastWaterNum
                    water = ((usedWater - quota) * quotaPrice) + (usedWater * waterPrice)
                }
                else {
                    water = (waterNum - lastWaterNum) * waterPrice
                }
                let total = roomPrice + ((electricNum - lastElectricNum)*electricPrice) + water
                roomData["totalNum"] = total
                
                roomDataTemp.append(roomData)
            }
            data["roomData"] = roomDataTemp
            dataTemp.append(data)
        }

        roomData["data"] = dataTemp
        
        let response : [String:Any] =
        ["statusCode" : 200,
         "data" : roomData,
         "messageVN": "Login sucessfully!",
         "messageEN": "Đăng nhập thành công!"]
        
        var host: String = Environment.shared.configuration(.apiHost)
        let path: String = Environment.shared.configuration(.apiPath)
        
        host = host.deletingPrefix("https://")
        host = host.deletingPrefix("http://")
        host = host.replacingOccurrences(of: "/", with: "")
       
//        stub(condition: isHost("\(baseURl)") &&  isPath("/api/getaddress")) { _ in
        stub(condition: isPath("/\(path)address/\(addressId)/get")) { _ in
            
            return HTTPStubsResponse(jsonObject: response, statusCode: 200, headers: ["Authorization": "Bearer \(PrefsImpl.default.getAccessToken() ?? "")"])
        }
    }
}

