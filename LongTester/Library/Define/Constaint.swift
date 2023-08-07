//
//  Constaint.swift
//  LongTester
//
//  Created by Long on 1/3/23.
//

import Foundation
import UIKit

struct App {
    // MARK: - Ratio
    static let ratio: CGFloat = UIScreen.main.bounds.size.width / 375
}

extension App {
    struct Format {
        static let englishMonthYear = "MMM ,yyyy"
        static let vietnamMonthYear = "MM/yyyy"
        static let userDateTime = "yyyy/MM/dd"
        static let serverDateTime = "yyyy-MM-dd"
        static let serverCurrentDateTime = "yyyy-MM-dd HH:mm:ss"
        static let headerDateTime = "dd/MM/yyyy"
        static let reponseDateTime = "dd-MM-yyyy"
        static let imageName = "yyyy-MM-dd_HH:mm:ss"
        static let defaultFieldTime = "HH:mm:ss"
        static let fieldTime = "HH:mm"
        static let countDownTimeFormat = "mm:ss"
        static let estimatedTimeFormat = "HH:mm dd/MM/yyyy"
        static let responseTime = "yyyy-MM-dd'T'HH:mm:ss"
        static let estimatedServerFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        static let currentTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        static let notificationFormat = "dd/MM/yyyy HH:mm"
        static let soaItemDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        static let todoTimeGetCaseFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    }
}
