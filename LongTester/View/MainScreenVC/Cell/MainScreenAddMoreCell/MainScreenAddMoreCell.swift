//
//  MainScreenAddMoreCell.swift
//  LongTester
//
//  Created by Long on 6/2/23.
//

import UIKit

class MainScreenAddMoreCell: UITableViewCell {

    @IBOutlet weak var clickView: UIView!
    var handlePress: () -> () = { }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        clickView.layer.cornerRadius = 10
        clickView.layer.masksToBounds = true
        
        DispatchQueue.main.async {
            self.clickView.addDashedBorder(color: Color.redPrimary, radius: 10)
        }
        addTapGesture()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func addTapGesture(){
        let uiLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(pressLongGesture(_:)))
        uiLongGesture.minimumPressDuration = 0.1
        clickView.addGestureRecognizer(uiLongGesture)
    }
    
    @objc func pressLongGesture(_ gestureRecognizer: UILongPressGestureRecognizer!){
        if (gestureRecognizer.state == .began){
            clickView.backgroundColor = Color.selectTableView
            
        }
        else if (gestureRecognizer.state == .ended){
            let size = gestureRecognizer.location(in: self)
            clickView.backgroundColor = Color.viewDefaultColor
//            self.handlePress()
            if (size.y < 0 || size.y > self.frame.size.height ||
                size.x < 0 || size.x > self.frame.size.width){
                clickView.backgroundColor = Color.viewDefaultColor
            }
            else {
                self.handlePress()
            }
        }
    }
    
}
