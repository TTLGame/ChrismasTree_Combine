//
//  MainScreenViewModel.swift
//  LongTester
//
//  Created by Long on 12/28/22.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import SVProgressHUD
import OHHTTPStubs

class MainScreenViewModel : NSObject {
    private(set) var mainViewDataModel : BehaviorRelay<[MainViewDataModel]> = BehaviorRelay(value: [])
    var cellViewModels : BehaviorRelay<[MainScreenCellViewModel]> = BehaviorRelay(value: [])
    var dropdownCellVM : BehaviorRelay<[AddressCollectionDropDownCellViewModel]> = BehaviorRelay(value: [])
    
    var longA : PublishSubject<Int> = PublishSubject()
    var willAddMore : BehaviorRelay<Int> = BehaviorRelay(value: 0)
    
    var baseVC : BaseViewController? {
        didSet {
            resetPopup()
        }
    }
    var mainScreenPopUp : MainScreenAddMorePopUp!
    var customPopUp : CustomPopUp!
    
    let api: Provider <MultiTarget>
    let maxAddress = 5
    private(set) var rootViewModel: RootViewModel
    let limit: Int = 50
    
    private var randomPic = [String]()
    let disposeBag = DisposeBag()
    init(rootViewModel : RootViewModel = RootViewModel(), api: Provider<MultiTarget> = ProviderAPIWithAccessToken<MultiTarget>()) {
        self.api = api
        self.rootViewModel = rootViewModel
        super.init()
        addAllEnumType()
        bindToEvents()
    }
    
    private func resetPopup(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let baseVC = self.baseVC else { return }
            self.mainScreenPopUp = MainScreenAddMorePopUp(frame: baseVC.view.frame)
            self.customPopUp = CustomPopUp(frame: baseVC.view.frame, baseVC: baseVC, view: self.mainScreenPopUp)
            self.customPopUp.width = baseVC.view.frame.width * 0.9
            self.customPopUp.height =  500
            self.customPopUp.delegate = baseVC as? MainScreenViewController
        }
    }
    
    private func deleteMainViewModel(addressId: String){
        var data = mainViewDataModel.value
        if let index = data.firstIndex(where: { $0.id == addressId
        }) {
            data.remove(at: index)
            self.mainViewDataModel.accept(data)
        }
    }
    
    func updateCurrentAddressNumber(){
        self.mainViewDataModel.value.count < self.maxAddress ? self.willAddMore.accept(1) : self.willAddMore.accept(0)
    }
    
    func addAllEnumType(){
        for type in backbroundType.allCases {
            randomPic.append(type.rawValue)
        }
    }
    func bindToEvents() {
        mainViewDataModel.map {models in
            models.map {model in
                return MainScreenCellViewModel(logo: self.randomPic[Int.random(in: 0..<self.randomPic.count)],
                                               background: backbroundType(rawValue: self.randomPic[Int.random(in: 0..<self.randomPic.count)]),
                                               name: model.name,
                                               address: model.address,
                                               globalPrice: model.globalPrice,
                                               currentRooms: model.currentRooms,
                                               totalRooms: model.totalRooms)
            }
        }.bind(to: cellViewModels).disposed(by: disposeBag)
    }
    
    func getDropdownData(){
        let data = [AddressCollectionDropDownCellViewModel(
            image: UIImage(systemName: "trash"),
            title: Language.localized("delete"))]
        dropdownCellVM.accept(data)
    }
    

    func handleOpenCreatePopup(){
        customPopUp.open()
    }
    
    func handlePressData(index : IndexPath){
        if let addressId = mainViewDataModel.value[index.row].id {
            self.rootViewModel.pushViewModel.accept(PushModel(
                viewController: AddressCollectionViewController(
                    id: addressId,
                    background: cellViewModels.value[index.row].background?.rawValue ?? "PyramidBG"),
                title: Language.localized("addressCollectionMainTitle")))
        }
    }
    
    func handleDropdown(selectDropdownIndex: IndexPath, selectcellIndex : IndexPath){
        switch selectDropdownIndex.row {
        case 0:
            let alertModel = AlertModel.ActionModel(
                title: Language.localized("delete"),
                style: .default, handler: {_ in
                    self.deleteAddress(index: selectcellIndex)
                })
            let closeModel = AlertModel.ActionModel(
                title: Language.localized("cancelBtn"),
                style: .default, handler: {_ in
                })
            rootViewModel.alertModel.accept(AlertModel(
                actionModels: [closeModel,alertModel],
                title: "",
                message: Language.localized("deleteContent"),
                prefferedStyle: .alert))
            
        default :
            break
        }
    }
}

