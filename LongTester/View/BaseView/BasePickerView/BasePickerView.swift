//
//  BasePickerView.swift
//  LongTester
//
//  Created by Long on 6/1/23.
//

import Foundation
import UIKit

protocol BasePickerViewDelegate : AnyObject {
    func didSelectIndex(index: Int, id: String?)
}
class BasePickerView :UIView{
    enum SheetSize {
        case fixed(CGFloat)
        case fullscreen
        case percent(CGFloat)
    }
    weak var delegate : BasePickerViewDelegate?
    private var baseVC : UIViewController?
    private var isBaseView = false
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var sheetHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pickerView: PickerView!
    
    public var size : SheetSize = .fullscreen {
        didSet{
            changeSheetHeight()
        }
    }
    public var viewModel : [PickerViewModel] = [] {
        didSet{
            setupPicker()
        }
    }

    public var selectedIndex : Int = 0 {
        didSet{
            setupPicker()
        }
    }
    
    var cellHeight : CGFloat = 50 {
        didSet{
            setupPicker()
        }
    }
    
    var pickerType : PickerView.PickerType = .withImage {
        didSet{
            setupPicker()
        }
    }
    public var animate : Bool = true
    
    init(frame: CGRect, size : SheetSize, baseVC : UIViewController) {
        super.init(frame: frame)
        self.baseVC = baseVC
        self.size = size
        
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        changeSheetHeight()
//        changeExitBtnLayout()
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            if (isBaseView) {
                self.baseVC?.navigationController?.navigationBar.layer.zPosition = 0
                self.baseVC?.navigationController?.navigationBar.isUserInteractionEnabled = true
            }
        }
        else {
            baseVC?.navigationController?.navigationBar.layer.zPosition = -2
            baseVC?.navigationController?.navigationBar.isUserInteractionEnabled = false
        }
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
        setupBtn()
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        let index = pickerView.getCurrentIndex()
        
        delegate?.didSelectIndex(index: index,id: viewModel[index].id)
        close()
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        close()
    }
    private func setupBtn(){
        cancelBtn.setTitleColor(Color.normalTextColor, for: .normal)
        cancelBtn.setTitle(Language.localized("cancelBtn"), for: .normal)
        
        doneBtn.setTitleColor(Color.normalTextColor, for: .normal)
        doneBtn.setTitle(Language.localized("doneBtn"), for: .normal)
    }
    
    func setupPicker(){
        pickerView.setCellViewModel(viewModel: viewModel)
        pickerView.selectedIndex(index: selectedIndex)
        pickerView.cellHeight = self.cellHeight
        pickerView.pickerType = self.pickerType
        pickerView.commonSetup()
    }
    private func changeSheetHeight(_ tempSize : SheetSize? = nil ){
        var holdSize = self.size
        if let tempSize = tempSize {
            holdSize = tempSize
        }
        
        switch holdSize {
        case .fullscreen:
            if let baseVC = self.baseVC {
                UIView.animate(withDuration: 0.3) {
                    let guide = baseVC.view.safeAreaLayoutGuide
                    let height = guide.layoutFrame.size.height
                    let bottomSafe = baseVC.view.safeAreaInsets.bottom
                    self.sheetHeightConstraint.constant = height + bottomSafe
                    
                    if let navigationHidden = baseVC.navigationController?.navigationBar.isHidden {
                        self.sheetHeightConstraint.constant =  self.sheetHeightConstraint.constant + (navigationHidden ? 0 : 44)
                    }
                    self.layoutIfNeeded()
                } completion: { _ in }
            }
        case let .fixed(height):
            sheetHeightConstraint.constant = height
        case let .percent(percent):
            if (percent > 1 || percent < 0){
                break
            }
            sheetHeightConstraint.constant = (baseVC?.view.frame.height ?? 0) * percent
        }
    }
    
    
}

extension BasePickerView {
    func open(){
        if (baseVC?.navigationController?.navigationBar.layer.zPosition == 0){
            isBaseView = true
        }
        self.baseVC?.view.addSubview(self)
        self.baseVC?.view.bringSubviewToFront(self)
        if animate {
            contentView.alpha = 0
            sheetHeightConstraint.constant = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIView.animate(withDuration: 0.3) {
                    self.contentView.alpha = 1
                    self.changeSheetHeight()
                    self.layoutIfNeeded()
                } completion: { _ in }
            }
        }
    }
    
    func close(){
        if animate {
            UIView.animate(withDuration: 0.3) {
                self.contentView.alpha = 0
                self.sheetHeightConstraint.constant = 0
                self.layoutIfNeeded()
            } completion: { _ in
                self.removeFromSuperview()
            }
        }
    }
}


