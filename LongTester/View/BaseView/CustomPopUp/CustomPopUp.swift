//
//  CustomPopUp.swift
//  LongTester
//
//  Created by Long on 6/4/23.
//

import Foundation
import UIKit
import SnapKit

protocol CustomPopUpDelegate : AnyObject {
    func didPressAction()
    func didPressCancel()
}

extension CustomPopUpDelegate {
    func didPressCancel(){
        
    }
}
class CustomPopUp : UIView {
    private var isBaseView = false
    weak var delegate : CustomPopUpDelegate?
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var widthPopupConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightPopupConstraint: NSLayoutConstraint!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cancelView: UIView!
    private var baseVC : UIViewController?
    
    public var animate : Bool = true
    public var height : CGFloat = 400 {
        didSet{
            changePopupSize()
        }
    }
    public var width : CGFloat = 300 {
        didSet{
            changePopupSize()
        }
    }
    
    public var isIncludeCancelBtn = true {
        didSet {
            hideCancelBtn()
        }
    }
    init(frame: CGRect, baseVC : UIViewController, view : UIView) {
        super.init(frame: frame)
        commonInit()
        
        
        self.baseVC = baseVC
        
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.tag = 9182
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
    
    private func setup(){
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
        
        acceptBtn.setTitle(Language.localized("doneBtn"), for: .normal)
        cancelBtn.setTitle(Language.localized("cancelBtn"), for: .normal)
    }
    
    private func changePopupSize(){
        widthPopupConstraint.constant = width
        heightPopupConstraint.constant = height
    }
    
    private func hideCancelBtn() {
        cancelView.isHidden = true
    }
    @IBAction func acceptBtnPressed(_ sender: Any) {
        delegate?.didPressAction()
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        close()
        delegate?.didPressCancel()
    }
    
}

extension CustomPopUp {
    func open(){
        if (baseVC?.navigationController?.navigationBar.layer.zPosition == 0){
            isBaseView = true
        }
        
        self.baseVC?.view.addSubview(self)
        self.baseVC?.view.bringSubviewToFront(self)
        if animate {
            popupView.alpha = 0
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIView.animate(withDuration: 0.3) {
                    self.popupView.alpha = 1
                    self.layoutIfNeeded()
                } completion: { _ in }
            }
        }
    }
    
    func close(){
        if animate {
            UIView.animate(withDuration: 0.3) {
                self.popupView.alpha = 0
                self.layoutIfNeeded()
            } completion: { _ in
                self.removeFromSuperview()
            }
        }
    }
}
