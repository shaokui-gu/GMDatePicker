//
//  SwiftUIView.swift
//  
//
//  Created by gavin on 2022/8/9.
//


import SwiftUI

@available(iOS 13.0, *)
public struct GMDatePickerView : UIViewRepresentable {
    @Binding var date:Date
    let initialDate:Date
    let limit:ClosedRange<Date>?
    let type:GMCalendarType
    let enableNoYear:Bool
    
    let locale:Locale
    
    public init(_ date:Binding<Date>, type: GMCalendarType = .gregorian, locale:Locale = .init(identifier: "zh_CN"),  enableNoYear:Bool = false, limit:ClosedRange<Date>? = nil) {
        self._date = date
        self.initialDate = date.wrappedValue
        self.type = type
        self.limit = limit
        self.enableNoYear = enableNoYear
        self.locale = locale
    }
    
    public func makeUIView(context: Context) -> GMDatePicker {
        let datePicker = GMDatePicker(initialDate, type: self.type, locale: self.locale, enableNoYear: self.enableNoYear, limit: self.limit)
        datePicker.onChangedCallBack = { date in
            self.date = date
        }
        return datePicker
    }
    
    public func updateUIView(_ uiView: GMDatePicker, context: Context) {
        if date != uiView.date {
            uiView.scrollToDate(date)
        }
        if locale.identifier != uiView.locale.identifier {
            uiView.locale = locale
        }
    }
    
    public typealias UIViewType = GMDatePicker
}

@available(iOS 13.0, *)
struct GMDatePickerView_Previews : PreviewProvider {
    @State static var date:Date = Date()
    static var previews : some View {
        GMDatePickerView($date, locale: .init(identifier: "en"))
            .preferredColorScheme(.light)
    }
}

