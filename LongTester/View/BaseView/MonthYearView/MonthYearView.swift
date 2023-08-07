//
//  MonthYearView.swift
//  LongTester
//
//  Created by Long on 5/22/23.
//

import Foundation
import UIKit


protocol MonthYearViewDelegate : AnyObject {
    func didSelectDate(value: Date)
}
class MonthYearView :UIView{
    enum SheetSize {
        case fixed(CGFloat)
        case fullscreen
        case percent(CGFloat)
    }
    
    private var baseVC : UIViewController?
    private var isBaseView = false
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var sheetHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var monthYearPickView: MonthYearPickerView!
    
    weak var delegate : MonthYearViewDelegate?
    public var size : SheetSize = .fullscreen {
        didSet{
            changeSheetHeight()
        }
    }
    public var minDate : MonthYear = MonthYear() - 12 {
        didSet{
            setupPicker()
        }
    }
    
    public var maxDate : MonthYear = MonthYear() {
        didSet{
            setupPicker()
        }
    }
    
    public var selectedDate : MonthYear = MonthYear() {
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
    
    private func setupBtn(){
        cancelBtn.setTitleColor(Color.normalTextColor, for: .normal)
        cancelBtn.setTitle(Language.localized("cancelBtn"), for: .normal)
        
        doneBtn.setTitleColor(Color.normalTextColor, for: .normal)
        doneBtn.setTitle(Language.localized("doneBtn"), for: .normal)
    }
    
    func setupPicker(){
        monthYearPickView.setMinDate(date: minDate)
        monthYearPickView.setMaxDate(date: maxDate)
        monthYearPickView.selectedDate(date: selectedDate)
        monthYearPickView.commonSetup()
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
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        close()
    }
    @IBAction func doneBtnPressed(_ sender: Any) {
        let year = monthYearPickView.year
        let month = monthYearPickView.month
        let date = Date("\(year)-\(month)-01")
        
        delegate?.didSelectDate(value: date)
        close()
    }
    
}

extension MonthYearView {
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

