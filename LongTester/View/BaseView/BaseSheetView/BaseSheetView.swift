//
//  BaseSheetView.swift
//  LongTester
//
//  Created by Long on 5/18/23.
//

import Foundation
import UIKit
import SnapKit
class BaseSheetView : UIView {
    enum SheetSize {
        case fixed(CGFloat)
        case fullscreen
        case percent(CGFloat)
    }
    
    private var baseVC : UIViewController?
    @IBOutlet weak var sheetView : UIView!
    @IBOutlet weak var backgroundView : UIView!
    @IBOutlet weak var sheetHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var closeBtnSizeConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var infoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dragView: UIView!
    @IBOutlet weak var sheetViewLeadingConstraint: NSLayoutConstraint!
    
    private var isExpand = false
    private var isBaseView = false
    public var size : SheetSize = .fullscreen {
        didSet{
            changeSheetHeight()
        }
    }
    
    public var leadingConstraint : CGFloat = 0 {
        didSet {
            sheetViewLeadingConstraint.constant = leadingConstraint
        }
    }
    public var useDefaultCloseBtn : Bool = true {
        didSet{
            changeExitBtnLayout()
            checkInfoHeight()
        }
    }
    
    public var draggableSheet : Bool = true {
        didSet{
            checkDraggable()
        }
    }

    public var title : String? {
        didSet{
            titleLbl.text = title
            checkInfoHeight()
        }
    }
    
    public var hideOnClick : Bool = false {
        didSet{
            if (hideOnClick) {
                if let gestures = backgroundView.gestureRecognizers {
                    if (gestures.isEmpty) {
                        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissableViewTapped))
                        backgroundView.addGestureRecognizer(gestureRecognizer)
                    }
                }
                else {
                    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissableViewTapped))
                    backgroundView.addGestureRecognizer(gestureRecognizer)
                }
            }
            else {
                if let gestures = backgroundView.gestureRecognizers {
                    if (!gestures.isEmpty) {
                        for gesture in gestures {
                            backgroundView.removeGestureRecognizer(gesture)
                        }
                    }
                }
            }
        }
    }
    
    
    public var animate : Bool = true 
    
    init(frame: CGRect, size : SheetSize, baseVC : UIViewController, view : UIView) {
        super.init(frame: frame)
        commonInit()
        
        
        self.baseVC = baseVC
        self.size = size
        
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.tag = 9182
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hideOnClick = true
        changeSheetHeight()
        changeExitBtnLayout()
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
        setupUI()
        setGesture()
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
    
    func setGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dragViewTapped))
        self.dragView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dragViewTapped() {
        isExpand = !isExpand
        if (self.isExpand){
            
            changeSheetHeight(.fullscreen)
//            DispatchQueue.main.async {
//                if let baseVC = self.baseVC {
//                    UIView.animate(withDuration: 0.3) {
//                        let guide = baseVC.view.safeAreaLayoutGuide
//                        let height = guide.layoutFrame.size.height
//                        let bottomSafe = baseVC.view.safeAreaInsets.bottom
//                        self.sheetHeightConstraint.constant = height + bottomSafe
//
//                        if let navigationHidden = baseVC.navigationController?.navigationBar.isHidden {
//                            self.sheetHeightConstraint.constant =  self.sheetHeightConstraint.constant + (navigationHidden ? 0 : 44)
//                        }
//                        self.layoutIfNeeded()
//                    } completion: { _ in }
//                }
//            }
        }
        else {
            UIView.animate(withDuration: 0.3) {
                self.changeSheetHeight()
                self.layoutIfNeeded()
            } completion: { _ in }
           
        }
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
    
    private func setupUI(){
        closeBtn.setTitle("", for: .normal)
        dragView.layer.cornerRadius = 3
        UIView.animate(withDuration: 3, delay: 0.0, options: [.repeat, .autoreverse, .allowUserInteraction]) { [self] in
            dragView.alpha = 0.3
        }
        
        self.sheetView.layer.cornerRadius = 30
        sheetView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        sheetView.layer.masksToBounds = true
//        DispatchQueue.main.async {
//           self.sheetView.roundCorners([.topLeft, .topRight], radius: 30)
//        }
        
        
    }
    
    private func changeExitBtnLayout(){
        closeBtnSizeConstraint.constant = useDefaultCloseBtn ? 30 : 0
        closeBtn.isUserInteractionEnabled = useDefaultCloseBtn
        closeBtn.isHidden = !useDefaultCloseBtn
    }
    
    private func checkInfoHeight(){
        if (title == nil && useDefaultCloseBtn == false) {
            infoViewHeight.constant = 10
        }
        else {
            infoViewHeight.constant = 40
        }
    }
    
    private func checkDraggable(){
        dragView.isHidden = !draggableSheet
        dragView.isUserInteractionEnabled = draggableSheet
    }
    
    @objc func dismissableViewTapped() {
        close()
    }
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        if useDefaultCloseBtn {
            close()
        }
    }
}

extension BaseSheetView {
    func open(){
        if (baseVC?.navigationController?.navigationBar.layer.zPosition == 0){
            isBaseView = true
        }
        
        self.baseVC?.view.addSubview(self)
        self.baseVC?.view.bringSubviewToFront(self)
//        baseVC?.navigationController?.navigationBar.layer.zPosition = -2
//        baseVC?.navigationController?.navigationBar.isUserInteractionEnabled = false
        if animate {
            sheetView.alpha = 0
            sheetHeightConstraint.constant = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIView.animate(withDuration: 0.3) {
                    self.sheetView.alpha = 1
                    
                    self.changeSheetHeight()
                    self.layoutIfNeeded()
                } completion: { _ in }
            }
        }
    }
    
    func close(){
        if animate {
            UIView.animate(withDuration: 0.3) {
                self.sheetView.alpha = 0
                self.sheetHeightConstraint.constant = 0
                self.layoutIfNeeded()
            } completion: { _ in
//                self.baseVC?.navigationController?.navigationBar.layer.zPosition = 0
//                self.baseVC?.navigationController?.navigationBar.isUserInteractionEnabled = true
                self.removeFromSuperview()
            }
        }
    }
}
