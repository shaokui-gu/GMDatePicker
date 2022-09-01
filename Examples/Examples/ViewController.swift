//
//  ViewController.swift
//  Examples
//
//  Created by 谷少魁 on 2022/9/1.
//

import UIKit
import SwiftUI
import GMDatePicker

extension Date {
    func lunarFormat() -> String {
        let chinese = Calendar(identifier: .chinese)
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.calendar = chinese
        formatter.dateStyle = .medium
        formatter.dateFormat = "rU年MMMd"
        var lunar = formatter.string(from: self)
        if lunar.contains("1984") {
            formatter.dateFormat = "MMMddd"
            lunar = formatter.string(from: self)
        }
        return lunar
    }
    
    func gregorianFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "en_US")
        formatter.calendar = Calendar.init(identifier: .gregorian)
        formatter.dateStyle = .medium
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: self)
    }
}

class ViewController: UIViewController {

    let datePicker = GMDatePicker(Date(), type: .lunar)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.uikitTest()
        self.swiftUITest()
    }

    
    func uikitTest() {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.font = .systemFont(ofSize: 14)
        label.frame = CGRect(x: 0, y: 100, width: self.view.bounds.size.width, height: 44)
        label.text = Date().lunarFormat() + " / " + Date().gregorianFormat()
        view.addSubview(label)
        
        let width:CGFloat = 320
        let x = (self.view.bounds.size.width - width) / 2
        datePicker.onChangedCallBack = { date in
            label.text = date.lunarFormat() + " / " + date.gregorianFormat()
        }
        datePicker.frame = CGRect(x: x, y: 200, width: width, height: 200)
        view.addSubview(datePicker)
    }
    
    func swiftUITest() {
        let hostingController = UIHostingController(rootView:TestDatePickerView())
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = CGRect(x: 0, y: 460, width: self.view.bounds.size.width, height: 300)
    }

}

struct TestDatePickerView : View {
    
    @State var date = Date()
    @State var type:GMCalendarType = .lunar
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    self.type = .gregorian
                } label: {
                    Text("公历")
                }
                Button {
                    self.type = .lunar
                } label: {
                    Text("农历")
                }
            }
            .frame(height:44)
            Text(date.lunarFormat() + " / " + date.gregorianFormat())
                .foregroundColor(Color.black)
                .font(.system(size: 15))
            Spacer()
            if self.type == .lunar {
                GMDatePickerView($date, type: .lunar)
            } else {
                GMDatePickerView($date, type: .gregorian)
            }
            Spacer()
            
        }
    }
}


