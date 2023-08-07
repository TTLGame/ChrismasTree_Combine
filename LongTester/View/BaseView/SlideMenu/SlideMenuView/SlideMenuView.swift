//
//  SlideMenuView.swift
//  LongTester
//
//  Created by Long on 4/19/23.
//

import Foundation
import UIKit

class SlideMenuView : UIView {
    
    @IBOutlet var _contentView: UIView!
    @IBOutlet weak var slideMenuLeadingContraint: NSLayoutConstraint!
    
    @IBOutlet weak var sideMenuWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuView: SubSlideMenuView!
    @IBOutlet weak var backgroundView: UIView!
    private var sideMenuRevealWidth: CGFloat = 260
    private let paddingForRotation: CGFloat = 150
    private var isExpanded: Bool = false
    private var sideMenuShadowView: UIView!
    private var maxSubSlideMenuWidth : CGFloat = 0
    private var baseVC = UIViewController()
    private var lastOffset : CGFloat = 0
    
    // Expand/Collapse the side menu by changing trailing's constant
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    
    private var revealSideMenuOnTop: Bool = false
    
    init(frame: CGRect, baseVC: UIViewController) {
        super.init(frame: frame)
        self.baseVC = baseVC
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.frame.size.height = self.baseVC.view.frame.size.height
        }
        
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
    func commonInit(){
        loadViewFromNib()
        hideMenu()
        self.sideMenuView.isHidden = true
        
        self.backgroundColor = .clear
        self.addLeftShadow()
        
        self.sideMenuWidthConstraint.constant = 0
        self.backgroundView.isHidden = true
        self.backgroundView.isUserInteractionEnabled = false
        self.frame.size.width = 0
        
        // Side Menu
        DispatchQueue.main.async {
            self.maxSubSlideMenuWidth = self.baseVC.view.frame.size.width * 0.7
            self.sideMenuView.defaultHighlightedCell = 0 // Default Highlighted Cell
            self.sideMenuView.delegate = self
           
            self.sideMenuView.translatesAutoresizingMaskIntoConstraints = false
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
            self.backgroundView.addGestureRecognizer(tapGesture)
            
        }
        
        addGesture()
    }
    
    private func hideMenu(){
        isExpanded = false
        print("-> Slide Menu : HIDE")
        UIView.animate(withDuration: 0.2) {
            self.sideMenuWidthConstraint.constant = 0
            self.backgroundView.isHidden = true
            
            self.backgroundView.isUserInteractionEnabled = false
            self.frame.size.width = 0
            // Call this to trigger refresh constraint
            self.layoutIfNeeded()
        } completion: { _ in
            self.sideMenuView.isHidden = true
        }
    }
    
    private func openMenu(){
        isExpanded = true
        print("-> Slide Menu : OPEN")
        UIView.animate(withDuration: 0.2) {
            self.frame.size.width = self.baseVC.view.frame.size.width
            self.sideMenuWidthConstraint.constant = self.maxSubSlideMenuWidth
            self.sideMenuView.isHidden = false
            self.backgroundView.isHidden = false
            
            self.backgroundView.isUserInteractionEnabled = true
            

            // Call this to trigger refresh constraint
            self.layoutIfNeeded()
        } completion: { _ in
            
        }
    }
    
    private func addGesture(){
        let uiPanGestureContainerSwipeHorizontally = UIPanGestureRecognizer(target: self, action: #selector(vContainerOnScroll(_:)))
        uiPanGestureContainerSwipeHorizontally.delaysTouchesBegan = false
        uiPanGestureContainerSwipeHorizontally.delaysTouchesEnded = false
        _contentView.addGestureRecognizer(uiPanGestureContainerSwipeHorizontally)
    }
    
    @objc func viewTapped(){
        handleAction()
    }
    
    @objc func vContainerOnScroll(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self._contentView)
        let newPosition = sideMenuWidthConstraint.constant + (translation.x < lastOffset ? -10 : translation.x > lastOffset ? 10 : 0)
        switch sender.state {
        case .changed:
            lastOffset = translation.x
            sideMenuWidthConstraint.constant = newPosition > maxSubSlideMenuWidth ? maxSubSlideMenuWidth : newPosition < 0 ? 0 : newPosition
        case .ended:
            lastOffset = 0
            if ( newPosition > maxSubSlideMenuWidth / 1.2) {
                self.openMenu()
            }
            else {
                self.hideMenu()
            }
        default:
            break
        }
    }
}

///CALLER
extension SlideMenuView {
    func handleAction(){
        isExpanded ? hideMenu() : openMenu()
    }
}

extension SlideMenuView : SubSlideMenuViewDelegate {
    func selectedCell(_ row: Int) {
        switch row {
        case 0:
            self.baseVC.pushNavigationView(TableScreenViewController(), "Long")
        case 1:
            self.baseVC.pushNavigationView(TableScreenViewController(), "Long")
        case 2:
            self.baseVC.pushNavigationView(DateVC(), "Date")
        default:
            break
        }
    
        handleAction()
    }
}