extension MainScreenViewModel {
    func getMainScreenData() {
        #if STG
        snub()
        #endif
        rootViewModel.handleProgress(true)
        api.request(MultiTarget(MainScreenTarget.getAddress))
            .map(MainViewModel.self, using: JSONDecoder.decoderAPI(), failsOnEmptyData: false)
            .subscribe {[weak self] event in
                guard let self = self else { return }
                switch event {
                case .success(let value):
                    if let value = value.data {
                        self.mainViewDataModel.accept(value)
                        self.rootViewModel.handleProgress(false)
                    }
                case .failure(let error):
                    self.rootViewModel.alertModel.accept(AlertModel(message: error.localizedDescription))
                    break
                }
                self.rootViewModel.handleProgress(false)
            }.disposed(by: disposeBag)
    }
    
    func createAddress(){
        if let data = mainScreenPopUp.returnViewModel() {
            rootViewModel.handleProgress(true)
            api.request(MultiTarget(MainScreenTarget
                .createAddress(quota: data.inputQuota,
                               quotaPrice: data.inputQuotaPrice,
                               roomPrice: data.inputRoomPrice,
                               waterPrice: data.inputWater,
                               electricPrice: data.inputElectric,
                               roomsNum: data.inputRooms,
                               address: data.inputAddress,
                               name: data.inputName)))
                .map(ReturnBlankModel.self, using: JSONDecoder.decoderAPI(), failsOnEmptyData: false)
                .subscribe {[weak self] event in
                    guard let self = self else { return }
                    switch event {
                    case .success(let value):
                        if let messageVN = value.messageVN,
                           let messageEN = value.messageEN{
                            self.rootViewModel.alertModel.accept(AlertModel(message: AppConfig.shared.language == .vietnamese ? messageVN : messageEN))
                            self.rootViewModel.handleProgress(false)
                            self.customPopUp.close()
                            
                            self.getMainScreenData()
//                            self.convertCellModel(data: data)
                            self.resetPopup()
                        }
                    case .failure(let error):
                        self.rootViewModel.alertModel.accept(AlertModel(message: error.localizedDescription))
                        SVProgressHUD.dismiss()
                        break
                    }
                }.disposed(by: disposeBag)
        }
        else {
            self.rootViewModel.alertModel.accept(AlertModel(message: Language.localized("fillError")))
        }
    }
    
    func deleteAddress(index: IndexPath) {
        guard let addressId = mainViewDataModel.value[index.row].id  else { return}
        rootViewModel.handleProgress(true)
        api.request(MultiTarget(MainScreenTarget.deleteAddress(id: addressId)))
            .map(ReturnBlankModel.self, using: JSONDecoder.decoderAPI(), failsOnEmptyData: false)
            .subscribe {[weak self] event in
                guard let self = self else { return }
                switch event {
                case .success(let value):
                    if let messageVN = value.messageVN,
                       let messageEN = value.messageEN{
                        self.rootViewModel.alertModel.accept(AlertModel(message: AppConfig.shared.language == .vietnamese ? messageVN : messageEN))
                        self.rootViewModel.handleProgress(false)
                        self.deleteMainViewModel(addressId: addressId)
                    }
                case .failure(let error):
                    self.rootViewModel.alertModel.accept(AlertModel(message: error.localizedDescription))
                    break
                }
                self.rootViewModel.handleProgress(false)
            }.disposed(by: disposeBag)
    }
}

extension MainScreenViewModel {
    func snub(){
        let roomData : [String:Any] =
        ["statusCode" : 200,
         "data" : [[
            "id": "33d80a7a-dabb-4eb7-9fb0-3d75a9c5ef07",
            "name": "Long Trinh",
            "address": "99/4A",
            "globalPrice": 1000000,
            "currentRooms": 1,
            "totalRooms": 10]],
         "messageVN": "Login sucessfully!",
         "messageEN": "Đăng nhập thành công!"]
        
        var host: String = Environment.shared.configuration(.apiHost)
        let path: String = Environment.shared.configuration(.apiPath)
        
        host = host.deletingPrefix("https://")
        host = host.deletingPrefix("http://")
        host = host.replacingOccurrences(of: "/", with: "")
        
        stub(condition: isHost("\(host)") &&  isPath("/\(path)address/get") && isScheme("https")) { _ in
    
            return HTTPStubsResponse(jsonObject: roomData, statusCode: 200, headers: ["Authorization": "Bearer \(PrefsImpl.default.getAccessToken() ?? "")"])
        }
    }
}
