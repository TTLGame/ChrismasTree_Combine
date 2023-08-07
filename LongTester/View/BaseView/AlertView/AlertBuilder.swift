//
//  AlertBuilder.swift
//  LongTester
//
//  Created by Long on 4/21/23.
//

import Foundation
import UIKit
class AlertBuilder {
    static func buildAlertController(for model: AlertModel) -> UIAlertController {
        let controller = UIAlertController(title: model.title,
                                           message: model.message,
                                           preferredStyle: model.prefferedStyle)
        model.actionModels.forEach({ controller.addAction(UIAlertAction(title: $0.title,
                                                                        style: $0.style,
                                                                        handler: $0.handler)) })

        return controller
    }
}
