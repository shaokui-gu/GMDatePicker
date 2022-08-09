//
//  SwiftUIView.swift
//  
//
//  Created by gavin on 2022/8/9.
//


import SwiftUI

@available(iOS 13.0, *)
struct GMDatePickerView : UIViewRepresentable {
    @Binding var date:Date
    let initialDate:Date
    let limit:ClosedRange<Date>?
    let type:GMCalendarType
    let enableNoYear:Bool
    
    init(_ date:Binding<Date>, type: GMCalendarType = .gregorian, enableNoYear:Bool = false, limit:ClosedRange<Date>? = nil) {
        self._date = date
        self.initialDate = date.wrappedValue
        self.type = type
        self.limit = limit
        self.enableNoYear = enableNoYear
    }
    
    func makeUIView(context: Context) -> GMDatePicker {
        let datePicker = GMDatePicker(Date(), type: self.type, enableNoYear: self.enableNoYear, limit: self.limit)
        datePicker.date = initialDate
        datePicker.onChangedCallBack = { date in
            self.date = date
        }
        return datePicker
    }
    
    func updateUIView(_ uiView: GMDatePicker, context: Context) {
        if date != uiView.date {
            uiView.scrollToDate(date)
        }
    }
    
    typealias UIViewType = GMDatePicker
}

@available(iOS 13.0, *)
struct GMDatePickerView_Previews : PreviewProvider {
    @State static var date:Date = Date()
    static var previews : some View {
        GMDatePickerView($date)
            .preferredColorScheme(.light)
            .environment(\.locale, .init(identifier: "en"))
    }
}
