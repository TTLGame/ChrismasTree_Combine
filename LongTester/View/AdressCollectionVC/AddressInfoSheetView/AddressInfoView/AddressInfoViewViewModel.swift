//
//  AddressInfoViewViewModel.swift
//  LongTester
//
//  Created by Long on 5/20/23.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

struct AddressInfoViewTableHeaderViewModel {
    var title : String
    var cellViewModels : [AddressInfoViewCellViewModel]
}
class AddressInfoViewViewModel : NSObject {
    var cellViewModels : BehaviorRelay<[AddressInfoViewTableHeaderViewModel]> = BehaviorRelay(value: [])
    let api: Provider<MultiTarget>
    private(set) var rootViewModel: RootViewModel


    var addressDataMonthModel : BehaviorRelay<[AddressDataMonthModel]> = BehaviorRelay(value: [])
    var addressDataModel : AddressDataModel = AddressDataModel()
    var currentMonthYear = MonthYear()
    
    let disposeBag = DisposeBag()
    init(rootViewModel : RootViewModel = RootViewModel(), api: Provider<MultiTarget> = ProviderAPIBasic<MultiTarget>()) {
        self.api = api
        self.rootViewModel = rootViewModel
        super.init()
        
    }
    
    func setupData(){
        if let data = addressDataModel.data {
            self.addressDataMonthModel.accept(data)
        }
    }
    func getData(date: MonthYear){
        currentMonthYear = date

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
                
                let currentCellData = mainCellData.filter {$0.status != "Vacancy"}
                let vacanCellData = mainCellData.filter {$0.status == "Vacancy"}
                
                var waterMoneyText = ""
                if let waterMax = mainCellData.max(by: {$0.waterPrice ?? 0 < $1.waterPrice ?? 0})?.waterPrice,
                   let waterMin = mainCellData.max(by: {$0.waterPrice ?? 0 > $1.waterPrice ?? 0})?.waterPrice {
                    waterMoneyText = waterMin == waterMax ? waterMax.formatnumberWithDot() + " VND" :
                    "\(waterMin.formatnumberWithDot()) - \(waterMax.formatnumberWithDot()) VND"
                }
                
                var electricMoneyText = ""
                if let electricMax = mainCellData.max(by: {$0.electricPrice ?? 0 < $1.electricPrice ?? 0})?.electricPrice,
                   let electricMin = mainCellData.max(by: {$0.electricPrice ?? 0 > $1.electricPrice ?? 0})?.electricPrice {
                    electricMoneyText = electricMin == electricMax ? electricMax.formatnumberWithDot() + " VND" :
                    "\(electricMin.formatnumberWithDot()) - \(electricMax.formatnumberWithDot()) VND"
                }
                
                var renterText = ""
                if let renterMax = mainCellData.max(by: {$0.renters ?? 0 < $1.renters ?? 0})?.renters,
                   let renterMin = mainCellData.max(by: {$0.renters ?? 0 > $1.renters ?? 0})?.renters {
                    renterText = renterMin == renterMax ? String(renterMax) :
                                                            "\(renterMin) - \(renterMax)"
                }

                let rent = currentCellData.map({$0.totalNum ?? 0}).reduce(0, +)
                    
                var advWater = 0
                var advElectric = 0
                var averageIncome = 0
                let totalSumWater = currentCellData.map({($0.waterNum ?? 0) - ($0.lastWaterNum ?? 0)}).reduce(0, +)
                let totalSumElectric = currentCellData.map({($0.electricNum ?? 0) - ($0.lastElectricNum ?? 0)}).reduce(0, +)
                
                if (currentCellData.count != 0) {
                    advWater = totalSumWater / currentCellData.count
                
                    advElectric = totalSumElectric / currentCellData.count
                    averageIncome = rent / currentCellData.count
                }
             
                let infoCell : [AddressInfoViewCellViewModel] =
                [AddressInfoViewCellViewModel(title: Language.localized("address"),
                                              value: addressDataModel.address),
                 AddressInfoViewCellViewModel(title: Language.localized("totalRoom"),
                                              value: "\(currentCellData.count)/\(currentCellData.count + vacanCellData.count)"),
                 AddressInfoViewCellViewModel(title: Language.localized("averageRenters"),
                                              value: renterText),
                 AddressInfoViewCellViewModel(title: Language.localized("globalWater"),
                                              value: (monthYearData.globalWater?.formatnumberWithDot() ?? "0") + " VND"),
                 AddressInfoViewCellViewModel(title: Language.localized("globalElectric"),
                                              value: (monthYearData.globalElectric?.formatnumberWithDot() ?? "0") + " VND"),
                 AddressInfoViewCellViewModel(title: Language.localized("globalPrice"),
                                              value: (monthYearData.globalRoomPrice?.formatnumberWithDot() ?? "0") + " VND")
                ]
                
                let infoHeaderCell = AddressInfoViewTableHeaderViewModel(title: Language.localized("facilityInfo"),
                                                                         cellViewModels: infoCell)
                
                let comsumptionCell : [AddressInfoViewCellViewModel] =
                [AddressInfoViewCellViewModel(title: Language.localized("averageWaterComsumption"),
                                              value: String(advWater)),
                 
                 AddressInfoViewCellViewModel(title: Language.localized("totalWaterComsumption"),
                                               value: String(totalSumWater),
                                               shouldHighlightTitle: true),
                 
                 AddressInfoViewCellViewModel(title: Language.localized("waterUnit"),
                                              value: waterMoneyText),
                 
                 AddressInfoViewCellViewModel(title: Language.localized("averageElectricComsumption"),
                                              value: String(advElectric)),
                 
                 AddressInfoViewCellViewModel(title: Language.localized("totalElectricComsumption"),
                                              value: String(totalSumElectric),
                                              shouldHighlightTitle: true),
                 
                 AddressInfoViewCellViewModel(title: Language.localized("electricUnit"),
                                              value: electricMoneyText),
                 
                 AddressInfoViewCellViewModel(title: Language.localized("averageIncome"),
                                              value: averageIncome.formatnumberWithDot() + " VND",
                                              shouldHighlightTitle: true),
                 
                 AddressInfoViewCellViewModel(title: Language.localized("totalRent"),
                                              value: rent.formatnumberWithDot() + " VND",
                                              shouldHighlightTitle: true,
                                              shouldHighlightValue: true)
                 
                ]
                let comsumptionHeaderCell = AddressInfoViewTableHeaderViewModel(title: Language.localized("consumptionInfo"),
                                                                         cellViewModels: comsumptionCell)
                
                cellViewModels.accept([infoHeaderCell,comsumptionHeaderCell])
            }
        }
    }
}
