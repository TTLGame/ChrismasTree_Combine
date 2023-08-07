//
//  AddressCollectionRadioView.swift
//  LongTester
//
//  Created by Long on 5/16/23.
//

import Foundation

import UIKit

protocol AddressCollectionRadioViewDelegate : AnyObject {
    func didSortData(interator: Int)
}
class AddressCollectionRadioView : UIView {
    let DEFAULT_RADIO_HEIGHT : CGFloat = 30
    private var selectedIndex = IndexPath(row: 0, section: 0)
    weak var delegate : AddressCollectionRadioViewDelegate?
    @IBOutlet weak var radioCollectionView: UICollectionView!
    
    var viewModel: AddressCollectionRadioViewModel? {
        didSet {
            radioCollectionView.reloadData()
        }
    }
    
    init(frame: CGRect, image : UIImage?, text: String) {
        super.init(frame: frame)
        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    func commonInit(){
        loadViewFromNib()
        setupCollectionView()
    }
   
    private func setupCollectionView(){
        radioCollectionView.register(UINib(nibName: String(describing: AddressCollectionRadioViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: AddressCollectionRadioViewCell.self))
        radioCollectionView.delegate = self
        radioCollectionView.dataSource = self

    }
    
    func reloadRadioView(){
        selectedIndex = IndexPath(row: 0, section: 0)
        radioCollectionView.reloadData()
    }
}

extension AddressCollectionRadioView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        delegate?.didSortData(interator: indexPath.row)
        radioCollectionView.reloadData()
        
    }
}
extension AddressCollectionRadioView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.cellViewModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AddressCollectionRadioViewCell! = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: AddressCollectionRadioViewCell.self),
            for: indexPath) as? AddressCollectionRadioViewCell
        cell.viewModel = viewModel?.cellViewModels?[indexPath.row]
        cell.selectingOption(didSelect: indexPath.row == selectedIndex.row)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension AddressCollectionRadioView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let text = viewModel?.cellViewModels?[indexPath.row].title {
            let cellWidth = text.size(withAttributes:[.font: UIFont.systemFont(ofSize:13.0)]).width + CGFloat(Int(DEFAULT_RADIO_HEIGHT))
            return CGSize(width: cellWidth, height: CGFloat(Int(DEFAULT_RADIO_HEIGHT)))
        }
        else {
            return CGSize(width: 90, height: Int(DEFAULT_RADIO_HEIGHT))
        }
    }
}
