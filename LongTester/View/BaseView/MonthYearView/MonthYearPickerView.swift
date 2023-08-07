//
//  MonthYearPickerView.swift
//  LongTester
//
//  Created by Long on 5/23/23.
//

import Foundation
import UIKit

class MonthYearPickerView: UIPickerView  {
    
    var months : [Int]!
    var disableMonths : [Int]!
    var years : [Int]!
    
    var month: Int = 0
    var year: Int = 0
    
    private var minDate = MonthYear()
    private var maxDate = MonthYear()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setMinDate(date: MonthYear) {
        self.minDate = date
    }
    
    func setMaxDate(date: MonthYear) {
        self.maxDate = date
    }
    
    func selectedDate(date: MonthYear) {
        self.year = date.year
        self.month = date.month
    }
    
    internal func hide() {
        self.removeFromSuperview()
        self.isHidden = true
    }
    
    func commonSetup() {
        setupYears()
        setupMonths()
        
        self.delegate = self
        self.dataSource = self
        
        selectMonth(month: self.month)
        selectYear(year: self.year)
    }
    
    private func setupYears() {
        var years: [Int] = []
        if years.count == 0 {
            let maxYear = maxDate.year
            let minYear = minDate.year
            for year in minYear...maxYear {
                years.append(year)
            }
        }
        self.years = years
    }
    
    private func setupMonths() -> (Int, Int) {
        let maxYear = maxDate.year
        let minYear = minDate.year
        var minMonth = 1
        var maxMonth = 12
        if year == minYear {
            minMonth = minDate.month
        }
        if year == maxYear {
            maxMonth = maxDate.month
        }
        var months: [Int] = []
        for month in minMonth...maxMonth {
//            let range = minMonth...maxMonth
            months.append(month)
//            range.contains(month) ? months.append(month) : disableMonths.append(month)
        }
        self.months = months
        return (minMonth, maxMonth)
    }
    
    private func selectMonth(month: Int) {
        selectRow(months.firstIndex(of: month) ?? 0, inComponent: 0, animated: false)
    }
    
    private func selectYear(year: Int) {
        selectRow(years.firstIndex(of: year) ?? 0, inComponent: 1, animated: false)
    }
}

extension MonthYearPickerView : UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            if (AppConfig.shared.language == .english){
                return DateFormatter().monthSymbols[months[row] - 1].capitalized
            }
            else {
                return "Tháng " + String(months[row])
            }
        case 1:
            return "\(years[row])"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return months.count
        case 1:
            return years.count
        default:
            return 0
        }
    }
    
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) ->  NSAttributedString? {
//        NSAttributedString(
//            string: titleLbl.text ?? "",
//            attributes: [NSAttributedString.Key.foregroundColor: Color.greyPrimary]
//        )
//    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let year  = years[selectedRow(inComponent: 1)]
        if component == 1 {
            if self.year != year {
                self.year = year
                let (minMonth, maxMonth) = setupMonths()
                reloadComponent(0)
                var selectedMonth: Int
                if self.month < minMonth {
                    selectedMonth = minMonth
                } else if self.month > maxMonth {
                    selectedMonth = maxMonth
                } else {
                    selectedMonth = self.month
                }
                selectMonth(month: selectedMonth)
                self.month = selectedMonth
            }
        } else {
            self.month = months[selectedRow(inComponent: 0)]
        }
        self.year = year
    }
}
 
