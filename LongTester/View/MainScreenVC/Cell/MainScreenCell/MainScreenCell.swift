//
//  MainScreenCell.swift
//  LongTester
//
//  Created by Long on 4/20/23.
//

import UIKit
import SDWebImage

class MainScreenCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var ammountLbl: UILabel!
    @IBOutlet weak var logoImgView: UIImageView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var addressTitle: UILabel!
    
    @IBOutlet weak var roomPriceTitle: UILabel!
    @IBOutlet weak var roomPriceLbl: UILabel!
    @IBOutlet weak var backgroundImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    @IBOutlet weak var settingBtn: UIButton!
    private var dropdown : DropDownView<AddressCollectionDropDownCell, AddressCollectionDropDownCellViewModel>!
    
    var handlePress: () -> () = { }
    var handlePressDropdown: (IndexPath) -> () = {_ in }
    var viewModel: MainScreenCellViewModel? {
        didSet {
            bindData()
        }
    }
    
    private func loadImgViewURL(with url : String?) throws -> URL{
        guard let url = url, let url = URL(string: url) else {
            throw ReadError.invalidURL
        }
        return url
    }
    
    private func bindData(){
        self.backgroundImgView.image = UIImage(named: viewModel?.background?.rawValue ?? "PyramidBG")
        
        self.nameLbl.textColor = viewModel?.background?.fontColor
        self.nameLbl.text = viewModel?.name
        self.addressLbl.text = viewModel?.address
        self.roomPriceLbl.text = (viewModel?.globalPrice?.formatnumberWithDot() ?? "0") + " VND"
        self.setupFullRoom()
        
        self.logoImgView.image = UIImage(named: viewModel?.logo ?? "PyramidBG")
//        do {
//            let imageURL = try loadImgViewURL(with: viewModel?.logo)
//            logoImgView.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "NoImage"))
//        } catch ReadError.invalidURL {
//            print("Cannot read URL")}
//        catch {
//            print("Error data")}
    }
    
    func setupDropdown(viewModels : [AddressCollectionDropDownCellViewModel], baseVC: BaseViewController){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dropdown = DropDownView<AddressCollectionDropDownCell, AddressCollectionDropDownCellViewModel>(baseVC : baseVC, anchorView: self.settingBtn)
            
            self.dropdown.cellViewModels = viewModels
            
            self.dropdown.tableWidth = 200
            self.dropdown.tableHeight = 50
            self.dropdown.cellHeight = 50
            self.dropdown.heightOffset = -3
//            self.dropdown.highLightColor = .clear
            self.dropdown.horizonalDirection = .auto
            self.dropdown.verticalDirection = .auto
            self.dropdown.delegate = self
        }
    }
    
    private func setupFullRoom(){
        if let current = viewModel?.currentRooms, let total = viewModel?.totalRooms {
            
            var fullString = String(current) + "/" + String(total)
            let behindText = " " + (viewModel?.currentRooms != viewModel?.totalRooms ? Language.localized("shortRoom") :
                                        Language.localized("fullRoom"))
            fullString += behindText
            if (viewModel?.currentRooms != viewModel?.totalRooms){
                
            }
            let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.right

            let attributedStringColor = [NSAttributedString.Key.foregroundColor : viewModel?.background?.fontColor, NSAttributedString.Key.paragraphStyle: paragraphStyle,]; // iMarineBlue
            
            
            let titleString = NSMutableAttributedString(string: fullString, attributes:attributedStringColor as [NSAttributedString.Key : Any])
            titleString.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSRange(location: 0, length: titleString.length))
            
//            check if totalRoom equals to current Room
            if (viewModel?.currentRooms != viewModel?.totalRooms){
                if let indexCurrentRoom = fullString.index(of: String(current)){
                    titleString.addAttribute(.foregroundColor,
                                             value: viewModel?.background?.roomFontColor as Any,
                                             range: NSRange(location: indexCurrentRoom,
                                                            length: String(current).count))
                }
            }
            
            self.ammountLbl.attributedText = titleString
        }
    }
    
    private func addTapGesture(){
        let uiLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(pressLongGesture(_:)))
        uiLongGesture.minimumPressDuration = 0.3
        stackView.addGestureRecognizer(uiLongGesture)
    }
    
    @objc func pressLongGesture(_ gestureRecognizer: UILongPressGestureRecognizer!){
        if (gestureRecognizer.state == .began){
            bgView.addBottomShadow(height: 3, alpha: 0.4)
            
        }
        else if (gestureRecognizer.state == .ended){
            bgView.addBottomShadow(height: 3, alpha: 0.2)
            self.handlePress()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }
    func setup(){        
        bgView.addBottomShadow(height: 3, alpha: 0.2)
        bgView.layer.masksToBounds = false
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 10
        
        stackView.layer.cornerRadius = 10
        stackView.backgroundColor = .white
        stackView.layer.masksToBounds = true
        circleView.layer.cornerRadius = circleView.frame.size.width/2
        circleView.clipsToBounds = true
        
        addressTitle.text = Language.localized("address")
        roomPriceTitle.text = Language.localized("globalPrice")
        addTapGesture()
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func settingBtnPressed(_ sender: Any) {
        dropdown.show()
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions(), animations: {
            [weak self] in
            self?.settingBtn.transform = CGAffineTransform(rotationAngle: .pi)
        }) { (animated) in }
    }
}

extension MainScreenCell : DropDownViewDelegate{
    func didSelect(indexPath: IndexPath) {
        print("Pressed")
        self.handlePressDropdown(indexPath)
    }
    
    func didCloseDropdown(){
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions(), animations: {
            [weak self] in
            self?.settingBtn.transform = CGAffineTransform.identity
        }) { (animated) in }
    }
    
}
