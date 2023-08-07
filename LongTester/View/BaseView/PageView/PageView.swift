//
//  PageView.swift
//  LongTester
//
//  Created by Long on 5/26/23.
//

import Foundation
import UIKit
import SnapKit

class PageView : UIView {
    enum Direction {
        case forward
        case reverse
    }
    
    enum AnimateType {
        case none
        case faded
        case move(Direction)
    }
    
    enum viewType {
        case first
        case second
    }
    
    ///Animation type for pageView
    ///1 : none, set no animation for page View
    ///2: faded, set faded animation for page view
    ///3: move, set moving animation for page view, move have 2 enumerator Direction: fowrard and reverse
    var animeType : AnimateType = .faded
    
    ///Transition Views, first view will always be presented first
    var transitionViews : [UIView] = [] {
        didSet {
            self.currentViewPos = -1
            self.setInitView()
        }
    }
    
    @IBOutlet weak var secondViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondView: UIView!
    
    @IBOutlet weak var firstViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstView: UIView!
    
    @IBOutlet var contentView: UIView!
    
    
    private var currentViewPos : Int = -1
    private var currentActiveView: viewType = .first
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
        secondView.tag = 10
        firstView.tag = 11
    }
    
    private func setInitView(){
        for view in self.firstView.subviews {
            view.removeFromSuperview()
        }
        
        for view in self.secondView.subviews {
            view.removeFromSuperview()
        }
        
        self.presentView(interator: 0)
    }
    
    private func changeView(currentView: UIView?, changeView: UIView?){
        guard let currentView = currentView ,
              let changeView = changeView else { return }
        for view in currentView.subviews {
            view.removeFromSuperview()
        }
        
        contentView?.bringSubviewToFront(changeView)
        
                
        switch self.animeType {
        case .faded :
            currentView.alpha = 1
        case .move(_):
            let currentContraint = currentActiveView == .first ? firstViewLeadingConstraint :                                                            secondViewLeadingConstraint
            currentContraint?.constant = 0
        default:
            break
        }
        
        currentActiveView = currentActiveView == .first ? .second : .first
    }
    
    private func animteView(currentView: UIView?, changeView: UIView?, interator: Int){
        UIView.animate(withDuration: 0.2) {
            switch self.animeType {
            case .faded :
                currentView?.alpha = 0
            case let .move(type):
                let currentContraint = self.currentActiveView == .first ? self.firstViewLeadingConstraint :                                                self.secondViewLeadingConstraint
                let moveContraint = type == .forward ? self.frame.width : -self.frame.width
                if let currentContraint = currentContraint {
                    currentContraint.constant += moveContraint
                }
            default:
                break
            }
            self.layoutIfNeeded()
        } completion: { _ in
            
            self.currentViewPos = interator
            self.changeView(currentView: currentView, changeView: changeView)
        }
    }
}

extension PageView {
    func presentView(interator: Int){
        if (currentViewPos == interator || interator >= transitionViews.count) {
            return
        }
        
        let currentView = currentActiveView == .first ? firstView : secondView
        let changeView = currentActiveView == .first ? secondView : firstView

        changeView?.addSubview(self.transitionViews[interator])
        self.transitionViews[interator].snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.animteView(currentView: currentView, changeView: changeView, interator: interator)
    }
}
