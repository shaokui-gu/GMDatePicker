//
//  CustomDatePicker.swift
//  Polytime
//
//  Created by gavin on 2022/7/28.
//  Copyright © 2022 cn.kroknow. All rights reserved.
//

import Foundation
import UIKit

private extension Date {
    
    var components : DateComponents {
        return Calendar.current.dateComponents([.year, .weekday, .month,.day], from: self)
    }
    
    var year : Int  {
        return components.year!
    }
    
    var month : Int {
        return components.month!
    }

    var day : Int {
        return components.day!
    }
    
    func addDay(by : Int ,in calendar : Calendar = Calendar.current) -> Date {
        return calendar.date(byAdding: .day, value: by, to: self)!
    }
    
    func addMonth(by : Int ,in calendar : Calendar = Calendar.current) -> Date {
        return calendar.date(byAdding: .month, value: by, to: self)!
    }
    
    func addYear(by : Int ,in calendar : Calendar = Calendar.current) -> Date {
        return calendar.date(byAdding: .year, value: by, to: self)!
    }
    
    func dateComponents(in calendar : Calendar = Calendar.current) -> DateComponents {
        let components = calendar.dateComponents([.year,.month,.day, .hour, .minute, .second], from: self)
        return components
    }
}

public class GMDatePickerCaculator {
    
    var minYear:Int = 1
    var maxYear:Int = 2099
    var minDate:Date = DateComponents(calendar:Calendar.current, year: 1, month: 1, day: 1).date!
    
    var locale:Locale = Locale.init(identifier: "zh_CN")
    
    private var localBundlePath:String? = Bundle.main.path(forResource: "GMDatePicker", ofType: "bundle")
    
    private func datePickerLocalized(_ str:String) -> String {
        guard let path = localBundlePath else {
            return str
        }
        if locale.identifier == "zh_CN" {
            if let bundle = Bundle(path: "\(path)/zh-Hans.lproj") {
                return NSLocalizedString(str, bundle: bundle, comment: str)
            }
        } else {
            if let bundle = Bundle(path: "\(path)/en.lproj") {
                return NSLocalizedString(str, bundle: bundle, comment: str)
            }
        }
        return str
    }
    
    lazy var lunarFormatter:DateFormatter = {
        let chinese = Calendar(identifier: .chinese)
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.calendar = chinese
        formatter.dateStyle = .medium
        formatter.dateFormat = "U年"
        return formatter
    }()
    
    func daysIn(date:Date, calendar:Calendar = Calendar.current) -> Int {
        return calendar.range(of: .day, in: .month, for: date)!.count
    }
    
    func monthsIn(date:Date, calendar:Calendar = Calendar.current) -> Int {
        if self.leapMonthAt(date: date, calendar: calendar) != nil {
            return 13
        }
        return 12
    }
    
    func dayTitle(date:Date, calendar:Calendar = Calendar.current) -> String {
        if calendar.identifier == Calendar.Identifier.chinese {
            /// 农历
            lunarFormatter.dateFormat = "d"
            return lunarFormatter.string(from: date)
        } else {
            /// 公历
            let day = date.day
            return self.datePickerLocalized("\(day)日")
        }
    }
    
    func monthTitle(date:Date, calendar:Calendar = Calendar.current) -> String {
        if calendar.identifier == Calendar.Identifier.chinese {
            /// 农历
            lunarFormatter.dateFormat = "MMM"
            return lunarFormatter.string(from: date)
        } else {
            /// 公历
            let month = date.month
            return self.datePickerLocalized("\(month)月")
        }
    }
    
    func yearTitle(date:Date, calendar:Calendar = Calendar.current) -> String {
        if calendar.identifier == Calendar.Identifier.chinese {
            /// 农历
            lunarFormatter.dateFormat = "U年"
            return lunarFormatter.string(from: date)
        } else {
            /// 公历
            let year = date.year
            return "\(year)\(self.datePickerLocalized("年"))"
        }
    }
    
    func leapMonthAt(date:Date, calendar:Calendar = Calendar.current) -> Int? {
        guard calendar.identifier == .chinese else {
            return nil
        }
        let components = date.dateComponents(in: calendar)
        let year = components.year
        for index in 1...12 {
            let nextMonthDate = date.addMonth(by: index, in: calendar)
            let nextComponents = nextMonthDate.dateComponents(in: calendar)
            if  nextComponents.year == year, (nextComponents.isLeapMonth ?? false) {
                return nextComponents.month!
            }
        }
        return nil
    }
}

public enum GMCalendarType {
    case gregorian
    case lunar
}

public class GMDatePicker : UIView {
    
    let pickerView = UIPickerView()
    
    let caculator:GMDatePickerCaculator
    
    let calendar:Calendar
    
    var onChangedCallBack:((Date) -> Void)?
    
    private var _date:Date
    
    private var isLeap:Bool = false
    
    private var leapMonth:Int?
    
