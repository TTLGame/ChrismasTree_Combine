//
//  RoomStatusCell.swift
//  LongTester
//
//  Created by Long on 6/14/23.
//

import UIKit

class RoomStatusCell: UITableViewCell {
    
    @IBOutlet weak var statusShadowImgView: UIImageView!
    @IBOutlet weak var statusImgView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var borderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setup()
    }

    private func setup(){
        bgView.backgroundColor = Color.viewDefaultColor
        
        DispatchQueue.main.async {
            self.statusShadowImgView.layer.cornerRadius = self.statusShadowImgView.bounds.size.height / 2.0
            self.borderView.addBorderGradient(startColor: Color.redPrimary, endColor: Color.darkGreen, lineWidth: 10, startPoint: CGPoint.topLeft, endPoint: CGPoint.bottomRight)
            
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.statusShadowImgView.transform = CGAffineTransform(rotationAngle: .pi * 1)
            }
            UIView.animate(withDuration: 0.5, delay: 0.3, options: []) { [weak self] in
                self?.statusShadowImgView.transform = CGAffineTransform(rotationAngle: .pi * 2)
            }
            
            
            UIView.animate(withDuration: 2) { [weak self] in
                self?.borderView.transform = CGAffineTransform(rotationAngle: .pi * 1)
//                self?.statusShadowImgView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                
            }
            
            UIView.animate(withDuration: 3, delay: 2, options: [.repeat, .autoreverse, .allowUserInteraction]) { [weak self] in
                self?.borderView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                
            }
        
            UIView.animate(withDuration: 3, delay: 2.5, options: [.repeat, .autoreverse, .allowUserInteraction]) { [weak self] in
                self?.statusImgView.alpha = 0.7
            }
        }
    
        
//        borderView.layer.borderWidth = 1
//        borderView.layer.borderColor = UIColor.black.cgColor
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
