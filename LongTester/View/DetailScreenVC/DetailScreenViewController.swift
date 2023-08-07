//
//  DetailScreenViewController.swift
//  LongTester
//
//  Created by Long on 5/8/23.
//

import UIKit

class DetailScreenViewController: BaseViewController {
    @IBOutlet weak var detailTblView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        bindToViewModel()
        setup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.addBottomShadow(height: 3, alpha: 0.2,radius: 4)
        navigationController?.navigationBar.layer.masksToBounds = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setup(){
        self.detailTblView.register(UINib(nibName: String(describing: RoomStatusCell.self), bundle: nil), forCellReuseIdentifier: String(describing: RoomStatusCell.self))
        self.detailTblView.register(UINib(nibName: String(describing: RoomDetailStatusHeaderCell.self), bundle: nil), forCellReuseIdentifier: String(describing: RoomDetailStatusHeaderCell.self))
        
        self.detailTblView.register(UINib(nibName: String(describing: RoomDetailStatusCell.self), bundle: nil), forCellReuseIdentifier: String(describing: RoomDetailStatusCell.self))
        
        self.detailTblView.delegate = self
        self.detailTblView.dataSource = self
        
    }
}

extension DetailScreenViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 1:
            return UITableView.automaticDimension
        default:
//            return 100
            return UITableView.automaticDimension
        }
    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let bg = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
////        bg.backgroundColor = .white
////        bg.layer.cornerRadius = 30
//        bg.backgroundColor = .clear
////        bg.layer.masksToBounds = true
////        bg.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
//        return bg
//    }
    
}

extension DetailScreenViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch indexPath.row {
        case 1:
            let cell: RoomDetailStatusCell! = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RoomDetailStatusCell.self),
                for: indexPath) as? RoomDetailStatusCell
            let myCustomSelectionColorView = UIView()
            myCustomSelectionColorView.backgroundColor = .clear
            cell.selectedBackgroundView = myCustomSelectionColorView
            
            let type : RoomDetailStatusCell.CornerType = .up
            cell.setupCorner(type: type)
            return cell
            
        default :
            let cell: RoomStatusCell! = tableView.dequeueReusableCell(
                withIdentifier: String(describing: RoomStatusCell.self),
                for: indexPath) as? RoomStatusCell
            let myCustomSelectionColorView = UIView()
            myCustomSelectionColorView.backgroundColor = .clear
            cell.selectedBackgroundView = myCustomSelectionColorView
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