    private var limit:ClosedRange<Date>? {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    var type:GMCalendarType {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    var enableNoYear:Bool = false {
        didSet {
            pickerView.reloadAllComponents()
        }
    }

    var date:Date {
        get {
            return _date
        }
        set {
            _date = newValue
            self._scrollToDate(date: newValue)
        }
    }

    init(_ initialDate:Date = Date(), type:GMCalendarType = .gregorian, enableNoYear:Bool = false, limit:ClosedRange<Date>? = nil) {
        caculator = GMDatePickerCaculator()
        var calendar:Calendar
        if type == .lunar {
            calendar = Calendar.init(identifier: .chinese)
            calendar.locale = Locale(identifier: "zh_CN")
            let minDate = DateComponents(calendar:Calendar.current, year: 1984, month: 2, day: 2).date!
            if let limit = limit {
                let lower = limit.lowerBound
                let uper = limit.upperBound
                let newMinDate = minDate.addYear(by: lower.year - 1984, in: calendar)
                caculator.minDate = newMinDate
                caculator.minYear = newMinDate.year
                caculator.maxYear = newMinDate.year + (uper.year - lower.year)
            } else {
                caculator.minDate = minDate.addYear(by: -1984)
                caculator.minYear = 1
                caculator.maxYear = 2099
            }
        } else {
            calendar = Calendar.init(identifier: .gregorian)
            caculator.minDate = DateComponents(calendar:Calendar.current, year: limit?.lowerBound.year ?? 1, month: 1, day: 1).date!
            caculator.minYear = caculator.minDate.year
            caculator.maxYear = limit?.upperBound.year ?? 2099
        }
        
        self.calendar = calendar
        let leapMonth = caculator.leapMonthAt(date:initialDate, calendar: calendar)
        if type == .gregorian {
            self.isLeap = false
        } else {
            let yearRow = initialDate.year - caculator.minYear
            let firstMonthDate = caculator.minDate.addYear(by: yearRow, in: self.calendar)
            let lunarComponents = firstMonthDate.dateComponents(in: calendar)
            self.isLeap = lunarComponents.isLeapMonth ?? false
        }
        _date = initialDate
        self.type = type
        super.init(frame: .zero)
        self.leapMonth = leapMonth
        self.enableNoYear = enableNoYear
        pickerView.delegate = self
        pickerView.dataSource = self
        addSubview(pickerView)
        pickerView.reloadAllComponents()
    }
    
    public override func layoutSubviews() {
        pickerView.frame = self.bounds
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
 
@available(iOS 13.0, *)
extension GMDatePicker {
    var userInerfaceStyle:UIUserInterfaceStyle {
        set {
            pickerView.reloadAllComponents()
        }
        get {
           return UITraitCollection.current.userInterfaceStyle
        }
    }
}

extension GMDatePicker : UIPickerViewDelegate, UIPickerViewDataSource {
    
    var titleAttr:[NSAttributedString.Key : Any ] {
        if #available(iOS 13.0, *) {
            return [.font : UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: self.userInerfaceStyle == .dark ?  UIColor.white : UIColor.black]
        } else {
            return [.font : UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.black]
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title:String
        let yearCount = self.caculator.maxYear - self.caculator.minYear + 1
        if component == 0 {
            if row == yearCount {
                title = "----"
            } else {
                let mewDate = self.caculator.minDate.addYear(by: row, in: self.calendar)
                title = self.caculator.yearTitle(date:mewDate, calendar: self.calendar)
            }
        } else if component == 1 {
            let yearRow = pickerView.selectedRow(inComponent: 0)
            let yearAddition = (yearRow == yearCount) ? 0 : yearRow
            let caculateDate =  (yearRow == yearCount) ? DateComponents(calendar:Calendar.current, year: 1984, month: 2, day: 2).date! : self.caculator.minDate
            let mewDate = caculateDate.addYear(by: yearAddition, in: self.calendar).addMonth(by: row, in: self.calendar)
            title = self.caculator.monthTitle(date: mewDate, calendar: self.calendar)
        } else {
            let yearRow = pickerView.selectedRow(inComponent: 0)
            let yearAddition = (yearRow == yearCount) ? 0 : yearRow
            let monthAddition = pickerView.selectedRow(inComponent: 1)
            let caculateDate =  (yearRow == yearCount) ? DateComponents(calendar:Calendar.current, year: 1984, month: 2, day: 2).date! : self.caculator.minDate
            let date = caculateDate.addYear(by: yearAddition, in: self.calendar).addMonth(by: monthAddition, in: self.calendar).addDay(by: row, in: self.calendar)
            title = self.caculator.dayTitle(date: date, calendar: self.calendar)
        }
        return NSAttributedString(string: title, attributes: titleAttr)
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let yearCount = self.caculator.maxYear - self.caculator.minYear + 1
        if component == 0 {
            return self.caculator.maxYear - self.caculator.minYear + 1 + (enableNoYear ? 1 : 0)
        } else if component == 1 {
            let yearRow = pickerView.selectedRow(inComponent: 0)
            let yearAddition = (yearRow == yearCount) ? 0 : yearRow
            let caculateDate =  (yearRow == yearCount) ? DateComponents(calendar:Calendar.current, year: 1984, month: 2, day: 2).date! : self.caculator.minDate
            let mewDate = caculateDate.addYear(by: yearAddition, in: self.calendar)
            return self.caculator.monthsIn(date: mewDate, calendar: self.calendar)
        } else {
            let yearRow = pickerView.selectedRow(inComponent: 0)
            let yearAddition = (yearRow == yearCount) ? 0 : yearRow
            let monthAddition = pickerView.selectedRow(inComponent: 1)
            let caculateDate =  (yearRow == yearCount) ? DateComponents(calendar:Calendar.current, year: 1984, month: 2, day: 2).date! : self.caculator.minDate
            let mewDate = caculateDate.addYear(by: yearAddition, in: self.calendar).addMonth(by: monthAddition, in: self.calendar)
            return self.caculator.daysIn(date: mewDate, calendar: self.calendar)
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let yearCount = self.caculator.maxYear - self.caculator.minYear + 1
        if component == 0 {
            if row == yearCount {
                pickerView.reloadAllComponents()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    let monthAddition = pickerView.selectedRow(inComponent: 1)
                    let dayAddition = pickerView.selectedRow(inComponent: 2)
                    if self.type == .lunar {
                        self._date = DateComponents(calendar:Calendar.current, year: 1984, month: 2, day: 2).date!.addMonth(by: monthAddition, in: self.calendar).addDay(by: dayAddition, in: self.calendar)
                    } else {
                        self._date = DateComponents(calendar:Calendar.current, year: 1, month: 1, day: 1).date!.addMonth(by: monthAddition, in: self.calendar).addDay(by: dayAddition, in: self.calendar)
                    }
                    self.onChangedCallBack?(self.date)
                }
                return
            }
            pickerView.reloadAllComponents()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let monthAddition = pickerView.selectedRow(inComponent: 1)
                let dayAddition = pickerView.selectedRow(inComponent: 2)
                let date = self.caculator.minDate.addYear(by: row, in: self.calendar).addMonth(by: monthAddition, in: self.calendar).addDay(by: dayAddition, in: self.calendar)
                self.updateDate(date)
                self.onChangedCallBack?(self.date)
            }
        } else if component == 1 {
            pickerView.reloadComponent(2)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let yearRow = pickerView.selectedRow(inComponent: 0)
                let dayAddition = pickerView.selectedRow(inComponent: 2)
                let yearAddition = (yearRow == yearCount) ? 0 : yearRow
                let caculateDate =  (yearRow == yearCount) ? DateComponents(calendar:Calendar.current, year: 1984, month: 2, day: 2).date! : self.caculator.minDate
                let date = caculateDate.addYear(by: yearAddition, in: self.calendar).addMonth(by: row, in: self.calendar).addDay(by: dayAddition, in: self.calendar)
                self.updateDate(date)
                self.onChangedCallBack?(self.date)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let yearRow = pickerView.selectedRow(inComponent: 0)
                let yearAddition = (yearRow == yearCount) ? 0 : yearRow
                let monthAddition = pickerView.selectedRow(inComponent: 1)
                let caculateDate =  (yearRow == yearCount) ? DateComponents(calendar:Calendar.current, year: 1984, month: 2, day: 2).date! : self.caculator.minDate
                let date = caculateDate.addYear(by: yearAddition, in: self.calendar).addMonth(by: monthAddition, in: self.calendar).addDay(by: row, in: self.calendar)
                self.updateDate(date)
                self.onChangedCallBack?(self.date)
            }
        }
    }
    
    func updateDate(_ date:Date) {
        if let limit = self.limit {
            if date < limit.lowerBound {
                self._scrollToDate(date: limit.lowerBound)
                return
            } else if date > limit.upperBound {
                self._scrollToDate(date: limit.upperBound)
                return
            }
        }
        self._date = date
    }
    
    func scrollToDate(_ date:Date, animated:Bool = true) {
        if let limit = self.limit {
            if date < limit.lowerBound {
                self._scrollToDate(date: limit.lowerBound, animated: animated)
                return
            } else if date > limit.upperBound {
                self._scrollToDate(date: limit.upperBound, animated: animated)
                return
            }
        }
        self._scrollToDate(date: date, animated: animated)
    }
    
    private func _scrollToDate(date:Date, animated:Bool = true) {
        let year = date.year
        let yearRow = year - self.caculator.minYear
        var monthRow:Int
        let components = date.dateComponents(in: self.calendar)
        if components.isLeapMonth ?? false {
            monthRow = components.month!
        } else {
            monthRow = components.month! - 1
        }
        let dayRow = components.day! - 1
        if self.pickerView.numberOfRows(inComponent: 0) > yearRow {
            self.pickerView.selectRow(yearRow, inComponent: 0, animated: animated)
        }
        if self.pickerView.numberOfRows(inComponent: 1) > monthRow {
            self.pickerView.selectRow(monthRow, inComponent: 1, animated: animated)
        }
        if self.pickerView.numberOfRows(inComponent: 2) > dayRow {
            self.pickerView.selectRow(dayRow, inComponent: 2, animated: animated)
        }
    }
}
