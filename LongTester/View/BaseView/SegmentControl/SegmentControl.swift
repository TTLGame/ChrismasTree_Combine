//
//  SegmentControl.swift
//  LongTester
//
//  Created by Long on 5/25/23.
//

import Foundation
import UIKit

protocol SegmentControlDelegate : AnyObject {
    
    func didChangeSegment(indexPath: IndexPath, direction : SegmentControl.Direction)
}
class SegmentControl : UIView {
    enum Direction {
        case forward
        case reverse
    }
    
    enum SegmentType {
        case withImage
        case textOnly
    }
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var segCollectionView: UICollectionView!
    
    @IBOutlet weak var slideViewLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var slideView: UIView!
    @IBOutlet weak var slideMenuWidthConstraint: NSLayoutConstraint!
    private var selectedIndex = IndexPath(row: 0, section: 0)
    weak var delegate : SegmentControlDelegate?
  
    /// Custom CellView Model
    public var cellViewModels : [SegmentControlCellViewModel] = [] {
        didSet{
            segCollectionView.reloadData()
        }
    }
    
    /// Custom CellView Model
    public var segmentType : SegmentType = .textOnly {
        didSet{
            segCollectionView.reloadData()
        }
    }
    
    /// Custom backgroundView Color, default white
    public var bgColor : UIColor = .white {
        didSet{
            bgView.backgroundColor = bgColor
        }
    }
    
    /// Custom Selected backgroundView Color, default white
    public var selectedBgColor : UIColor = Color.redPrimary {
        didSet{
            slideView.backgroundColor = selectedBgColor
        }
    }
    
    /// Custom text Color, default black
    public var textColor : UIColor = .black {
        didSet{
            segCollectionView.reloadData()
        }
    }
    
    /// Custom Selected text Color, default white
    public var selectedTextColor : UIColor = .white {
        didSet{
            segCollectionView.reloadData()
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
        setupCollectionView()
        
    }
    
    private func setupCollectionView(){
        segCollectionView.register(UINib(nibName: String(describing: SegmentControlCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SegmentControlCell.self))
        
        segCollectionView.register(UINib(nibName: String(describing: SegmentControlTextCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: SegmentControlTextCell.self))
        
        segCollectionView.delegate = self
        segCollectionView.dataSource = self
    }
}

//MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension SegmentControl: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        handleAnimationSelected(indexPath)
        
    }
    
    private func handleAnimationSelected(_ indexPath: IndexPath){
        let newConstraint = self.slideMenuWidthConstraint.constant * CGFloat(indexPath.row)
        let type : Direction = newConstraint > slideViewLeftConstraint.constant ? .forward : .reverse
    
        UIView.animate(withDuration: 0.3) {
            self.slideViewLeftConstraint.constant = newConstraint
            self.layoutIfNeeded()
        } completion: { _ in }
        delegate?.didChangeSegment(indexPath: indexPath, direction: type)
        segCollectionView.reloadData()
    }
}

extension SegmentControl: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if segmentType == .textOnly {
            let cell: SegmentControlTextCell! = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: SegmentControlTextCell.self),
                for: indexPath) as? SegmentControlTextCell
            cell.viewModel = cellViewModels[indexPath.row]
            cell.setColor(selectedTextColor: selectedTextColor, textColor: textColor)
            cell.selectingOption(didSelect: indexPath.row == selectedIndex.row)
            return cell
            
        }
        else {
            let cell: SegmentControlCell! = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: SegmentControlCell.self),
                for: indexPath) as? SegmentControlCell
            cell.viewModel = cellViewModels[indexPath.row]
            cell.setColor(selectedTextColor: selectedTextColor, textColor: textColor)
            cell.selectingOption(didSelect: indexPath.row == selectedIndex.row)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension SegmentControl: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = self.frame
        var width = frame.width
        if (cellViewModels.count != 0){
            width = (width / CGFloat(cellViewModels.count))
            slideMenuWidthConstraint.constant = width
        }
        return CGSize(width: width, height: frame.height)
    }
}
