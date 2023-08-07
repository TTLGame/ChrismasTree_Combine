//
//  AlertModel.swift
//  LongTester
//
//  Created by Long on 4/21/23.
//

import Foundation
import UIKit

struct AlertModel {
    struct ActionModel {
        var title: String?
        var style: UIAlertAction.Style
        var handler: ((UIAlertAction) -> Void)?
    }

    var actionModels = [ActionModel]()
    var title: String?
    var message: String?
    var prefferedStyle: UIAlertController.Style
}

extension AlertModel {
    init(message: String) {
        self.init(actionModels: [
            AlertModel.ActionModel(title: "OK", style: .default, handler: nil)
        ], title: nil, message: message, prefferedStyle: .alert)
    }
    
//    init(title: String, message: String, actionModels : [ActionModel], prefferedStyle : UIAlertController.Style = .alert ) {
//        self.title = title
//        self.message = message
//        self.actionModels = actionModels
//        self.prefferedStyle = prefferedStyle
//    }
}

